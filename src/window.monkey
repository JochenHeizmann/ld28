Strict

Import level
Import fairlight
Import gameobject
Import dynamicblock
Import hammer

Class Window Extends GameObject Implements DynamicBlock
    Const LEFT_ALIGNED% = 0
    Const RIGHT_ALIGNED% = 1
    Const CENTERED% = 2
    Global img:Image

    Field position:Vector2D = Vector2D.Zero()

    Field level:Level
    Field height%
    Field rect:Rect = New Rect()
    Field type% = 0

    Method New(l:Level, mapX%, mapY%, height%, type%)
        level = l
        position.x = mapX * level.tilemap.tileWidth
        position.y = mapY * level.tilemap.tileHeight
        Self.height = height

        rect.point.x = position.x
        rect.point.y = position.y
        rect.size.x = 16
        rect.size.y = img.Height() * height

        Self.type = type
    End

    Method OnRender:Void()
        For Local c := 0 To height-1
            DrawImage img, position.x, position.y + (c * img.Height()), type
        Next
    End

    Method OnUpdate:Void(delta#)
    End

    Method OnDestroy:Void(hammer:Hammer)
        level.gameObjects.Remove(Self)
    End

    Method GetBlockRect:Rect()
        Return rect
    End
End