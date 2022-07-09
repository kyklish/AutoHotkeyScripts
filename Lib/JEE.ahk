;==================================================

JEE_ClientToScreen(hWnd, vPosX, vPosY, ByRef vPosX2, ByRef vPosY2)
{
	VarSetCapacity(POINT, 8)
	NumPut(vPosX, &POINT, 0, "Int")
	NumPut(vPosY, &POINT, 4, "Int")
	DllCall("user32\ClientToScreen", Ptr,hWnd, Ptr,&POINT)
	vPosX2 := NumGet(&POINT, 0, "Int")
	vPosY2 := NumGet(&POINT, 4, "Int")
}

;==================================================

JEE_ScreenToClient(hWnd, vPosX, vPosY, ByRef vPosX2, ByRef vPosY2)
{
	VarSetCapacity(POINT, 8)
	NumPut(vPosX, &POINT, 0, "Int")
	NumPut(vPosY, &POINT, 4, "Int")
	DllCall("user32\ScreenToClient", Ptr,hWnd, Ptr,&POINT)
	vPosX2 := NumGet(&POINT, 0, "Int")
	vPosY2 := NumGet(&POINT, 4, "Int")
}

;==================================================

JEE_ScreenToWindow(hWnd, vPosX, vPosY, ByRef vPosX2, ByRef vPosY2)
{
	VarSetCapacity(RECT, 16)
	DllCall("user32\GetWindowRect", Ptr,hWnd, Ptr,&RECT)
	vWinX := NumGet(&RECT, 0, "Int")
	vWinY := NumGet(&RECT, 4, "Int")
	vPosX2 := vPosX - vWinX
	vPosY2 := vPosY - vWinY
}

;==================================================

JEE_WindowToScreen(hWnd, vPosX, vPosY, ByRef vPosX2, ByRef vPosY2)
{
	VarSetCapacity(RECT, 16, 0)
	DllCall("user32\GetWindowRect", Ptr,hWnd, Ptr,&RECT)
	vWinX := NumGet(&RECT, 0, "Int")
	vWinY := NumGet(&RECT, 4, "Int")
	vPosX2 := vPosX + vWinX
	vPosY2 := vPosY + vWinY
}

;==================================================

JEE_ClientToWindow(hWnd, vPosX, vPosY, ByRef vPosX2, ByRef vPosY2)
{
	VarSetCapacity(POINT, 8)
	NumPut(vPosX, &POINT, 0, "Int")
	NumPut(vPosY, &POINT, 4, "Int")
	DllCall("user32\ClientToScreen", Ptr,hWnd, Ptr,&POINT)
	vPosX2 := NumGet(&POINT, 0, "Int")
	vPosY2 := NumGet(&POINT, 4, "Int")

	VarSetCapacity(RECT, 16)
	DllCall("user32\GetWindowRect", Ptr,hWnd, Ptr,&RECT)
	vWinX := NumGet(&RECT, 0, "Int")
	vWinY := NumGet(&RECT, 4, "Int")
	vPosX2 -= vWinX
	vPosY2 -= vWinY
}

;==================================================

JEE_WindowToClient(hWnd, vPosX, vPosY, ByRef vPosX2, ByRef vPosY2)
{
	VarSetCapacity(RECT, 16, 0)
	DllCall("user32\GetWindowRect", Ptr,hWnd, Ptr,&RECT)
	vWinX := NumGet(&RECT, 0, "Int")
	vWinY := NumGet(&RECT, 4, "Int")

	VarSetCapacity(POINT, 8)
	NumPut(vPosX+vWinX, &POINT, 0, "Int")
	NumPut(vPosY+vWinY, &POINT, 4, "Int")
	DllCall("user32\ScreenToClient", Ptr,hWnd, Ptr,&POINT)
	vPosX2 := NumGet(&POINT, 0, "Int")
	vPosY2 := NumGet(&POINT, 4, "Int")
}

;==================================================
