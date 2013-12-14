Strict

Import fairlight
Import tileids
Import player
Import collisionlayer

Class Level
    Field player:Player
    Field tilemap:TiledMap
    Field blockLayer:CollisionLayer
    Field groundLayer:CollisionLayer

    Method New()
        player = New Player()
    End

    Method Load:Void(levelFile$)
        tilemap = New TiledMap()
        tilemap.Load("maps/level1.json")
        InitializeLevel()
    End

    Method InitializeLevel:Void()
        Local map := tilemap.GetLayer("map")

        ' Init Player Start position
        player.level = Self
        player.Restart()

        blockLayer = New CollisionLayer()
        groundLayer = New CollisionLayer()
    End

    Method OnUpdate:Void(delta#)
        ResetCollisionLayers()
        UpdateCollisionLayers()
        player.OnUpdate(delta)
    End

    Method ResetCollisionLayers:Void()
        blockLayer.Reset()
        groundLayer.Reset()
    End

    Method UpdateCollisionLayers:Void()
        Local layer := tilemap.GetLayer("map")
        Local viewport := layer.GetCurrentViewport()

        For Local x% = viewport.point.x To viewport.point.x + viewport.size.x
            For Local y% = viewport.point.y To viewport.point.y + viewport.size.y

                Local gx% = x 
                If (gx < 0) Then gx = layer.width - (Abs(gx) Mod layer.width)
                gx = gx Mod layer.width

                Local gy% = y
                If (gy < 0) Then gy = layer.height - (Abs(gy) Mod layer.height)
                gy = gy Mod layer.height

                If (layer.data[gx][gy] > 0)
                    Local tiles := tilemap.GetTilesetForTileId(layer.data[gx][gy])
                    Local bx := gx * tiles.tileWidth
                    Local by := gy * tiles.tileWidth

                    If tiles.GetProperty(layer.data[gx][gy], "block") = "1"
                        blockLayer.AddBox(bx, by, tiles.tileWidth, tiles.tileHeight)  
                        groundLayer.AddBox(bx, by, tiles.tileWidth, tiles.tileHeight)  
                    Else If tiles.GetProperty(layer.data[gx][gy], "ground") = "1"
                        groundLayer.AddBox(bx, by, tiles.tileWidth, tiles.tileHeight)  
                    End
                End
            Next
        Next      
    End

    Method OnRender:Void()
        tilemap.OnRender()
        
        PushMatrix()
        Translate(-tilemap.GetLayer("map").x, -tilemap.GetLayer("map").y)
        player.OnRender()
        'blockLayer.DebugDraw()
        PopMatrix()
    End
End
