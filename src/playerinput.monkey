Strict

Import mojo

Class PlayerInput
    Const POWERBAR_STEP# = 0.02

    Field moveLeftOrRight? = False
    Field right?
    Field left?
    Field jump?
    Field jumpStarted?

    Field fire?
    Field firePower#
    Field resetFire? = False

    Method ResetAll:Void()
        moveLeftOrRight = False
        right = False
        left = False
        jump = False
        jumpStarted = False
        fire = False
        firePower = 0
        resetFire = False
    End

    Method OnUpdate:Void(delta#)    
        moveLeftOrRight = False
        right = Bool(KeyDown(KEY_RIGHT))
        left = Bool(KeyDown(KEY_LEFT))
        jump = Bool(KeyDown(KEY_UP))
        If (Not jumpStarted) Then jumpStarted = Bool(KeyHit(KEY_UP))

        If (KeyHit(KEY_X))
            fire = False
            firePower = 0.0
        Else If (KeyDown(KEY_X))
            firePower += POWERBAR_STEP
            firePower = Clamp(firePower, 0.0, 1.0)
        Else If firePower > 0 And resetFire = False
            fire = True
            resetFire = True
        Else If resetFire
            ResetFire()
        End
    End

    Method ResetFire:Void()
        firePower = 0
        fire = False
        resetFire = False
    End
End