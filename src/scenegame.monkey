Strict

Import fairlight

Import level
Import stone
Import player
Import window
Import coin
Import door

Class SceneGame Extends Scene Implements Updateable, Renderable, IOnTouchDown
    Field level:Level
    Field player:Player

    Method OnEnter:Void()
        Stone.img = LoadImage("gfx/stone.png")
        Player.img = LoadImage("gfx/player.png", 32, 32, 4)
        Hud.powerBar = LoadImage("gfx/powerbar.png", 200, 16, 2)
        Window.img = LoadImage("gfx/window.png", 16, 16, 3)
        Coin.img = LoadImage("gfx/coin.png")
        Door.img = LoadImage("gfx/door.png", 16, 16, 2)

        level = New Level()
        level.Load("maps/level1.json")
    End

    Method OnLeave:Void()
    End

    Method OnUpdate:Void(delta#)
        level.OnUpdate(delta)
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
        level.OnRender()
    End

End