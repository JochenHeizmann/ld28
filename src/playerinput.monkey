Strict

Import mojo

Class PlayerInput
    Field moveLeftOrRight? = False
    Field right?
    Field left?
    Field jump?
    Field jumpStarted?
    Field fire?

    Method OnUpdate:Void(delta#)    
        moveLeftOrRight = False
        right = Bool(KeyDown(KEY_RIGHT))
        left = Bool(KeyDown(KEY_LEFT))
        jump = Bool(KeyDown(KEY_UP))
        If (Not jumpStarted) Then jumpStarted = Bool(KeyHit(KEY_UP))
    End
End