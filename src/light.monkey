Import fairlight

Class Light
    Field position := Vector2D.Zero()
    Field radius# = 196.0

    Method New(x#, y#, radius#)
        position.x = x
        position.y = y
        Self.radius = radius
    End
End
