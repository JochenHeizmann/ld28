Strict

Import mojo
Import level

Class Hud
    Global powerBar:Image

    Const POWERBAR_X% = 12
    Const POWERBAR_Y% = 450

    Field level:Level

    Method New(l:Level)
        level = l
    End

    Method OnRender:Void()
        If (level.player.stone.isInInventory)
            DrawImage powerBar, POWERBAR_X + 16, POWERBAR_Y, 0
            Local w := level.player.input.firePower * powerBar.Width()
            Local h := powerBar.Height()
            DrawImage level.player.stone.img, POWERBAR_X, POWERBAR_Y + 4
            DrawImageRect powerBar, POWERBAR_X + 16, POWERBAR_Y, 0, 0, w, h, 0.0, 1.0, 1.0, 1
        End
    End
End