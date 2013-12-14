Strict

Import level
Import fairlight
Import switch

Class Door Extends GameObject Implements DynamicBlock
    Global img:Image

    Field position := Vector2D.Zero()
    Field level:Level
    Field switch:Switch
    Field height%
    Field rect:Rect

    Field open% = 0

    Method New(l:Level, x%, y%, switch:Switch, height%)
        level = l
        position.x = x * level.tilemap.tileWidth
        position.y = y * level.tilemap.tileHeight
        Self.switch = switch
        Self.height = height

        rect = New Rect(position.x, position.y, img.Width(), height * img.Height())
    End

    Method OnUpdate:Void(delta#)
        If (switch.activated)
            open += 2
            rect.point.y = position.y + open
        Else 
            open = Max(open - 2, 0)            
            rect.point.y = position.y + open
        End
    End

    Method OnRender:Void()
        For Local c := 0 To height-1
            Local frame% = (c > 0)
            DrawImage img, position.x, position.y + (c * img.Height()) + open, frame
        Next
    End

    Method GetBlockRect:Rect()
        Return rect
    End
End