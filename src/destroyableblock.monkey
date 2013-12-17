Strict

Import level
Import fairlight
Import gameobject
Import dynamicblock
Import hammer

Class DestroyableBlock Extends GameObject Implements DynamicBlock
    Const BLOCK1% = 0
    Const BLOCK2% = 1
    Const ICE% = 2
    Global img:Image

    Field position:Vector2D = Vector2D.Zero()

    Field level:Level
    Field rect:Rect = New Rect()
    Field type% = 0

    Method New(l:Level, mapX%, mapY%, type%)
        level = l
        position.x = mapX * level.tilemap.tileWidth
        position.y = mapY * level.tilemap.tileHeight

        rect.point.x = position.x
        rect.point.y = position.y
        rect.size.x = 16
        rect.size.y = img.Height()

        Self.type = type
    End

    Method OnRender:Void()
        DrawImage img, position.x, position.y, type
    End

    Method OnUpdate:Void(delta#)
    End

    Method OnDestroy:Void(hammer:Hammer)
        For Local i% = 0 To 3
            Local dx# = hammer.velocity.x * Rnd(0.1, 0.3)
            level.particleSystem.LaunchParticleGlass(position.x, position.y, dx)
            level.particleSystem.LaunchParticleGlass(position.x, position.y, dx)
        Next
        BaseApplication.GetInstance().soundManager.PlaySfx("sfx/explosion")
        level.gameObjects.Remove(Self)

        level.player.score += 15
    End

    Method GetBlockRect:Rect()
        Return rect
    End
End