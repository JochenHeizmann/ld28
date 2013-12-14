Strict

Import fairlight
Import level

Class Stone
    Global img:Image

    Const THROW_SPEED# = 8.0
    Const CURVE_FACTOR# = 0.4

    Const FRICTION# = 0.98
    Const RESTITUTION# = 0.5

    Field isInInventory? = False
    Field collectable? = False

    Field position:Vector2D = Vector2D.Zero()
    Field velocity:Vector2D = Vector2D.Zero()


    Field level:Level

    Method New(l:Level)
        level = l
    End    

    Method ThrowIt:Void()
        If (Not isInInventory) Then Return

        position.x = level.player.position.x
        position.y = level.player.position.y - 20

        Local power := level.player.input.firePower
        If (power < 0.1) Then power = 0.001
        velocity.x = level.player.velocity.x + (THROW_SPEED * level.player.direction * power)
        velocity.y = (level.player.GetNextY() - level.player.position.y) - (THROW_SPEED * CURVE_FACTOR * level.player.input.firePower)

        velocity.x = Clamp(velocity.x, -8.0, 8.0)
        velocity.y = Clamp(velocity.y, -8.0, 8.0)

        isInInventory = False
        collectable = False
    End

    Method IsCollectable?()
        If (Not isInInventory And collectable)
            Return True
        End

        Return False
    End

    Method OnUpdate:Void(delta#)           
        CheckXCollision()
        CheckYCollision()

        position.x += velocity.x
        position.y += velocity.y
    End

    Method CheckXCollision:Void()
        velocity.x *= FRICTION

        Local x := position.x + velocity.x

        Local bbX := x + img.Width() / 2
        Local bbY := position.y
        Local bbW := 1
        Local bbH := img.Height()

        Local box := level.IntersectRectWithBlock(bbX, bbY, bbW, bbH - 2)
        If (box)
            If (Window(box.object) And Abs(velocity.x) > 2) Then Window(box.object).OnDestroy(Self)
            velocity.x = -velocity.x
        End
    End

    Method CheckYCollision:Void()
        velocity.y += Level.GRAVITY

        Local y := position.y + velocity.y
        Local bbX := position.x + img.Width() / 2
        Local bbY := y
        Local bbW := 1
        Local bbH := img.Height()

        Local box := level.IntersectRectWithBlock(bbX, bbY, bbW, bbH + 1)
        If (box)
            If (Window(box.object) And Abs(velocity.y) > 2) Then Window(box.object).OnDestroy(Self)
            velocity.y = -velocity.y * RESTITUTION
            If (Abs(velocity.y) < Level.GRAVITY)
                velocity.y = 0
                position.y = box.rect.point.y - img.Height()
            End
        End
    End
    
    Method OnRender:Void()
        If (Not isInInventory)
            DrawImage img, position.x, position.y
        End
    End
End