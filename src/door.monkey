Strict

Import level
Import fairlight
Import switch

Class Door Extends GameObject Implements DynamicBlock
    Global img:Image

    Const SPEED# = 2.0

    Global playSfx? = False

    Field position := Vector2D.Zero()
    Field level:Level
    Field switches:List<Switch>
    Field height%
    Field rect:Rect
    Field allSwitchesRequired?
    Field open# = 0

    Field originalSize := Vector2D.Zero()

    Method New(l:Level, x%, y%, switches:List<Switch>, height%, switchesRequired?)
        level = l
        position.x = x * level.tilemap.tileWidth
        position.y = y * level.tilemap.tileHeight
        Self.switches = switches
        Self.height = height
        allSwitchesRequired = switchesRequired

        originalSize.x = img.Width()
        originalSize.y = height * img.Height()
        rect = New Rect(position.x, position.y, img.Width(), originalSize.y)
    End

    Function ResetPlaySfx:Void()
        playSfx = False
    End

    Function UpdateSfx:Void()
        If (playSfx And Not BaseApplication.GetInstance().soundManager.IsChannelPlaying(31))
            BaseApplication.GetInstance().soundManager.PlaySfx("sfx/dooropen", 0.5, 0.0, 31, 1)
        Else If Not playSfx
            BaseApplication.GetInstance().soundManager.StopSfx(31)
        End
    End

    Method OnUpdate:Void(delta#)
        Local activated := False
        For Local switch := EachIn switches
            If (allSwitchesRequired)
                activated = True
                If (Not switch.activated) Then activated = False ; Exit
            Else
                If (switch.activated) Then activated = True ; Exit
            End
        Next

        Local oldOpen := open
        If (activated)
            open = Min(open + SPEED, originalSize.y - SPEED)
            rect.point.y = position.y + open + SPEED
        Else 
            open = Max(open - SPEED, 0.0)            
            rect.point.y = position.y + open + SPEED
        End

        If (open <> oldOpen) Then playSfx = True

        If (open <> oldOpen And Rnd(0, 100) > 80) 
            level.particleSystem.LaunchParticleDoor(position.x + img.Width() / 2, position.y + originalSize.y)
        End

        rect.size.y = originalSize.y - open
    End

    Method OnRender:Void()
        MatrixHelper.SetScissorRelative(position, originalSize)
        For Local c := 0 To height-1
            Local frame% = (c > 0)
            DrawImage img, position.x, Int(position.y + (c * img.Height()) + open), frame
        Next
        MatrixHelper.ResetScissor()
    End

    Method GetBlockRect:Rect()
        Return rect
    End
End