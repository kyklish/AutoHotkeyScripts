#NoEnv
#NoTrayIcon
#SingleInstance, Force
SetBatchLines, -1

; LButton:: Click("Left")  ;Not work mouse drag :(
; RButton:: Click("Right") ;Not work mouse drag :(
MButton:: Click("Middle")

;By default only one thread per hotkey.
;Wait N milliseconds to prevent multi-clicks by broken switch in mouse.
Click(ByRef sButton) {
    ; Click %sButton%
    SendInput {Click %sButton%}
    Sleep 200
}
