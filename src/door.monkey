Strict

Import level
Import fairlight
Import switch

Class Door Extends GameObject Implements DynamicBlock
    Global img:Image

    Const SPEED# = 2.0

    Field position := Vector2D.Zero()
    Field level:Level
    Field switches:List<Switch>
    Field height%
    Field rect:Rect
    Field allSwitchesRequired?
    Field open# = 0

    Method New(l:Level, x%, y%, switches:List<Switch>, height%, switchesRequired?)
        level = l
        position.x = x * level.tilemap.tileWidth
        position.y = y * level.tilemap.tileHeight
        Self.switches = switches
        Self.height = height
        allSwitchesRequired = switchesRequired

        rect = New Rect(position.x, position.y, img.Width(), height * img.Height())
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

        If (activated)
            open = Min(open + SPEED, rect.size.y - SPEED)
            rect.point.y = position.y + open + SPEED
        Else 
            open = Max(open - SPEED, 0.0)            
            rect.point.y = position.y + open + SPEED
        End
    End

    Method OnRender:Void()
        MatrixHelper.SetScissorRelative(position, rect.size)
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