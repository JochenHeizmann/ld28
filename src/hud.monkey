Strict

Import mojo
Import level
Import cornucopia
Import fairlight.vendor.fontmachine

Class Hud
    Global powerBar:Image
    Global hudFont:BitmapFont
    Global hudFontSmall:BitmapFont

    Const POWERBAR_X% = 12
    Const POWERBAR_Y% = 450

    Const CORNUCOPIA_X% = 560
    Const CORNUCOPIA_Y% = 440

    Field level:Level
    Field currentScore% = 0

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

        DrawImage Cornucopia.img, CORNUCOPIA_X, CORNUCOPIA_Y

        PushMatrix()
        SetAlpha(0.5)
        Translate(CORNUCOPIA_X + 15, CORNUCOPIA_Y - 3)
        hudFont.DrawText("x" + level.player.cornucopias, 3, 0, eDrawAlign.LEFT)
        hudFontSmall.DrawText(Cornucopia.levelRemaining + " left", -20, 25, eDrawAlign.LEFT)
        SetAlpha(1)
        PopMatrix()

        If (level.player.score > currentScore) Then currentScore += 1
        hudFont.DrawText(currentScore, 630, 20, eDrawAlign.RIGHT)

    End
End