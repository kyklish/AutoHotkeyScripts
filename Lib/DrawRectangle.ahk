; Draw rectangle (Not work with fullscreen applications!)
; All coordinates relative to "Screen"!

; Create 4 rectangle lines
CreateRectangle(id, color := "Red") {
	Loop, 4 {
		idL := "Line" . A_Index . id
		CreateMouseClickTransGui(idL)
		Gui, %idL%: Color, % color
	}
}

DrawRectangle(X1, Y1, X2, Y2, id := "")
{
	idL := "Line"
	
	; Check: is Gui exist?
	Gui, %idL%1%id%: +LastFoundExist
	if (!WinExist())
		CreateRectangle(id)
	
	if (X2 > X1) {
		Gui, %idL%1%id%: Show, % "x" X1 " y" Y1 " w" X2 - X1 " h1 NoActivate"
		Gui, %idL%4%id%: Show, % "x" X1 " y" Y2 " w" X2 - X1 " h1 NoActivate"
	} else {
		Gui, %idL%1%id%: Show, % "x" X2 " y" Y1 " w" X1 - X2 " h1 NoActivate"
		Gui, %idL%4%id%: Show, % "x" X2 " y" Y2 " w" X1 - X2 " h1 NoActivate"
	}
	
	if (Y2 > Y1) {
		Gui, %idL%2%id%: Show, % "x" X1 " y" Y1 " w1 h" Y2 - Y1 " NoActivate"
		Gui, %idL%3%id%: Show, % "x" X2 " y" Y1 " w1 h" Y2 - Y1 " NoActivate"
	} else {
		Gui, %idL%2%id%: Show, % "x" X1 " y" Y2 " w1 h" Y1 - Y2 " NoActivate"
		Gui, %idL%3%id%: Show, % "x" X2 " y" Y2 " w1 h" Y1 - Y2 " NoActivate"
	}
}

DestroyRectangle(id := "")
{
	idL := "Line"
	Loop, 4
		Gui, %idL%%A_Index%%id%: Destroy
}
