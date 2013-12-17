Strict

Import fairlight
Import particlesystem

Import level

Class Particle
    Global level:Level

    Const FADE_OUT_SPEED# = 0.025

    Field inUse? = False
    Field position := Vector2D.Zero()
    Field velocity := Vector2D.Zero()
    Field boundingBox:Rect = New Rect()
    Field alpha# = 1.0
    Field gravity# = 0.0
    Field lifetime# = 120.0
    Field livedFor# = 0.0
    Field collideWithLevelGeometry? = True

    Const TYPE_WHITE% = 0
    Const TYPE_BROWN% = 1
    Const TYPE_RED% = 2

    Field type%

    Method UpdateBoundingBox:Void(x#, y#)
        boundingBox.point.x = x - 1
        boundingBox.point.y = y - 1
        boundingBox.size.x = 3
        boundingBox.size.y = 3
    End

    Method OnUpdate:Void(delta#)
        livedFor += 1

        If (livedFor >= lifetime)
            alpha -= FADE_OUT_SPEED
            If (alpha < 0)
                inUse = False
                Return
            End
        End

        If (collideWithLevelGeometry)
            ' check x movement
            Local nextX := position.x + velocity.x
            UpdateBoundingBox(nextX, position.y)

            Local boxes := level.IntersectAllRectsWithGround(boundingBox.point.x, boundingBox.point.y, boundingBox.size.x, boundingBox.size.y)
            If (boxes.Count() > 0)
                velocity.x = -velocity.x * 0.7
            End

            ' check y movement
            Local nextY := position.y + velocity.y
            UpdateBoundingBox(position.x, nextY)
            boxes = level.IntersectAllRectsWithGround(boundingBox.point.x, boundingBox.point.y, boundingBox.size.x, boundingBox.size.y)
            If (boxes.Count() > 0)
                velocity.y = -velocity.y * 0.7
            End
        End

        position.x += velocity.x
        position.y += velocity.y

        velocity.y += gravity

        UpdateBoundingBox(position.x, position.y)
    End
End