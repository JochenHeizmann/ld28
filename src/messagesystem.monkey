Strict

Import fairlight
Import fairlight.vendor.fontmachine
Import level

Class MessageSystem Extends GameObject
    Global img:Image
    Global font:BitmapFont

    Const STATE_OFF% = 0
    Const STATE_MOVE_IN% = 1
    Const STATE_SHOWING% = 2
    Const STATE_MOVE_OUT% = 3

    Const MOVE_SPEED# = 0.025
    Const TYPING_SPEED# = 1.0

    Const MAX_LINES% = 3    

    Field level:Level

    Field queue:StringStack = New StringStack()
    Field currentMessage$
    Field textPos# = 0

    Field textBoxWidth%
    Field position := Vector2D.Zero()

    Field progress#
    Field transition:Transition
    Field transitionIn := New TransitionQuint()
    Field transitionOut := New TransitionOut(New TransitionQuint())

    Field state% = STATE_OFF

    Method New(l:Level)
        level = l
        position.x = BaseApplication.GetInstance().virtualDisplay.virtualWidth / 2 - img.Width() / 2
        position.y = BaseApplication.GetInstance().virtualDisplay.virtualHeight - img.Height()
        textBoxWidth = 605
        transition = transitionIn
    End

    Method GetNextMessage?()
        If (queue.Length() = 0) Then Return False
        level.player.velocity.x = 0

        currentMessage = queue.Get(0)
        textPos = 0
        queue.Remove(0)        
        progress = 1

        Local tbw := textBoxWidth
        Local continueText := " ..."
        If (font.GetTxtWidth(currentMessage) > tbw)
            Local previousSplit% = 0
            Local lastSplit% = 0
            Local tempMessage:List<String> = New List<String>
            Local lines% = 0
            For Local i% = 0 To currentMessage.Length() - 1
                If (String.FromChar(currentMessage[i]) = " ") Then lastSplit = i
                If (font.GetTxtWidth(currentMessage[previousSplit..i]) >= tbw)
                    Local str$
                    If (lines > 0) Then str += "~n"
                    str += currentMessage[previousSplit..(lastSplit)]
                    tempMessage.AddLast(str)
                    previousSplit = lastSplit + 1
                    lines += 1
                    If (lines = MAX_LINES-1) THen tbw -= font.GetTxtWidth(continueText)
                    If (lines >= MAX_LINES) Then Exit
                End
            Next
            If (lines < MAX_LINES)
                If (previousSplit <= currentMessage.Length()) Then tempMessage.AddLast("~n" + currentMessage[previousSplit..])
            Else
                tempMessage.AddLast(continueText)                
                queue.Push(currentMessage[previousSplit..])
            End

            currentMessage = "".Join(tempMessage.ToArray())
        End

        Return True
    End

    Method OnUpdate:Void(delta#)
        If (state = STATE_OFF)
            If (level.IsGamePaused()) Then Return
            If (GetNextMessage()) 
                state = STATE_MOVE_IN
                level.PauseGame()
                transition = transitionIn
                BaseApplication.GetInstance().soundManager.PlaySfx("sfx/msgwin")
            End
        Else If (state = STATE_MOVE_IN)
            progress -= MOVE_SPEED
            If (progress <= 0) 
                progress = 0
                state = STATE_SHOWING
            End
        Else If (state = STATE_SHOWING)
            textPos = Clamp(textPos + TYPING_SPEED, 0.0, Float(currentMessage.Length()))
            If (textPos < Float(currentMessage.Length()) And Int(textPos) Mod 6 = 0) Then BaseApplication.GetInstance().soundManager.PlaySfx("sfx/typing")
        Else If (state = STATE_MOVE_OUT)
            progress += MOVE_SPEED
            If (progress >= 1)
                progress = 1
                state = STATE_OFF
            End
        End
    End

    Method OnUp:Void()
        If (state = STATE_SHOWING)
            If (textPos < currentMessage.Length())
                textPos = currentMessage.Length()
            Else
                If Not(GetNextMessage()) 
                    transition = transitionOut
                    state = STATE_MOVE_OUT
                    BaseApplication.GetInstance().soundManager.PlaySfx("sfx/msgwin")
                    level.UnpauseGame()
                Else
                    progress = 0
                End
            End
        End
    End

    Method OnRender:Void()
        If (state = STATE_OFF) Then Return

        Local py% = position.y + (transition.Calculate(progress) * (img.Height() + 5))  
        DrawImage img, position.x, py 
        font.DrawText(currentMessage[0..Int(textPos)], position.x + 6, py + 9, eDrawAlign.LEFT)     
    End
End