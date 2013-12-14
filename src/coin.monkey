Strict

Import level
Import fairlight

Class Coin Extends GameObject
    Global img:Image

    Field level:Level
    Field position := Vector2D.Zero()
    Field delta := Vector2D.Zero()

    Field stp%
    Field collected? = False

    Method New(l:Level, x%, y%)
        level = l
        position.x = x * level.tilemap.tileWidth
        position.y = y * level.tilemap.tileHeight
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
            If (stp > 16) Then level.gameObjects.Remove(Self)
        Else
            stp += 1
            position.y += Sin(stp) * 0.1
    
            Local p := level.player.playerBox
            If Rect.Intersect(position.x - 16, position.y - 16, 48, 48, p.point.x, p.point.y, p.size.x, p.size.y)
                collected = True  
                stp = 0     
            End
        End
    End

    Method OnRender:Void()
        If (collected) Then SetAlpha(Max(0.0, 1.0 -  (Float(stp) / 16.0)))
        DrawImage img, position.x, position.y
        SetAlpha(1)
    End
End