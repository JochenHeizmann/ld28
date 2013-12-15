Strict

Import level
Import fairlight

Class Switch Extends GameObject
    Field mapPos := Vector2D.Zero()
    Field boundingBox:Rect
    Field level:Level
    Field hold? = False
    Field activated? = False
    Field id% = -1

    Method New(l:Level, x%, y%, switchId%, hold%)
        mapPos.x = x
        mapPos.y = y
        level = l
        boundingBox = New Rect(mapPos.x * level.tilemap.tileWidth, mapPos.y * level.tilemap.tileHeight, level.tilemap.tileWidth, level.tilemap.tileHeight)
        If (hold = 1) Then Self.hold = True
        id = switchId
    End

    Method OnUpdate:Void(delta#)
        If (activated And hold) Then Return

        Local s := level.player.hammer
        Local playerBox := level.player.playerBox
        activated = False
        If (Rect.Intersect(boundingBox, playerBox))
            activated = True            
        End

        If (Not s.isInInventory And Rect.Intersect(s.position.x, s.position.y, s.img.Width(), s.img.Height(), boundingBox.point.x, boundingBox.point.y, boundingBox.size.x, boundingBox.size.y))
            activated = True
        End

        If (activated)
            level.tilemap.GetLayer("objects").SetTile(mapPos.x, mapPos.y, TileIds.SWITCH + 1)
        Else
            level.tilemap.GetLayer("objects").SetTile(mapPos.x, mapPos.y, TileIds.SWITCH)
        End
    End

    Method OnRender:Void()
    End
End