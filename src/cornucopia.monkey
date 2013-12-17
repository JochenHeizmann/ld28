Strict

Import level
Import fairlight

Class Cornucopia Extends GameObject
    Global img:Image

    Const ANIM_SPEED# = 0.1

    Field frame# = 0

    Field level:Level
    Field position := Vector2D.Zero()
    Field delta := Vector2D.Zero()

    Field stp%
    Field collected? = False

    Global levelCount%
    Global levelRemaining%

    Method New(l:Level, x%, y%)
        level = l
        position.x = x * level.tilemap.tileWidth
        position.y = y * level.tilemap.tileHeight
        levelCount += 1
        levelRemaining += 1
    End

    Function Initialize:Void()
        levelCount = 0
        levelRemaining = 0
    End

    Method OnUpdate:Void(delta#)
        If (collected)
            Local destX := level.player.position.x - img.Width() / 2
            Local destY := level.player.playerBox.point.y + level.player.playerBox.size.y / 2 - img.Height() / 2
            Self.delta.x = (destX - position.x)
            Self.delta.y = (destY - position.y)

            position.x += Self.delta.x / 16.0
            position.y += Self.delta.y / 16.0
            stp += 1
            If (stp > 16) 
                level.player.cornucopias += 1
                level.player.score += 5
                level.gameObjects.Remove(Self)
                levelRemaining -= 1
                If (levelRemaining = 0)
                    level.messageSystem.queue.Push("You've found all jewles. Now find the exit!")
                End
            End
        Else
            stp += 2
            position.y += Sin(stp) * 0.15
    
            Local p := level.player.playerBox
            If Rect.Intersect(position.x - 16, position.y - 16, 48, 48, p.point.x, p.point.y, p.size.x, p.size.y)
                collected = True  
                stp = 0     
                BaseApplication.GetInstance().soundManager.PlaySfx("sfx/bonusitem")
            End
        End

        frame += ANIM_SPEED
        If (frame >= img.Frames()) Then frame -= img.Frames()
    End

    Method OnRender:Void()
        If (collected) Then SetAlpha(Max(0.0, 1.0 -  (Float(stp) / 16.0)))
        DrawImage img, position.x, position.y, frame
        SetAlpha(1)
    End
End