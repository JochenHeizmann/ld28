Strict

Import fairlight
Import level

Class Hammer
    Global img:Image

    Const THROW_SPEED# = 8.0
    Const CURVE_FACTOR# = 0.4

    Const FRICTION# = 0.98
    Const RESTITUTION# = 0.5

    Const ROTATION_STEP# = 10
    Field ROTATION_SPEED# = 0.3
    Field rotate? = False

    Field isInInventory? = False
    Field collectable? = False

    Field position:Vector2D = Vector2D.Zero()
    Field velocity:Vector2D = Vector2D.Zero()

    Field rotation#    

    Field level:Level

    Field hittedEnemy:Enemy = Null
    Field launchSparkle? = False

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

        If (Abs(level.player.velocity.x) < 0.01)
            If (Abs(level.player.velocity.y) > 0.2)
                velocity.x = 0
                velocity.y *= 2
            Else If level.player.input.jump
                velocity.x = 0
                velocity.y = -1.2 * (THROW_SPEED * power)
            End
        End

        isInInventory = False
        collectable = False
        rotate = True

        level.player.hammerJustThrownAway = Player.THROW_AWAY_FRAMES
    End

    Method LooseIt:Void()
        ThrowIt()
        velocity.x = Rnd(0.1, 0.5) * level.player.direction * THROW_SPEED
        velocity.y = Rnd(0.2, 0.5) * THROW_SPEED

        velocity.x = Clamp(velocity.x, -8.0, 8.0)
        velocity.y = Clamp(velocity.y, -8.0, 8.0)
    End

    Method IsCollectable?()
        If (Not isInInventory And collectable)
            Return True
        End

        Return False
    End

    Method OnUpdate:Void(delta#)  
        If (isInInventory) Then Return
            
        If rotate
            rotation += ROTATION_SPEED
            If (GetRotation() Mod 180 = 0)
                If ((Abs(velocity.x) < 3) And (Abs(velocity.y) < 3)) Then rotate = False
            End
            If (level.player.playingIdleAnimation) Then rotation += ROTATION_SPEED * 6 ; rotate = True
        End

        hittedEnemy = Null
        launchSparkle = False


        CheckXCollision()
        CheckYCollision()

        If (Abs(velocity.x) < 1 And Abs(velocity.y) < 1) Then launchSparkle = False

        position.x += velocity.x
        position.y += velocity.y

        If (launchSparkle)
            level.particleSystem.LaunchParticleSparkle(position.x, position.y)
            level.player.playingIdleAnimation = False
            BaseApplication.GetInstance().soundManager.PlaySfx("sfx/hammerhitground")
        End
    End

    Method CheckXCollision:Void()
        velocity.x *= FRICTION

        Local x := position.x + velocity.x

        Local bbX := x + img.Width() / 2
        Local bbY := position.y
        Local bbW := 1
        Local bbH := img.Height()

        Local box:CollisionZone

        If (level.player.invincible <= 0)
            box = level.enemyZones.IntersectRect(bbX, bbY, bbW, bbH - 2)
            If (box And Enemy(box.object))
                hittedEnemy = Enemy(box.object)
                Enemy(box.object).OnHit(Self)
                velocity.x = -velocity.x
            End
        End

        x = position.x + velocity.x
        bbX = x + img.Width() / 2

        box = level.IntersectRectWithBlock(bbX, bbY, bbW, bbH - 2)
        If (box)
            If (DestroyableBlock(box.object) And Abs(velocity.x) > 2) Then DestroyableBlock(box.object).OnDestroy(Self)
            velocity.x = -velocity.x        
            launchSparkle = True
        End        
    End

    Method CheckYCollision:Void()
        velocity.y += Level.GRAVITY

        Local y := position.y + velocity.y
        Local bbX := position.x + img.Width() / 2 - 2
        Local bbY := y
        Local bbW := 4
        Local bbH := img.Height()

        Local box:CollisionZone

        If (level.player.invincible <= 0)
            box = level.enemyZones.IntersectRect(bbX, bbY, bbW, bbH - 2)
            If (box And Enemy(box.object))
                If (hittedEnemy <> Enemy(box.object))
                    ' dont hit enemy twice
                    Enemy(box.object).OnHit(Self)
                End
                velocity.y = -velocity.y
            End
        End

        y = position.y + velocity.y
        bbY = y

        box = level.IntersectRectWithBlock(bbX, bbY, bbW, bbH + 1)
        If (box)
            If (DestroyableBlock(box.object) And Abs(velocity.y) > 2) Then DestroyableBlock(box.object).OnDestroy(Self)
            velocity.y = -velocity.y * RESTITUTION
            If (Abs(velocity.y) < Level.GRAVITY)
                velocity.y = 0
                position.y = box.rect.point.y - img.Height()
            Else
                launchSparkle = True
            End
        End
    End

    Method GetRotation#()
        Return Int(rotation) * ROTATION_STEP Mod 360
    End
    
    Method OnRender:Void()
        If (Not isInInventory)
            PushMatrix()
            Translate (position.x, position.y)
            Rotate(GetRotation())
            DrawImage img, 0, Cos(GetRotation()) * 4
            PopMatrix()
        End
    End
End