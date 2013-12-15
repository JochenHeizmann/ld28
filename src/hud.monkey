Strict

Import mojo
Import level
Import coin
Import fairlight.vendor.fontmachine

Class Hud
    Global powerBar:Image
    Global hudFont:BitmapFont

    Const POWERBAR_X% = 12
    Const POWERBAR_Y% = 450

    Const COIN_X% = 570
    Const COIN_Y% = 450

    Field level:Level

    Method New(l:Level)
        level = l
    End

    Method OnRender:Void()
        If (level.player.hammer.isInInventory)
            DrawImage powerBar, POWERBAR_X + 16, POWERBAR_Y, 0
            Local w := level.player.input.firePower * powerBar.Width()
            Local h := powerBar.Height()
            DrawImage level.player.hammer.img, POWERBAR_X, POWERBAR_Y + 4
            DrawImageRect powerBar, POWERBAR_X + 16, POWERBAR_Y, 0, 0, w, h, 0.0, 1.0, 1.0, 1
        End

        DrawImage Coin.img, COIN_X, COIN_Y

        PushMatrix()
        SetAlpha(0.5)
        Translate(COIN_X + 15, COIN_Y - 5)
        hudFont.DrawText("x" + level.player.coins, 0, 0, eDrawAlign.LEFT)
        SetAlpha(1)
        PopMatrix()

    End
End