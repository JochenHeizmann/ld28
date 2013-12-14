Strict

Import fairlight

Import level

Class SceneGame Extends Scene Implements Updateable, Renderable, IOnTouchDown
    Field level:Level
    Field player:Player

    Method OnEnter:Void()
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
    End

    Method OnRender:Void()
        level.OnRender()
    End

End