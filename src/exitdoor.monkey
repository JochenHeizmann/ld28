Strict

Import fairlight
Import level
Import gameobject
Import cornucopia

Class ExitDoor Extends GameObject
    Global img:Image

    Field level:Level
    Field boundingBox := New Rect()
    Field exitOpened := False
    Field onEnter := False

    Method New(l:Level, x%, y%)
        level = l
        boundingBox.point.x = x * level.tilemap.tileWidth
        boundingBox.point.y = y * level.tilemap.tileHeight - 16
        boundingBox.size.x = img.Width()
        boundingBox.size.y = img.Height()
    End

    Method OnUpdate:Void(delta#)
        exitOpened = True

        If (Not level.player.hammer.isInInventory) Then exitOpened = False
        If (Cornucopia.levelRemaining > 0) Then exitOpened = False

        If (Rect.Intersect(boundingBox, level.player.playerBox))
            If (exitOpened And Not level.levelCompleted)
                level.NextLevel()
            Else If (onEnter = False)
                If (Cornucopia.levelRemaining > 0)
                    level.messageSystem.queue.Push("You have to to collect all jewles before you can leave this level!")
                Else If Not level.player.hammer.isInInventory
                    level.messageSystem.queue.Push("You won't leave this level without your hammer, right?")
                End
            End
            onEnter = True
        Else
            onEnter = False
        End
    End


    Method OnRender:Void()
        DrawImage img, boundingBox.point.x, boundingBox.point.y, Int(exitOpened)
    End
End