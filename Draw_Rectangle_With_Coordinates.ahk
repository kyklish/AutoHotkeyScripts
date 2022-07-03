; Draw rectangle and get coordinates relative to active windows (Work with fullscreen applications!)
#NoEnv
SetBatchLines, -1 ; For speed in general
SetWinDelay, -1   ; For speed of WinMove
BW := 1           ; Border width (and height) in pixels
BC := "Red"       ; Border color

FirstCall := True
CoordMode, Mouse, Screen
Gui, -Caption +ToolWindow +LastFound +AlwaysOnTop
Gui, Color, %BC%
Return

+LButton::
MouseGetPos, OriginX, OriginY
WinGetActiveStats, Title, WindowWidth, WindowHeight, WindowX, WindowY
SetTimer, DrawRectangle, 10
Return

+LButton Up::
SetTimer, DrawRectangle, Off
FirstCall := True
Gui, Cancel
ToolTip
MsgBox, 0, Coordinates, X = %X1%  -  Y = %Y1%  -  W = %W1%  -  H = %H1%
MsgBox, 0, relative: %Title%, % "X = " X1-WindowX  "  -  Y = " Y1-WindowY
Return

DrawRectangle:
MouseGetPos, X2, Y2
; Has the mouse moved?
If (XO = X2) And (YO = Y2)
	Return
Gui, +LastFound
XO := X2, YO := Y2
; Allow dragging to the left of the click point.
If (X2 < OriginX)
	X1 := X2, X2 := OriginX
Else
	X1 := OriginX
; Allow dragging above the click point.
If (Y2 < OriginY)
	Y1 := Y2, Y2 := OriginY
Else
	Y1 := OriginY
; Draw the rectangle
W1 := X2 - X1, H1 := Y2 - Y1
W2 := W1 - BW, H2 := H1 - BW
WinSet, Region, 0-0 %W1%-0 %W1%-%H1% 0-%H1% 0-0  %BW%-%BW% %W2%-%BW% %W2%-%H2% %BW%-%H2% %BW%-%BW%
If (FirstCall) {
	Gui, Show, NA x%X1% y%Y1% w%W1% h%H1%
	FirstCall := False
}
WinMove, , , X1, Y1, W1, H1
ToolTip, %X1% - %Y1% - %X2% - %Y2%
Return

!x::ExitApp
!z::Reload
