Import fairlight
Import gameobject
Import light
Import level

Class Torch Extends GameObject
    Global img:Image

    Const ANIM_SPEED# = 0.1

    Field light:Light
    Field level:Level

    Field frame# = 0.0
    Field stp# = 0.0

    Field radius#

    Method New(level:Level, light:Light, radius#)
        Self.level = level
        Self.light = light
        Self.radius = radius
    End

    Method OnUpdate:Void(delta#)
        frame += ANIM_SPEED
        If (frame >= img.Frames()) Then frame -= img.Frames()
    
        stp += 5.0
        light.radius = radius + Sin(stp) * 16
    End

    Method OnRender:Void()
        DrawImage img, light.position.x + img.Width() / 2, light.position.y, frame
    End
End