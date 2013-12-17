Strict

Import fairlight
Import level
Import playerinput
Import hammer

Class Player
    Const IDLE% = 0
    Const RUNNING% = 1
    Const JUMP% = 2
    Const DYING% = 3

    Const DIR_LEFT% = -1
    Const DIR_RIGHT% = 1

    Const IDLE_TIME_COOLDOWN% = 180
    Const IDLE_TIME_MIN_START% = 60
    Const IDLE_TIME_MAX_START% = 120

    'player jumping
    Const JUMP_INITIAL_IMPULSE# = 16
    Const JUMP_SLOWDOWN_FACTOR# = 0.94
    Const JUMP_NO_IMPULSE_SLOWDOWN_FACTOR# = 0.75

    'player walking/running
    Const ACCELERATION_MOMENTUM# = 0.7
    Const ACCELERATION# = 0.4

    Const MAX_VELOCITY_Y# = 32.0
    Const MAX_VELOCITY_X# = 8

    'player frames
    Const FRAME_STANDING# = 2.00
    Const FRAME_STANDING_WITH_HAMMER# = 0.00
    Const FRAME_HAMMER_THROWN_AWAY# = 4.0
    Const WALK_FRAMES% = 1.0
    Const WALK_ANIMSPEED# = 0.15
    Const THROW_AWAY_FRAMES% = 30

    Field invincible% = 0
    Field walkFrame# = 0.0
    Field hammerJustThrownAway% = 0
    Field idleTime% = 0
    Field playingIdleAnimation? = False

    Field score% = 0

    Global img:Image

    Field input:PlayerInput
    Field level:Level

    Field position:Vector2D
    Field frame# = 0

    Field velocity:Vector2D

    Field lastRestart:Vector2D

    Field hitOnGround? = True
    Field playerBox:Rect

    Field state%
    Field direction% = DIR_RIGHT

    Field jumpVelo# = 0

    Field cornucopias% = 0

    Field hammer:Hammer

    Field stp% = 0

    Method New(l:Level)
        level = l

        img.SetHandle(img.Width() / 2, img.Height())
        position = Vector2D.Zero()
        lastRestart = Vector2D.Zero()

        playerBox = New Rect()
        playerBox.size.x = 12
        playerBox.size.y = 28

        velocity = Vector2D.Zero()

        input = New PlayerInput()

        hammer = New Hammer(level)
    End

    Method UpdatePlayerBox:Void()
        SetPlayerBoxTo(position.x, position.y)
    End

    Method SetPlayerBoxTo:Void(x#, y#)
        playerBox.point.x = x - playerBox.size.x / 2
        playerBox.point.y = y - playerBox.size.y
    End

    Method Restart:Void(x% = -1, y% = -1)
        If (x = -1 Or y = -1)
            Local playerStartPosition := level.tilemap.GetLayer("objects").GetNextTileXY(TileIds.START_PLAYER, 0, 0)        
            lastRestart.x = playerStartPosition[0]
            lastRestart.y = playerStartPosition[1]
        End

        level.tilemap.GetLayer("objects").x = lastRestart.x * level.tilemap.tileWidth - BaseApplication.GetInstance().virtualDisplay.virtualWidth / 2
        level.tilemap.GetLayer("objects").y = lastRestart.y * level.tilemap.tileHeight - BaseApplication.GetInstance().virtualDisplay.virtualHeight / 2
        level.tilemap.GetLayer("objects").SetTile(lastRestart.x, lastRestart.y, 0)
        position.x = GetLastRestartX()
        position.y = GetLastRestartY()

        velocity.x = 0
        velocity.y = 0
        input.ResetAll()
    End

    Method GetLastRestartX#()
        Return lastRestart.x * level.tilemap.tileWidth  + level.tilemap.tileWidth / 2
    End

    Method GetLastRestartY#()
        Return lastRestart.y * level.tilemap.tileHeight + level.tilemap.tileHeight
    End

    Method UpdatePhysics:Void()
        If (jumpVelo < 2) Then velocity.y += Level.GRAVITY
        If (velocity.y > MAX_VELOCITY_Y) Then velocity.y = MAX_VELOCITY_Y
    End

    Method UpdateInputs:Void(delta#)
        If (level.IsGamePaused()) Then Return

        input.OnUpdate(delta)

        If (input.right)
            If (state = IDLE) Then state = RUNNING
            direction = DIR_RIGHT
            input.moveLeftOrRight = True
        Else If (input.left)
            If (state = IDLE) Then state = RUNNING
            direction = DIR_LEFT
            input.moveLeftOrRight = True
        End

        If (input.jump)
            If (state = RUNNING Or state = IDLE) And input.jumpStarted
                state = JUMP
                jumpVelo = JUMP_INITIAL_IMPULSE
                input.jumpStarted = False
                BaseApplication.GetInstance().soundManager.PlaySfx("sfx/jump")
            Else If (state = JUMP)
                jumpVelo *= JUMP_SLOWDOWN_FACTOR
            End
        Else If (Not input.jump)
            jumpVelo *= JUMP_NO_IMPULSE_SLOWDOWN_FACTOR
        End
    End

    Method GetNextY#()
        Return position.y + velocity.y - jumpVelo
    End

    Method CheckYMovement:Void()
        Local nextY# = GetNextY()

        SetPlayerBoxTo(position.x, nextY)

        'player is falling
        If (Floor(jumpVelo) = 0)
            state = JUMP

            Local boxesBlocks := level.IntersectAllRectsWithBlock(playerBox.point.x + 1, playerBox.point.y + 1, playerBox.size.x - 2, playerBox.size.y + 1)
            For Local box := EachIn boxesBlocks
                If (Door(box.object))
                    nextY = Int(box.rect.point.y - Door.SPEED - 1)
                    velocity.y = 0
                    SetPlayerBoxTo(position.x, nextY)     
                    state = IDLE        
                    Local box := level.IntersectRectWithBlock(playerBox.point.x + 1, playerBox.point.y + 3, playerBox.size.x - 2, playerBox.size.y - 6)
                    If (box) 'collision with block
                        Die()
                    End
                End
            Next

            Local boxes := level.IntersectAllRectsWithGround(playerBox.point.x + 1, playerBox.point.y + 1, playerBox.size.x - 2, playerBox.size.y + 1)
            If boxes.Count() = 0 Then hitOnGround = False
            For Local box := EachIn boxes
                If (box And Int(position.y <= box.rect.point.y))
                    state = IDLE
                    nextY = box.rect.point.y
                    velocity.y = 0
                    If (hitOnGround = False)
                        'play sfx
                        hitOnGround = True
                        level.particleSystem.LaunchParticleDust(position.x, nextY)
                        BaseApplication.GetInstance().soundManager.PlaySfx("sfx/hitground")
                    End
                    Exit
                End
            Next
        End

        Local jumping% = velocity.y - jumpVelo
        If (jumping < 0)
            Local box := level.IntersectRectWithBlock(playerBox.point.x + 1, playerBox.point.y + 1, playerBox.size.x - 2, playerBox.size.y - 2)
            If (box) 'collision with block
                jumpVelo = 0
                velocity.y = 0
                nextY = box.rect.point.y + box.rect.size.y + img.Height()
            End
        End

        position.y = nextY
    End

    Method CheckXMovement:Void()
        velocity.x = Clamp(velocity.x, -MAX_VELOCITY_X, MAX_VELOCITY_X)
        Local nextX := position.x

        If (Not input.moveLeftOrRight)
            If (state = RUNNING) Then state = IDLE
            If (velocity.x < 0.05 And velocity.x > -0.05) Then velocity.x = 0
            velocity.x *= ACCELERATION_MOMENTUM
        Else
            velocity.x += (direction * ACCELERATION)
        End

        If (velocity.y = 0)
            If ( (velocity.x > 0 And direction = DIR_LEFT) Or (velocity.x < 0 And direction = DIR_RIGHT) )
                If (Rnd(0, 100) > 50) Then level.particleSystem.LaunchParticleDust(position.x, position.y)
            End
        End

        nextX += velocity.x

        SetPlayerBoxTo(nextX, position.y)

        Local box := level.IntersectRectWithBlock(playerBox.point.x + 1, playerBox.point.y + 1, playerBox.size.x - 2, playerBox.size.y - 2)
        If (box)            
            If (velocity.x <> 0)
                nextX = position.x
                velocity.x = 0
            End

            ' set position hard left/right from block
            If (velocity.x = 0)
                If (velocity.x > 0)
                    nextX = playerBox.point.x + playerBox.size.x / 2
                Else If (velocity.x < 0)
                    nextX = playerBox.point.x + playerBox.size.x / 2
                End
            End
        End

        If (position.x <> nextX And state = IDLE) Then state = RUNNING
        position.x = nextX

        If (position.x < (img.Width() / 2)) Then position.x = img.Width() / 2

        Local ex := (level.tilemap.width * level.tilemap.tileWidth) - (img.Width() / 2)
        If (position.x > ex) Then position.x = ex
    End

    Method CheckCollisions:Void()
        Local posX := position.x
        Local posY := position.y - 8
        Local tileId := level.tilemap.GetLayer("objects").GetTileFromPixel(posX, posY)
        Select tileId
            Case TileIds.HAMMER
                hammer.isInInventory = True
                level.tilemap.GetLayer("objects").SetTileAtPixel(posX, posY, 0)
                BaseApplication.GetInstance().soundManager.PlaySfx("sfx/takehammer")
        End

        UpdatePlayerBox()

        ' player <--> enemies / player <--> hammer
        If (invincible <= 0)
            If Rect.Intersect(playerBox.point.x, playerBox.point.y, playerBox.size.x, playerBox.size.y, hammer.position.x - Hammer.img.Width() / 2, hammer.position.y, Hammer.img.Width(), Hammer.img.Height())
                If (hammer.IsCollectable())
                    hammer.isInInventory = True    
                    input.ResetFire()
                    BaseApplication.GetInstance().soundManager.PlaySfx("sfx/takehammer")
                End
            Else
                hammer.collectable = True
            End

            Local box := level.enemyZones.IntersectRect(playerBox.point.x, playerBox.point.y, playerBox.size.x, playerBox.size.y)
            If (box)
                If (hammer.isInInventory)
                    hammer.LooseIt()
                    hammerJustThrownAway = THROW_AWAY_FRAMES
                    invincible = Level.INVINICIBLE_TIME
                    BaseApplication.GetInstance().soundManager.PlaySfx("sfx/playerhit")
                Else
                    Die()
                End
            End
        End
    End

    Method UpdateHammer:Void(delta#)
        If (hammer.isInInventory And input.fire)
            hammer.ThrowIt()    
            BaseApplication.GetInstance().soundManager.PlaySfx("sfx/throwhammer")
            playingIdleAnimation = False        
        End
        hammer.OnUpdate(delta)
    End

    Method OnUpdate:Void(delta#)
        If (level.IsGamePaused()) Then UpdateCamera() ; Return

        If (KeyHit(KEY_R)) Then Die()

        If (invincible > 0) Then invincible -= 1

        If (state <> DYING)
            UpdatePhysics()
            UpdateInputs(delta)
            CheckYMovement()
            CheckXMovement()
            CheckCollisions()
            UpdateHammer(delta)

            If (position.y > (level.tilemap.height * level.tilemap.tileHeight)) Then Die()
        Else
            stp += 1
            If (stp < 32)        
                If (stp > 0)        
                    Local ss := 0
                    If (stp >= 16) Then ss = stp-16
                    position.x += (GetLastRestartX() - position.x) / (16.0 - ss)
                    position.y += (GetLastRestartY() - position.y) / (16.0 - ss)
                    velocity.x = 0
                    velocity.y = 0
                    invincible = Level.INVINICIBLE_TIME
                    input.ResetAll()
                    hammer.isInInventory = True
                End
            Else
                position.x = GetLastRestartX()
                position.y = GetLastRestartY()
                level.playerDied = True
                level.PauseGame()
                state = IDLE
                invincible = Level.INVINICIBLE_TIME
            End
        End
        UpdateAnimation()
        UpdateCamera()

        If (velocity.x = 0 And velocity.y = 0) Then idleTime += 1 Else idleTime = 0
        If (input.firePower > 0) Then idleTime = 0
        If (idleTime > IDLE_TIME_COOLDOWN)
            If (hammer.isInInventory)
                idleTime = Rnd(IDLE_TIME_MIN_START, IDLE_TIME_MAX_START)
                hammer.ThrowIt()
                BaseApplication.GetInstance().soundManager.PlaySfx("sfx/throwup")
                hammer.velocity.x = 0
                hammer.velocity.y = Rnd(-4, -7)
                playingIdleAnimation = True
            End
        End
    End

    Method GetStandingFrame#()
        If (hammer.isInInventory)
            Return FRAME_STANDING_WITH_HAMMER
        Else
            If (hammerJustThrownAway > 0)
                Return FRAME_HAMMER_THROWN_AWAY
            Else
                Return FRAME_STANDING
            End
        End
    End

    Method UpdateAnimation:Void()    
        If (hammerJustThrownAway > 0) Then hammerJustThrownAway -= 1 
        If (state = RUNNING)
            Local walkFactor := Abs(velocity.x / MAX_VELOCITY_X)
            walkFactor = 0.3
            If (walkFactor > 0.01)
                If (walkFactor < 0.2) Then walkFactor = 0.2
                walkFrame += WALK_ANIMSPEED * walkFactor                                                    
                frame = GetStandingFrame() + walkFrame Mod (WALK_FRAMES+1)
            Else
                frame = GetStandingFrame()
            End
        Else If (state = IDLE)
            frame = GetStandingFrame()
        Else If (state = JUMP)
            frame = GetStandingFrame() + 1
        Else If (state = DYING)
            frame = GetStandingFrame() + 1
        End
    End

    Method UpdateCamera:Void()
        Local ty := position.y - (BaseApplication.GetInstance().virtualDisplay.virtualHeight / 2) + (img.Height() / 2)
        level.tilemap.SetOffset(position.x - (BaseApplication.GetInstance().virtualDisplay.virtualWidth / 2), ty)
    End

    Method OnRender:Void()
        If (state = DYING And stp < 32) Then Return

        If (Not (invincible > 0 And invincible Mod 4 > 1))
            If (direction = DIR_RIGHT)
                DrawImage(img, position.x, position.y, frame)
            Else
                DrawImage(img, position.x, position.y, 0.0, -1.0, 1.0, frame)
            End
        End

        hammer.OnRender()
#rem
        SetAlpha(0.2)
        SetColor(255,0,0)
        UpdatePlayerBox()
        DrawRect(playerBox.point.x, playerBox.point.y, playerBox.size.x, playerBox.size.y)
        SetColor(0,0,255)
        DrawRect(hammer.position.x, hammer.position.y, hammer.img.Width(), hammer.img.Height())
        SetAlpha(1)
#end

    End

    Method Die:Void()
        state = DYING
        level.particleSystem.LaunchParticleExplosion(position.x, position.y)
        level.particleSystem.LaunchParticleExplosion(position.x, position.y)
        stp = -32
        BaseApplication.GetInstance().soundManager.PlaySfx("sfx/playerdies")
    End

End