Strict

Import fairlight
Import tileids
Import player
Import collisionlayer
Import hud
Import window
Import coin
Import switch
Import door
Import snake

Class Level
    Field player:Player
    Field tilemap:TiledMap

    Field dynamicBlocks:CollisionLayer
    Field blockLayer:CollisionLayer
    Field groundLayer:CollisionLayer
    Field stopperZones:CollisionLayer
    Field enemyZones:CollisionLayer

    Field hud:Hud
    Field gameObjects:List<GameObject>

    Const GRAVITY# = 0.3
    Const INVINICIBLE_TIME% = 120

    Method New()
        player = New Player(Self)

        hud = New Hud(Self)
    End

    Method Load:Void(levelFile$)
        tilemap = New TiledMap()
        tilemap.Load("maps/level1.json")
        InitializeLevel()
    End

    Method InitializeLevel:Void()
        gameObjects = New List<GameObject>

        ' Init Player Start position
        player.level = Self
        player.Restart()

        blockLayer = New CollisionLayer()
        groundLayer = New CollisionLayer()
        dynamicBlocks = New CollisionLayer()
        stopperZones = New CollisionLayer()
        enemyZones = New CollisionLayer()

        ResetCollisionLayers()
        UpdateCollisionLayers()          

        Local map := tilemap.GetLayer("objects")
        
        For Local x := 0 To tilemap.width-1
            For Local y := 0 To tilemap.height-1
                Select map.GetTile(x,y)
                    Case TileIds.WINDOW_LEFT
                        CreateWindow(TileIds.WINDOW_LEFT, x, y, Window.LEFT_ALIGNED)    

                    Case TileIds.WINDOW_RIGHT
                        CreateWindow(TileIds.WINDOW_RIGHT, x, y, Window.RIGHT_ALIGNED)                        

                    Case TileIds.WINDOW_CENTERED
                        CreateWindow(TileIds.WINDOW_CENTERED, x, y, Window.CENTERED) 

                    Case TileIds.COIN
                        CreateCoin(x, y)   

                    Case TileIds.SWITCH
                        Local p := map.GetTileProperties(x, y)
                        Local hold := Int(p.Get("hold"))
                        Local id := Int(p.Get("id"))
                        gameObjects.AddLast(New Switch(Self, x, y, id, hold))

                    Case TileIds.SNAKE
                        Local speed# = 2.0

                        Local p := map.GetTileProperties(x, y)
                        If (p) Then speed = Float(p.Get("speed"))

                        Local hitpoints# = 3.0
                        If (p) Then hitpoints = Float(p.Get("hitpoints"))


                        gameObjects.AddLast(New Snake(Self, x, y, speed, hitpoints))
                        map.SetTile(x, y, 0)

                    Case TileIds.ENEMY_STOPPER
                        map.SetTile(x, y, 0)
                        stopperZones.AddBox(x * tilemap.tileWidth, y * tilemap.tileHeight, tilemap.tileWidth, tilemap.tileHeight)

                End
            Next
        Next

        ' Iterate again because CreateDoor needs all switches initialized already
        For Local x := 0 To tilemap.width-1
            For Local y := 0 To tilemap.height-1
                Select map.GetTile(x,y)
                    Case TileIds.RED_DOOR_TOP
                        CreateDoor(x, y)
                End
            Next
        Next
    End

    Method CreateCoin:Void(x%, y%)
        tilemap.GetLayer("objects").SetTile(x, y, 0)
        gameObjects.AddLast(New Coin(Self, x, y))
    End

    Method CreateDoor:Void(x%, y%)
        Local map := tilemap.GetLayer("objects")
        Local p := map.GetTileProperties(x, y)
        Local switchIds := p.Get("switchId").Split(",")
        Local allSwitches? = p.Get("allSwitchesRequired") = "1"
        Local doorHeight% = 0
        Local c% = 0
        Repeat
            If (tilemap.height <= y + c) Then Exit
            Local id := map.GetTile(x, y + c)
            If (id = TileIds.RED_DOOR_TOP Or id = TileIds.RED_DOOR_BTM)
                doorHeight += 1 
                map.SetTile(x, y + c, 0)
            Else 
                Exit
            End
            c += 1
        Forever                    

        Local switches:List<Switch> = New List<Switch>
        For Local obj := EachIn gameObjects
            If (Switch(obj))
                For Local switchId := EachIn switchIds
                    switchId = switchId.Trim()
                    If (Int(switchId) = Switch(obj).id)
                        switches.AddLast(Switch(obj))
                    End
                Next
            End
        Next

        gameObjects.AddLast(New Door(Self, x, y, switches, doorHeight, allSwitches))
        map.SetTile(x, y, 0)
    End

    Method CreateWindow:Void(tileId%, x%, y%, type%)
        Local map := tilemap.GetLayer("objects")
        Local winHeight% = 0
        Local c% = 0
        Repeat
            If (tilemap.height <= y + c) Then Exit
            Local id := map.GetTile(x, y + c)
            If (id = tileId) 
                winHeight += 1 
                map.SetTile(x, y + c, 0)
            Else 
                Exit
            End
            c += 1
        Forever                    
        gameObjects.AddLast(New Window(Self, x, y, winHeight, type))  
    End

    Method OnUpdate:Void(delta#)
        UpdateDynamicCollisionLayers()

        For Local o := EachIn gameObjects
            o.OnUpdate(delta)
        Next
        player.OnUpdate(delta)        
    End

    Method ResetCollisionLayers:Void()
        blockLayer.Reset()
        dynamicBlocks.Reset()
        groundLayer.Reset()
        stopperZones.Reset()
    End

    Method UpdateDynamicCollisionLayers:Void()
        dynamicBlocks.Reset()
        enemyZones.Reset()

        For Local o := EachIn gameObjects
            If (DynamicBlock(o))
                Local r := DynamicBlock(o).GetBlockRect()
                If (r) Then dynamicBlocks.AddBox(r.point.x, r.point.y, r.size.x, r.size.y, o)
            End
            If (Enemy(o))
                Local r := Enemy(o).GetBlockRect()
                If (r) Then enemyZones.AddBox(r.point.x, r.point.y, r.size.x, r.size.y, o)
            End
        Next
    End

    Method IntersectRectWithBlock:CollisionZone(x#, y#, w#, h#)
        Local box := blockLayer.IntersectRect(x, y, w, h)
        If (box) Then Return box

        box = dynamicBlocks.IntersectRect(x, y, w, h)
        Return box
    End

    Method IntersectAllRectsWithBlock:List<CollisionZone>(x#, y#, w#, h#)
        Local boxes := blockLayer.IntersectAllRects(x, y, w, h)
        boxes = dynamicBlocks.IntersectAllRects(x, y, w, h, boxes)
        Return boxes
    End

    Method IntersectAllRectsWithGround:List<CollisionZone>(x#, y#, w#, h#)
        Local boxes := groundLayer.IntersectAllRects(x, y, w, h)
        boxes = dynamicBlocks.IntersectAllRects(x, y, w, h, boxes)
        Return boxes
    End

    Method UpdateCollisionLayers:Void()
        Local layer := tilemap.GetLayer("map")
        Local viewport := layer.GetCurrentViewport()

        For Local x% = 0 To layer.width
            For Local y% = 0 To layer.height

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

        UpdateDynamicCollisionLayers()
    End

    Method OnRender:Void()
        tilemap.OnRender()
        
        PushMatrix()
        Translate(-tilemap.GetLayer("map").x, -tilemap.GetLayer("map").y)

        For Local o := EachIn gameObjects
            o.OnRender()
        Next

        player.OnRender()
        'blockLayer.DebugDraw()
        'dynamicBlocks.DebugDraw()
        PopMatrix()

        hud.OnRender()
    End
End
