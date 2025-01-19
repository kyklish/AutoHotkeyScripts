#NoEnv
#NoTrayIcon
#SingleInstance, Force
SetBatchLines, -1

global bDownPermit := True
global bUpPermit := False
iDelay := 100

; LButton:: Click("Left", iDelay)  ;Not work mouse drag :(
; RButton:: Click("Right", iDelay) ;Not work mouse drag :(
; MButton:: Click("Middle", 200)

#If bDownPermit
    RButton:: ButtonDown("Right", iDelay)
#If bUpPermit
    RButton Up:: ButtonUp("Right", iDelay)
#If

ButtonDown(sButton, iDelay) {
    bDownPermit := False
    SendInput {Click %sButton% Down}
    Sleep %iDelay%
    bUpPermit := True
}

ButtonUp(sButton, iDelay) {
    bUpPermit := False
    SendInput {Click %sButton% Up}
    Sleep %iDelay%
    bDownPermit := True
}

;By default only one thread per hotkey.
;Wait N milliseconds to prevent multi-clicks by broken switch in mouse.
Click(sButton, iDelay) {
    ; Click %sButton%
    SendInput {Click %sButton%}
    Sleep %iDelay%
}
