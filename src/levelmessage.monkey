Strict

Import fairlight
Import level
Import gameobject

Class LevelMessage Extends GameObject
    Field level:Level
    Field text$
    Field boundingBox:Rect = New Rect()

    Method New(l:Level, x%, y%, text$)
        level = l
        boundingBox.point.x = x * level.tilemap.tileWidth
        boundingBox.point.y = y * level.tilemap.tileHeight
        boundingBox.size.x = 16
        boundingBox.size.y = 16
        Self.text = text
    End

    Method OnUpdate:Void(delta#)
        If (Rect.Intersect(boundingBox, level.player.playerBox))
            For Local t := EachIn text.Split("||")
                level.messageSystem.queue.Push(t)
            Next
            level.gameObjects.Remove(Self)
        End
    End

    Method OnRender:Void()
    End
End
