Strict

Import fairlight

Import level
Import hammer
Import player
Import destroyableblock
Import cornucopia
Import door
Import snake
Import particlesystem
Import exitdoor
Import messagesystem

Class SceneGame Extends Scene Implements Updateable, Renderable, IOnTouchDown, IOnTouchUp, IOnKeyUp
    
    Field state := STATE_GET_READY
    Field stp%

    Const STATE_GET_READY% = 0
    Const STATE_GAME_RUNNING% = 1
    Const STATE_GAME_OVER% = 2
    Const STATE_LEVEL_COMPLETE% = 3

    Field level:Level
    Field player:Player

    Field currentLevel% = 1

    Method OnEnter:Void()

        Hammer.img = LoadImage("gfx/hammer.png", 1, Image.MidHandle)
        Player.img = LoadImage("gfx/player.png", 32, 32, 6)
        Hud.powerBar = LoadImage("gfx/powerbar.png", 200, 16, 2)
        DestroyableBlock.img = LoadImage("gfx/destroyableblocks.png", 16, 16, 3)
        Cornucopia.img = LoadImage("gfx/cornucopia.png", 16, 16, 4)
        Door.img = LoadImage("gfx/door.png", 16, 16, 2)
        Hud.hudFont = New BitmapFont("fonts/24.txt", False)
        Hud.hudFontSmall = New BitmapFont("fonts/18.txt", False)
        Snake.img = LoadImage("gfx/snake.png", 18, 32, 2, Image.MidHandle)
        ParticleSystem.img = LoadImage("gfx/particles.png",3 ,3, 3, Image.MidHandle)
        Torch.img = LoadImage("gfx/torch.png", 7, 27, 5)
        ExitDoor.img = LoadImage("gfx/exit.png", 32, 32, 2)
        MessageSystem.img = LoadImage("gfx/messagewindow.png")
        MessageSystem.font = Hud.hudFontSmall

        Local sm := BaseApplication.GetInstance().soundManager
        sm.globalSfxVolume = 0.3
        sm.LoadAndPlayMusic("sfx/music", 1.0)
        sm.Load("sfx/bonusitem")
        sm.Load("sfx/enemyhit")
        sm.Load("sfx/explosion")
        sm.Load("sfx/hammerhitground")
        sm.Load("sfx/hitground")
        sm.Load("sfx/jump")
        sm.Load("sfx/playerdies")
        sm.Load("sfx/playerhit")
        sm.Load("sfx/takehammer")
        sm.Load("sfx/throwhammer")
        sm.Load("sfx/throwup")
        sm.Load("sfx/dooropen")
        sm.Load("sfx/msgwin")
        sm.Load("sfx/typing")

        level = New Level()
        InitLevel(currentLevel)
    End

    Method InitLevel:Void(levelNo%)
        Print "Init Level: " + levelNo
        level.Load("maps/level" + levelNo + ".json")
        state = STATE_GET_READY
        level.player.OnUpdate(1)
        level.PauseGame()
        level.levelCompleted = False
        stp = 0
    End

    Method OnLeave:Void()
    End

    Method OnTouchUp:Void(event:TouchEvent)
        OnInputUp()
    End

    Method OnKeyUp:Void(event:KeyEvent)
        OnInputUp()
    End

    Method OnInputUp:Void()
        If (state = STATE_GET_READY)
            state = STATE_GAME_RUNNING 
            level.player.input.ResetAll()
            level.player.velocity.x = 0
            level.player.velocity.y = 0
            level.UnpauseGame()
        Else If (state = STATE_LEVEL_COMPLETE)            
        Else If (state = STATE_GAME_RUNNING)
            level.messageSystem.OnUp()
        End
    End

    Field dly% = 0
    Method OnUpdate:Void(delta#)
        If KeyHit(KEY_M) Then BaseApplication.GetInstance().soundManager.ClearMusic()
        level.OnUpdate(delta)

        If (state = STATE_GET_READY)
            level.player.idleTime = 0
        Else If (state = STATE_GAME_RUNNING)          
            If (level.playerDied) Then state = STATE_GET_READY ; level.playerDied = False
            If (level.levelCompleted) 
                dly = 0
                state = STATE_LEVEL_COMPLETE
            End
        Else If (state = STATE_LEVEL_COMPLETE)
            dly += 1
            level.player.input.ResetAll()
            level.player.velocity.x = 0
            level.player.velocity.y = 0
            If (dly > 60)
                currentLevel += 1
                InitLevel(currentLevel)
                state = STATE_GET_READY
                level.player.idleTime = 0
                level.UnpauseGame()
            End
        End
    End

    Method OnTouchDown:Void(e:TouchEvent)
        Local tx := e.position.x + level.tilemap.GetLayer("map").x
        Local ty := e.position.y + level.tilemap.GetLayer("map").y
        Local tileId := level.tilemap.GetLayer("map").GetTileFromPixel(tx, ty)
        Print "TileID: " + tileId
        tileId = level.tilemap.GetLayer("objects").GetTileFromPixel(tx, ty)
        Print "TileID obj: " + tileId
    End

    Method OnRender:Void()
        If (state = STATE_GET_READY)
            level.OnRender()
            SetAlpha(0.5)
            SetColor(0,0,0)
            DrawRect(0,0,640,480)
            SetColor(255,255,255)
            SetAlpha(1.0)
            If (Millisecs() / 500 Mod 2 = 0) Then Hud.hudFont.DrawText("GET READY", 320, 230, eDrawAlign.CENTER)
        Else If (state = STATE_LEVEL_COMPLETE)
            level.OnRender()
            SetAlpha(0.5)
            SetColor(0,0,0)
            DrawRect(0,0,640,480)
            SetColor(255,255,255)
            SetAlpha(1.0)
            If (Millisecs() / 500 Mod 2 = 0) Then Hud.hudFont.DrawText("LEVEL COMPLETED", 320, 230, eDrawAlign.CENTER)
        Else If (state = STATE_GAME_RUNNING)
            level.OnRender()
        End
    End

End