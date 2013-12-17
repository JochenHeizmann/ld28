Strict

Import fairlight
Import level
Import light

Class LightRenderer Implements LayerRenderer
    Field level:Level

    Field v1 := Vector2D.Zero()
    Field v2 := Vector2D.Zero()

    Field lights:List<Light> = New List<Light>
    Field ambientLight# = 0.0

    Method New(l:Level)
        level = l
    End

    Method OnRender:Void(tileId%, tileImage:Image, x#, y#, gobalId%, gx%, gy%)
        Local distance# = 0.0
        Local alpha# = 0.0

        v1.x = x
        v1.y = y

        For Local light := EachIn lights
            v2.x = light.position.x - level.tilemap.GetLayer("map").GetOffsetX()
            v2.y = light.position.y - level.tilemap.GetLayer("map").GetOffsetY()
            If (v2.x < -light.radius Or v2.y < -light.radius Or v2.x > (640+light.radius) Or v2.y > (480+light.radius)) Then Continue

            distance = Abs(Vector2D.Distance(v1, v2)) / light.radius
            alpha += 1.0 - Clamp(distance, 0.0, 1.0)
        Next

        If (alpha > 0.0)
            alpha = Clamp(alpha, ambientLight, 1.0)
            SetAlpha(alpha)
            DrawImage tileImage, x, y, tileId
        End
    End
End
