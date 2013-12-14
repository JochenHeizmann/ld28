Strict

Import fairlight
Import collisionzone

Class CollisionLayer
    Const MAX_SIZE% = 100

    Field boundingBoxes:CollisionZone[MAX_SIZE]
    Field counter% = 0

    Method New()
        For Local i% = 0 To MAX_SIZE-1
            boundingBoxes[i] = New CollisionZone(0,0,0,0)
        Next
    End

    Function LayersCollide?(layer1:CollisionLayer, layer2:CollisionLayer)
        For Local i% = 0 To layer1.counter-1
            For local j% = 0 To layer2.counter-1
                Local x1 := layer1.boundingBoxes[i].x
                Local y1 := layer1.boundingBoxes[i].y
                Local w1 := layer1.boundingBoxes[i].w
                Local h1 := layer1.boundingBoxes[i].h

                Local x1 := layer2.boundingBoxes[j].x
                Local y1 := layer2.boundingBoxes[j].y
                Local w1 := layer2.boundingBoxes[j].w
                Local h1 := layer2.boundingBoxes[j].h

                If Collision.IntersectRect(x1,y1,w1,h1,x2,y2,w2,h2) Then Return True
            Next
        Next

        Return False
    End
    Method Reset:Void()
        counter = 0
    End

    Method AddBox:Void(x%, y%, w%, h%, object:Object = Null)
        If (w > 0)
            If (counter >= boundingBoxes.Length)
                boundingBoxes = boundingBoxes.Resize(boundingBoxes.Length + MAX_SIZE)
            End
            If (Not boundingBoxes[counter]) Then boundingBoxes[counter] = New CollisionZone(0,0,0,0)

            boundingBoxes[counter].rect.point.x = x
            boundingBoxes[counter].rect.point.y = y
            boundingBoxes[counter].rect.size.x = w
            boundingBoxes[counter].rect.size.y = h
            boundingBoxes[counter].object = object
            counter += 1
        End
    End

    Method IntersectRect:CollisionZone(x%, y%, w%, h%)
        For Local i% = 0 To counter-1
            If Rect.Intersect(boundingBoxes[i].rect.point.x, boundingBoxes[i].rect.point.y, boundingBoxes[i].rect.size.x, boundingBoxes[i].rect.size.y, x, y, w, h)
                Return boundingBoxes[i]
            End
        Next
        Return Null
    End

    Method IntersectAllRects:List<CollisionZone>(x%, y%, w%, h%)
        Local l := New List<CollisionZone>
        For Local i% = 0 To counter-1
            If Rect.Intersect(boundingBoxes[i].rect.point.x, boundingBoxes[i].rect.point.y, boundingBoxes[i].rect.size.x, boundingBoxes[i].rect.size.y, x, y, w, h)
                l.AddLast(boundingBoxes[i])
            End
        Next
        Return l
    End

    Method DebugDraw:Void()
        SetAlpha(0.25)
        SetColor(0,255,255)
        For Local i% = 0 To counter-1
            DrawRect(boundingBoxes[i].rect.point.x, boundingBoxes[i].rect.point.y, boundingBoxes[i].rect.size.x, boundingBoxes[i].rect.size.y)                       
        Next
        SetColor(255,255,255)
        SetAlpha(1)
    End
End
