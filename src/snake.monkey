
Import fairlight
Import level
Import gameobject
Import enemy

Class Snake Extends GameObject Implements Enemy
    Global img:Image

    CONST ANIM_SPEED# = 0.1

    Field level:Level

    Field frame#

    Field position := Vector2D.Zero()
    Field velocity := Vector2D.Zero()
    Field boundingBox := New Rect()

    Field hitpoints# = 3.0

    Field speed#

    Field invincible# = 0.0

    Method New(l:Level, x%, y%, speed#, hitpoints#)
        If (speed = 0) Then speed = 2
        level = l
        Self.speed = speed
        Self.hitpoints = hitpoints
        position.x = x * level.tilemap.tileWidth + img.Width() / 2
        position.y = y * level.tilemap.tileHeight

        velocity.x = 2

        UpdateBoundingBox(position.x, position.y)
    End

    Method GetBlockRect:Rect()
        If (invincible > 0) Then Return Null
        Return boundingBox
    End

    Method UpdateBoundingBox:Void(x#, y#)
        boundingBox.size.x = img.Width() * 0.6
        boundingBox.size.y = img.Height() * 0.7
        boundingBox.point.x = x - boundingBox.size.x / 2
        boundingBox.point.y = y + (img.Height() / 2) - boundingBox.size.y
    End

    Method OnUpdate:Void(delta#)
        If (invincible > 0) Then invincible -= 1
        frame += ANIM_SPEED
        If (frame > img.Frames()) Then frame -= img.Frames()

        CheckMovement()
    End

    Method OnHit:Void(hammer:Hammer)
        If (Abs(hammer.velocity.x) > 2 Or Abs(hammer.velocity.y) > 2)
            invincible = Level.INVINICIBLE_TIME
            hitpoints -= 1
            If (hitpoints <= 0) Then level.gameObjects.Remove(Self)        
        End
    End

    Method CheckMovement:Void()
        ' x movement
        Local nextX := position.x + velocity.x
        UpdateBoundingBox(nextX, position.y)

        Local box := level.IntersectRectWithBlock(boundingBox.point.x + 1, boundingBox.point.y + 1, boundingBox.size.x - 2, boundingBox.size.y - 2)
        If (Not box) Then box = level.stopperZones.IntersectRect(boundingBox.point.x + 1, boundingBox.point.y + 1, boundingBox.size.x - 2, boundingBox.size.y - 2)        
        If (box)            
            velocity.x = -velocity.x
            nextX = position.x + velocity.x
        End

        position.x = nextX
        UpdateBoundingBox(position.x, position.y)

        ' y movement
        Local nextY := position.y + velocity.y
        UpdateBoundingBox(position.x, nextY)

        box = level.groundLayer.IntersectRect(boundingBox.point.x + 1, boundingBox.point.y + 1, boundingBox.size.x - 2, boundingBox.size.y + 1)
        If (box)            
            velocity.y = 0
        Else
            velocity.y += level.GRAVITY
        End

        position.y += velocity.y
        UpdateBoundingBox(position.x, position.y)
    End

    Method OnRender:Void()
        If (Not (invincible > 0 And invincible Mod 4 > 1))
            Local scaleX# = 1.0
            If (velocity.x > 0) Then scaleX *= -1
            DrawImage img, position.x, position.y, 0, scaleX, 1, frame
        End

'      SetAlpha(0.5)
'      DrawRect boundingBox.point.x, boundingBox.point.y, boundingBox.size.x, boundingBox.size.y
'      SetAlpha(1)
    End
End