; [The Core] Hotkey Layout
#NoEnv
#SingleInstance Force
#UseHook ; All hotkeys can't be triggered by Send command
SetBatchLines -1
SetWorkingDir %A_ScriptDir%
Menu, Tray, Icon, Northgard.ico
Menu, Tray, Tip, Northgard [The Core] Hotkey Layout

SetMouseDelay, -1
SetKeyDelay, -1, 25

Reload_AsAdmin() ; for BlockInput we need admin rights
GroupAdd, Game, ahk_exe Northgard.exe

;-------------------------------------------------------------
;--------------------- CIVILIAN VARIABLE ---------------------
;-------------------------------------------------------------

; Start game not in fullscreen to proper show help picture by F1 or F10
; "Marketplace" has bigger info menu, so [Delete] hotkey "misses" it's destroy button

; Hotkey combination A&B will screen A key
; $ modifier = to not trigger hotkey itself
; ~ modifier = will not screen default action of key
; SC027 = ;
; SC028 = '

; BUILDINGS BUTTON COORDINATES
colStep  := 57
colBase  := 1695
colOne   := colBase + colStep * 0
colTwo   := colBase + colStep * 1
colThree := colBase + colStep * 2
colFour  := colBase + colStep * 3

global rowVillage  := 220
global rowProdOne  := 315
global rowProdTwo  := 375
global rowMilitary := 465
global rowTrade    := 560
global rowMystic   := 655

;-------------------------------------------------------------
;--------------------- MILITARY VARIABLE ---------------------
;-------------------------------------------------------------

; Any ToolTip, which appear on screen (from any AutoHotKey script) will break this script functionality.
; Game will be "switching", taskbar may appear, cursor will move outside of game window, etc...

