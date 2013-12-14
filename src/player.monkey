Strict

Import fairlight
Import level
Import playerinput
Import stone

Class Player
    Const IDLE% = 0
    Const RUNNING% = 1
    Const JUMP% = 2
    Const DYING% = 3

    Const DIR_LEFT% = -1
    Const DIR_RIGHT% = 1

    'player jumping
    Const JUMP_INITIAL_IMPULSE# = 16
    Const JUMP_SLOWDOWN_FACTOR# = 0.94
    Const JUMP_NO_IMPULSE_SLOWDOWN_FACTOR# = 0.75

    'player walking/running
    Const ACCELERATION_MOMENTUM# = 0.7
    Const ACCELERATION# = 0.4

    Const MAX_VELOCITY_Y# = 32.0
    Const MAX_VELOCITY_X# = 8

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

    Field stone:Stone

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

        stone = New Stone(level)
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
        position.x = lastRestart.x * level.tilemap.tileWidth  + level.tilemap.tileWidth / 2
        position.y = lastRestart.y * level.tilemap.tileHeight + level.tilemap.tileHeight
    End

    Method UpdatePhysics:Void()
        If (jumpVelo < 2) Then velocity.y += Level.GRAVITY
        If (velocity.y > MAX_VELOCITY_Y) Then velocity.y = MAX_VELOCITY_Y
    End

    Method UpdateInputs:Void(delta#)
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
            Local boxes := level.groundLayer.IntersectAllRects(playerBox.point.x + 1, playerBox.point.y + 1, playerBox.size.x - 2, playerBox.size.y + 1)
            If boxes.Count() = 0 Then hitOnGround = False
            For Local box := EachIn boxes
                If (box And Int(position.y <= box.rect.point.y))
                    state = IDLE
                    nextY = box.rect.point.y
                    velocity.y = 0
                    If (hitOnGround = False)
                        'play sfx
                        hitOnGround = True
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
            Case TileIds.STONE
                stone.isInInventory = True
                level.tilemap.GetLayer("objects").SetTileAtPixel(posX, posY, 0)
        End

        UpdatePlayerBox()
        If Rect.Intersect(playerBox.point.x, playerBox.point.y, playerBox.size.x, playerBox.size.y, stone.position.x, stone.position.y, 1, 1)                    
            If (stone.IsCollectable())
                stone.isInInventory = True        
            End
        Else
            stone.collectable = True
        End
    End

    Method UpdateStone:Void(delta#)
        If (stone.isInInventory And input.fire)
            stone.ThrowIt()
        End
        stone.OnUpdate(delta)
    End

    Method OnUpdate:Void(delta#)
        UpdatePhysics()
        If (state <> DYING)
            UpdateInputs(delta)
            CheckYMovement()
            CheckXMovement()
            CheckCollisions()
            UpdateStone(delta)

            If (position.y > (level.tilemap.height * level.tilemap.tileHeight)) Then Die()
        Else
            jumpVelo *= JUMP_SLOWDOWN_FACTOR
            position.y = GetNextY()
        End
        UpdateAnimation()
        UpdateCamera()
    End

    Const FRAME_STANDING# = 0.99
    Const WALK_FRAMES% = 3.0
    Const WALK_FRAME_FIRST% = 1.0
    Const WALK_FRAME_LAST% = WALK_FRAME_FIRST + WALK_FRAMES
    Const FRAME_JUMPING% = 1
    Const FRAME_FALLING% = 1
    Const FRAME_DYING% = 2
    Const WALK_ANIMSPEED# = 0.15

    Method UpdateAnimation:Void()
        If (state = RUNNING)
            Local walkFactor := Abs(velocity.x / MAX_VELOCITY_X)
            If (walkFactor > 0.01)
                If (walkFactor < 0.2) Then walkFactor = 0.2
                frame += WALK_ANIMSPEED * walkFactor
                If (frame >= WALK_FRAME_LAST) Then frame -= WALK_FRAMES
            Else
                frame = FRAME_STANDING
            End
        Else If (state = IDLE)
            frame = FRAME_STANDING
        Else If (state = JUMP)
            If (Floor(jumpVelo) = 0)
                frame = FRAME_FALLING
            Else
                frame = FRAME_JUMPING
            End
        Else If (state = DYING)
            frame = FRAME_DYING
        End
    End

    Method UpdateCamera:Void()
        Local ty := position.y - (BaseApplication.GetInstance().virtualDisplay.virtualHeight / 2) + (img.Height() / 2)
        level.tilemap.SetOffset(position.x - (BaseApplication.GetInstance().virtualDisplay.virtualWidth / 2), ty)
    End

    Method OnRender:Void()

        If (direction = DIR_RIGHT)
            DrawImage(img, position.x, position.y, frame)
        Else
            DrawImage(img, position.x, position.y, 0.0, -1.0, 1.0, frame)
        End

        stone.OnRender()
#rem
        SetAlpha(0.2)
        SetColor(255,0,0)
        UpdatePlayerBox()
        DrawRect(playerBox.point.x, playerBox.point.y, playerBox.size.x, playerBox.size.y)
        SetColor(0,0,255)
        DrawRect(stone.position.x, stone.position.y, stone.img.Width(), stone.img.Height())
        SetAlpha(1)
#end

    End

    Method Die:Void()
        Error "DIE"
    End

End