#Include <_COMMON_SETTINGS_>

CoordMode, Mouse, Screen

;-------------------------------------------------------------------------------------
ScrollLock::                       ; Alt-Z hotkey, change to your liking
If (BlockMouse := !BlockMouse) {   ; Toggle the BlockMouse variable and check if it is TRUE or FALSE
	MouseMove 9999, 9999, 0      ; Move the cursor to the lower right corner (= A_ScreenWidth, A_ScreenHeight) 
	BlockInput MouseMove          ; Freeze the mouse cursor
} Else {                           ; If unblock: 
	BlockInput MouseMoveOff       ; allow the mouse cursor to move
	MouseMove A_ScreenWidth/2, A_ScreenHeight/2, 0 ; move it to the center of the screen
}
Return
;-------------------------------------------------------------------------------------