; Click and hold [modifierKey & RButton], where you want place head of formation and drag where you want place end of formation.
; Release RButton. Your units will go on places, marked by yellow dots.
; Release [modifierKey] will cancel formation mode.
; Dots - points on screen, where each type of military units will be sended.
; Dots - points on screen, where GUI window (circle) will be shown to help user see future unit's formation.
global period := 100 ; period of calculation dots positions
; Distanse beatween units (unit order are set in unitOrder[] array)
; 0 - position will be on start point (if scale is 1)
; 1 - position will be on end point (if scale is 1)
global unitDist := [0, 1/2, 1] ; length of this array must be in sync with "unitOrder" array length
global unitOrder := ["NorthgardShieldBearer.png", "NorthgardWarrior.png", "NorthgardAxeThrower.png"]
;global unitDist := [0, 1/3, 2/3, 1] ; can't figure out haw to select warcheaf when playing different clanes
;global unitOrder := ["NorthgardWarcheaf.png", NorthgardShieldBearer.png", "NorthgardWarrior.png", "NorthgardAxeThrower.png"]
global scale := 1 ; Scale all distanses in unitDist[] (each value is multiply by [scale]): <1 less sesitive, ==1 linear, >1 more sensitive.
global d := 20 ; gui dot diameter
global r := d // 2 ; gui dot radius
global dotNum := unitDist.Length() ; number of dots
global dotX := [] ; coordinates of dots
global dotY := [] ; coordinates of dots
global dotColor := "Lime" ; [HTML color names] in AutoHotKey.chm
global x0, y0 ; Start point - coordinates of mouse, when you click [modifierKey & RButton].
global x1, y1 ; End point - current mouse coordinates (when you drag mouse after click).
global hypotenuse ; distance beatween Start point and End point

;   x
; ------*x1,y1
; |    /
; |   /
;y|  /hypotenuse
; | /
; |/ <-- A angle
; * x0,y0

if (unitDist.Length() != unitOrder.Length())
	MsgBox, unitDist.Length() != unitOrder.Length()`nLook at cooments above their declaration

CreateDots()

;-------------------------------------------------------------
;--------------------- MILITARY HOTKEYS ----------------------
;-------------------------------------------------------------

#IfWinActive ahk_group Game
; Modifier key of RButton (Right Alt in this hotkey) must be in sync with [modifierKey] variable
; It implement "cancel formation" logic in CalculateDots() when user release [modifierKey]
global modifierKey := "AppsKey"
AppsKey & RButton::DragBegin()
AppsKey & RButton Up::DragEnd()

;-------------------------------------------------------------
;---------------------- GENERAL HOTKEYS ----------------------
;-------------------------------------------------------------

#If
F1::ShowHelp()
<!z::Reload
<!x::ExitApp
<!c::Suspend

#IfWinActive ahk_group Game

F10::ShowHelp()
F11::Reload

;-------------------------------------------------------------
;--------------------- CIVILIAN HOTKEYS ----------------------
;-------------------------------------------------------------

;---------------------------------------
; REMAP DEFAULT HOTKEYS
; CAMERA
O::SendInput {w down}
O Up::SendInput {w up}
K::SendInput {a down}
K Up::SendInput {a up}
L::SendInput {s down}
L Up::SendInput {s up}
SC027::SendInput {d down} ; [;]
SC027 Up::SendInput {d up} 
;---------------------------------------
J::Send b ; BUILD
;---------------------------------------
P::Send e     ; SELECT WARBAND
-::Send u     ; SELECT IDLE WORKERS
SC028::Send g ; SELECT ALL VILLAGERS
[::Send h     ; SELECT ALL SCOUTS
I::Send {Tab} ; SELECT NEXT OF SAME TYPE
;---------------------------------------
U::Send x ; CANCEL ORDER
;---------------------------------------
=::Send p ; PAUSE
;---------------------------------------
B::Send k ; DIPLOMACY
N::Send n ; RIVALITY
H::Send l ; LORE
,::Send l ; LORE
;---------------------------------------
Space::Send {Space}
;---------------------------------------

Delete::DestroyBuilding()

; SELECT UNITS
Q::SelectAllCivUnits("NorthgardVillager.png")
W::SelectAllCivUnits("NorthgardWoodcutter.png")
;::SelectAllCivUnits("Northgard.png")
Space & Q::SelectAllCivUnitsExceptOne("NorthgardVillager.png")
Space & W::SelectAllCivUnitsExceptOne("NorthgardWoodcutter.png")
;Space & ::SelectAllCivUnitsExceptOne("Northgard.png")


; VILLAGE BASED ON J
J & O::Build(colOne, rowVillage)       ; SCOUT CAMP
J & P::Build(colTwo, rowVillage)       ; HOUSE
J & K::Build(colThree, rowVillage)     ; HEALERS HUT
J & L::Build(colFour, rowVillage)      ; BREWERY
J & SC027::Build(colThree, rowProdOne) ; CARVED STONE [;]
J & SC028::Build(colFour, rowProdOne)  ; FORGE [']


; PRODUCTION BASED ON H
H & O::Build(colOne, rowProdOne)       ; WOODCUTTERS LODGE
H & P::Build(colTwo, rowProdOne)       ; MINE
H & K::Build(colOne, rowProdTwo)       ; FISHERMANS HUT
H & L::Build(colTwo, rowProdTwo)       ; HUNTERS LODGE
H & SC027::Build(colThree, rowProdTwo) ; FIELDS [;]
H & SC028::Build(colFour, rowProdTwo)  ; FOOD SILO [']


; MILITARY BASED ON N
N & K::Build(colOne, rowMilitary)       ; TRAINING CAMP
N & L::Build(colTwo, rowMilitary)       ; AXE THROWER CAMP
N & SC027::Build(colThree, rowMilitary) ; SHIELD BEARER CAMP [;]
N & SC028::Build(colFour, rowMilitary)  ; DEFENSE TOWER [']


; TRADE BASED ON B
B & K::Build(colOne, rowTrade)       ; TRADING POST
B & L::Build(colTwo, rowTrade)       ; MARKETPLACE
B & SC027::Build(colThree, rowTrade) ; LONGSHIP DOCK [;]
B & SC028::Build(colFour, rowTrade)  ; LIGHTHOUSE [']

;-------------------------------------------------------------
;----------------------- CIVILIAN CODE -----------------------
;-------------------------------------------------------------

Build(x, y)
{
	y := FixBuildingMenuPosition(y)
	MouseGetPos, _x, _y
	if (!IsBuildingMenuOpen()) ; if building menu closed, open it
		Send b
	Click, %x% %y%
	MouseMove, %_x%, %_y%
}

IsBuildingMenuOpen()
{
	targetColor := 0x5D6677 ; color of building menu boundary
	; Check three points to be sure, that building menu opened
	PixelGetColor, color1, 1658, 350, RGB
	PixelGetColor, color2, 1658, 400, RGB
	PixelGetColor, color3, 1658, 450, RGB
	if (color1 == color2 && color2 == color3)
		return true
	else
		return false
}

FixBuildingMenuPosition(y)
{
	; When you got too many types of military units appears second
	; row of military units. It shifts building menu up. Button with "House"
	; on new position don't overlap with button "House" on new position,
	; so we need shift coordinate of all rows.
	; For example, when you choose military path "GUARDIAN" you got
	; four "Milita" units, you can recieve some unique mistic units, etc.
	PixelGetColor, color, 1674, 727, RGB ; Axe icon of Warband
	if (color != 0xA4B5C1)
		y := y - 50 ; axe icon not there, warband menu is taller, fix position
	return y
}

DestroyBuilding()
{
	; Building's info window has several sizes. In most cases "Destroy Building"
	; button overlaps in different size info windows (except "Marketplace").
	; Y = 902 is optimal coordinate to click overlapped button's region.
	MouseGetPos, _x, _y
	Click, 1200 902 ; "Destroy Building" [Fire button] except "Marketplace"
	Sleep, 50
	Click, 855 560  ; Confirm [OK button]
	MouseMove, %_x%, %_y%
}

SelectAllCivUnits(unit)
{
	; Search unit icon on Civilians menu
	ImageSearch, x, y, 1665, 830, 1895, 970, %unit%
	if (ErrorLevel) {
		ToolTip, %A_ThisFunc%:%unit% - can't find unit's image.
		return
	}
	MouseGetPos, _x, _y
	Click, %x% %y% Right
	Sleep, 50
	MouseMove, %_x%, %_y%
}

SelectAllCivUnitsExceptOne(unit)
{
	SelectAllCivUnits(unit)
	Sleep, 50 ; wait for bottom menu with selected units
	; Search first unit icon in first column of selected units (central bottom menu)
	ImageSearch, x, y, 855, 890, 895, 1045, %unit%
	if (ErrorLevel) {
		ToolTip, %A_ThisFunc%(%unit%) - can't find unit's image.
		return
	}
	MouseGetPos, _x, _y
	Send {Shift down}{Click %x% %y%}
	Sleep, 50
	Send, {Shift up}
	MouseMove, %_x%, %_y%
}

;-------------------------------------------------------------
;------------------ MILITARY FORMATION CODE ------------------
;-------------------------------------------------------------

SelectAllMilUnits(unit)
{
	; Search unit icon on Warband menu
	ImageSearch, x, y, 1665, 695, 1895, 790, %unit%
	if (ErrorLevel) {
		; In this function it is normal logic, when ImageSearch didn't find unit's image.
		; So comment this ToolTip, script will be not reliable with it.
		;ToolTip, %A_ThisFunc%(%unit%) - can't find unit's image.
		return false
	}
	Click, %x% %y% Right
	return true
}

DragBegin()
{
	MouseGetPos, x0, y0
	ShowDot(1, x0, y0)
	SetTimer, CalculateDots, %period%
}

CalculateDots()
{
	Critical, On
	
	; Disable timer ("cancel" formation) if user release [modifierKey]
	if (!GetKeyState(modifierKey, "P")) {
		SetTimer, , Off
		; On release RButton DragEnd() check [hypotenuse] value
		; Set it equal -1 to "cancel" unit's moving
		hypotenuse := -1
		HideDots()
		return
	}
	
	MouseGetPos, x1, y1
	x := x1 - x0
	y := y1 - y0
	hypotenuse := Sqrt(x*x + y*y)
	tanA := Abs(x/y)
	denominator := Sqrt(1 + tanA*tanA)
	cosA := 1 / denominator
	sinA := tanA / denominator
	for i, k in unitDist {
		dotX[i] := Floor(hypotenuse * sinA * k * scale)
		dotY[i] := Floor(hypotenuse * cosA * k * scale)
		if (x < 0)
			dotX[i] := -dotX[i]
		if (y < 0)
			dotY[i] := -dotY[i]
		dotX[i] := x0 + dotX[i]
		dotY[i] := y0 + dotY[i]
	}
	ShowDots()
	Critical, Off
}

DragEnd()
{
	SetTimer, CalculateDots, Off
	if (hypotenuse != -1) { ; "cancel formation" logic, see comments in CalculateDots()
		BlockInput On
		; If military units aready selected, their icon in "Warband" menu changed (glowed and shifted).
		; It can't be finded by [ImageSearch], so reset selection by clicking LButton.
		; It will selected something under cursor, but we don't care what it will be (land, building, unit, etc...)
		Click
		Sleep, 50
		; "GUI Point" main loop A_Index for dotX[] and dotY[] arrays
		id := 1 ; "Military Unit" secondary loop index in MoveUnits() function for unitOrder[] array
		; If [ImageSearch] didn't find military unit, we try find out next available, until we find or unitOrder[] array is finished.
		Loop, % dotNum {
			HideDot(A_Index)
			id := MoveUnits(id, dotX[A_Index], dotY[A_Index]) ; returns index of last checked element in unitOrder[] array
			id++ ; increment this index for next main loop iteration
			Sleep, 50
			if (id > dotNum) ; no more units left in unitOrder[] array
				break
		}
		Send {Esc}
		BlockInput Off
		Send {%modifierKey% Up} ; Possibly prevents "stuck down" modifier key (read BlockInput in AutoHotKey.chm).
	}
	; Hide GUI dots on "cancel formation" or for example when we buy only two types of units in game,
	; they will be sended in first two dots, so we need hide other unused dots.
	HideDots()
}

MoveUnits(startIndex, x, y)
{
	i := startIndex
	while (i <= dotNum) {
		if (SelectAllMilUnits(unitOrder[i])) { ; returns [true] on success, [false] if didn't find military unit
			Sleep, 50
			Click, %x% %y% Right
			break
		}
		i++
	}
	if (i > dotNum)
		i := dotNum
	; Returns index of last checked element in unitOrder[] array.
	return i
}

CreateDot(id)
{
	; Gui, GuiName:New [, Options, Title]
	; If GuiName is specified, a new GUI will be created, destroying any existing GUI with that name.
	; Otherwise, a new unnamed and unnumbered GUI will be created.
	; +E0x20 makes GUI mouse-click transparent.
	Gui, %id%: New, +AlwaysOnTop -Caption +LastFound -SysMenu +ToolWindow +E0x20
	Gui, %id%: Margin, 0, 0
	Gui, %id%: Color, %dotColor%
	WinSet, TransColor, 500 ; This line is necessary to working +E0x20 !!!! Very complicated theme.
;	WinSet, Transparent, 150
	WinSet, Region, 0-0 W%d% H%d% E
}

CreateDots()
{
	Loop, % dotNum
		CreateDot(A_Index) ; create outside of  screen
}

ShowDot(id, x, y)
{
	Gui, %id%: Show, % "W"d " H"d " X" (x - r) " Y" (y - r) " NA"
}

ShowDots()
{
	Loop, % dotNum
		ShowDot(A_Index, dotX[A_Index], dotY[A_Index])
}

HideDot(id)
{
	Gui, %id%: Hide
}

HideDots()
{
	Loop, % dotNum
		HideDot(A_Index)
}

;-------------------------------------------------------------
;----------------------- GENERAL CODE ------------------------
;-------------------------------------------------------------

ShowHelp()
{
	static toggle
	if (toggle := !toggle)
		SplashImage, NorthgardHotKeys.png, B
	else
		SplashImage, OFF
}

SendInput(key)
{
	SendInput, {%key% down}
	Sleep, 25
	SendInput, {%key% up}
}