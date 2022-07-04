﻿; [The Core] Hotkey Layout + Military Formation Helper

; Changelog
; v1.0 - Initial release.

#NoEnv
#SingleInstance Force
#UseHook ; All hotkeys can't be triggered by Send command
SetBatchLines -1
SetWorkingDir %A_ScriptDir%
Menu, Tray, Icon, Northgard.ico
Menu, Tray, Tip, Northgard [The Core] Hotkey Layout

SetDefaultMouseSpeed, 0
SetMouseDelay, -1
SetKeyDelay, -1, 25

; By default all [CoordMode] are relative to [Screen], but ToolTip somehow did not obey default value.
; For clarity set them explicitly.
CoordMode,   Pixel, Screen
CoordMode,   Mouse, Screen
CoordMode, ToolTip, Screen

; Send() wrapper function settings: TRUE = SendInput, FALSE = SendEvent
global bSendInput := true
global SendInputDelay := -1
global SendInputPressDuration := 25

global isDebug = IsDebugScript()

if (!isDebug) ; on Debug reload script will break debugging
	Reload_AsAdmin() ; for BlockInput we need admin rights

GroupAdd, Game, ahk_exe Northgard.exe

; Coordinates of search area of all used [ImageSearch] and [PixelGetColor] commands
coords := ParseImageSearchPixelScript()

helpText := "
(
                      [CIVILIAN]
          J = Build        |           P = Select Warband
          U = Cancel Order |           - = Select Idle Workers
          = = Pause        |           ‘ = Select All Villagers
          B = Diplomacy    |           [ = Select All Scouts
          N = Rivalry      |           I = Select Next of Same Type
          H = Lore         |      Delete = Destroy Building
          , = Lore         |

           [SELECT ALL]    | [SELECT ALL EXCEPT ONE]
           Q = Villager    | Space + Q = Villager
           W = Woodcutter  | Space + W = Woodcutter

                       [SCRIPT]
         F1 = Show Help 1  |         F11 =  Reload Script
 Shift + F1 = Show Help 2  | LeftAlt + Z =  Reload Script
        F10 = Show Help 1  | LeftAlt + X =    Exit Script
Shift + F10 = Show Help 2  | LeftAlt + C = Suspend Script

                        [DEBUG]
  Ctrl + F1 = Show 'ImageSearch' and 'PixelGetColor' Areas
Shift + F11 = Toggle Send Mode

              [MILITARY FORMATION HELPER]
'Military Formation Helper' has two modes: 3 units (default) or 4 units:
    3 units moves three unit's type: 'Shield', 'Warrior', 'Axe'.
    4 units moves  four unit's type: 'WarChief', 'Shield', 'Warrior', 'Axe'.
I can't detect Warchief presence in game. So if you use 4 units mode, but
you don't have 'WarChief', no units will be send to start dot.

'WarChief' means all units, that are assigned to in-game '1' hotkey.
Select Warchief, bear, any big units and press [Ctrl + 1].
Toggle to 4 units mode via hotkey (see below). Draw formation with 'WarChief'.

         J + AppsKey = Toggle Mode: 3 units or 4 units
AppsKey + RMB + Drag = Make Military Formation
)"

;-------------------------------------------------------------
;--------------------- CIVILIAN VARIABLE ---------------------
;-------------------------------------------------------------

; Start game not in fullscreen to proper show help picture by [F1, Shift+F1] or [F10, Shift+F10]

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

; Click and hold [modifierKey & RightMouseButton], where you want place head of formation and drag where you want place end of formation.
; Release [RightMouseButton]. Your units will go on places, marked by yellow dots.
; Release [modifierKey] before release [RightMouseButton] will cancel formation mode.
; Dots - points on screen, where each type of military units will be send.
; Dots - points on screen, where GUI window (circle) will be shown to help user see future unit's positions.
global period := 100 ; period of calculation dots positions
global idWarChief := "WarChief" ; can be any word or even number, script uses it like ID
global idShield  := "NorthgardShieldBearer.png" ; file name of search picture of unit's icon
global idWarrior := "NorthgardWarrior.png"      ; file name of search picture of unit's icon
global idAxe     := "NorthgardAxeThrower.png"   ; file name of search picture of unit's icon
; Distance between units (unit order are set in unitOrder[] array)
; 0 - position will be on start point (if scale is 1)
; 1 - position will be on end point (if scale is 1)
; unitDistN - N is number of units and dots
; I don't know how to select WarChief (different icons for different clans and additional units like bear), so...
; I use settings for 3 and 4 unit's type.
; With 3 unit's types script select military units via their icons in "Warband" menu on the right side of screen.
; With 4 unit's types we need assign WarChief to hotkey "1" (use in-game hotkey "Ctrl+1"), so WarChief will be selectable via in-game hotkey.
global unitDist  := {} ; we will assign our 3 or 4 settings to this variables
global unitOrder := {} ; we will assign our 3 or 4 settings to this variables
global unitDist3  := [0, 1/2, 1] ; length of this array must be in sync with unitOrder[] array length
global unitOrder3 := [idShield, idWarrior, idAxe]
global unitDist4  := [0, 1/3, 2/3, 1]
global unitOrder4 := [idWarChief, idShield, idWarrior, idAxe]
ToggleWarChief() ; initialize unitDist[] and unitOrder[] values, check for loosing sync in unitOrder[] and unitDist[] arrays
global scale := 1 ; Scale all distances in unitDist[] (each value is multiply by [scale]): <1 less sensitive, ==1 linear, >1 more sensitive.
global d := 20 ; gui dot diameter
global r := d // 2 ; gui dot radius
global dotNum := unitDist.Length() ; number of dots
global dotX := [] ; coordinates of dots
global dotY := [] ; coordinates of dots
global dotColor := "Lime" ; [HTML color names] in AutoHotKey.chm
global x0, y0 ; Start point - coordinates of mouse, when you click [modifierKey & RightMouseButton].
global x1, y1 ; End point - current mouse coordinates (when you drag mouse after click).
global hypotenuse ; distance between Start point and End point

;   x
; ------*x1,y1
; |    /
; |   /
;y|  /hypotenuse
; | /
; |/ <-- A angle
; * x0,y0

CreateDots()

;-------------------------------------------------------------
;--------------------- MILITARY HOTKEYS ----------------------
;-------------------------------------------------------------

#IfWinActive ahk_group Game
; Modifier key ("AppsKey" in this hotkey) of RButton (RightMouseButton) must be in sync with [modifierKey] variable
; It implements "cancel formation" logic in CalculateDots() when user release [modifierKey]
global modifierKey := "AppsKey"
AppsKey & RButton::DragBegin()
AppsKey & RButton Up::DragEnd()
J & AppsKey::ToggleWarChief()

;-------------------------------------------------------------
;---------------------- GENERAL HOTKEYS ----------------------
;-------------------------------------------------------------

#If
F1::ShowHelpImage("NorthgardHotKeys.png")
+F1::ShowHelpText(helpText)
^F1::ShowImageSearchPixelAreas(coords)
<!z::Reload
<!x::ExitApp
<!c::Suspend

#IfWinActive ahk_group Game

F10::ShowHelpImage("NorthgardHotKeys.png")
+F10::ShowHelpText(helpText)
F11::Reload
+F11::ToggleSendMode()

;-------------------------------------------------------------
;--------------------- CIVILIAN HOTKEYS ----------------------
;-------------------------------------------------------------

;---------------------------------------
; REMAP DEFAULT HOTKEYS
; CAMERA
O::   SendInput {w down}
O Up::SendInput {w up}
K::   SendInput {a down}
K Up::SendInput {a up}
L::   SendInput {s down}
L Up::SendInput {s up}
SC027::   SendInput {d down} ; [;]
SC027 Up::SendInput {d up}
;---------------------------------------
J::Send("b") ; BUILD
;---------------------------------------
P::Send("e")     ; SELECT WARBAND
-::Send("u")     ; SELECT IDLE WORKERS
SC028::Send("g") ; SELECT ALL VILLAGERS
[::Send("h")     ; SELECT ALL SCOUTS
I::Send("Tab")   ; SELECT NEXT OF SAME TYPE
;---------------------------------------
U::Send("x") ; CANCEL ORDER
;---------------------------------------
=::Send("p") ; PAUSE
;---------------------------------------
B::Send("k") ; DIPLOMACY
N::Send("n") ; RIVALRY
H::Send("l") ; LORE
,::Send("l") ; LORE
;---------------------------------------
Space::Send("Space")
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
J & K::Build(colThree, rowVillage)     ; HEALER'S HUT
J & L::Build(colFour, rowVillage)      ; BREWERY
J & SC027::Build(colThree, rowProdOne) ; CARVED STONE [;]
J & SC028::Build(colFour, rowProdOne)  ; FORGE [']


; PRODUCTION BASED ON H
H & O::Build(colOne, rowProdOne)       ; WOODCUTTER'S LODGE
H & P::Build(colTwo, rowProdOne)       ; MINE
H & K::Build(colOne, rowProdTwo)       ; FISHERMAN'S HUT
H & L::Build(colTwo, rowProdTwo)       ; HUNTER'S LODGE
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
		Send("b")
	Click(x, y)
	MouseMove, %_x%, %_y%
}

IsBuildingMenuOpen()
{
	targetColor := 0x5D6677 ; color of building menu boundary
	; Check three points to be sure, that building menu opened
	PixelGetColor, color1, 1658, 350, RGB ; IsBuildingMenuOpen
	PixelGetColor, color2, 1658, 400, RGB ; IsBuildingMenuOpen
	PixelGetColor, color3, 1658, 450, RGB ; IsBuildingMenuOpen
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
	; four "Militia" units, you can receive some unique mystic units, etc.
	; Check if Axe icon of Warband on it's place
	PixelGetColor, color, 1674, 727, RGB ; FixBuildingMenuPosition, AxeIcon
	if (color != 0xA4B5C1)
		y := y - 50 ; Axe icon not there, Warband menu is taller, fix position
	return y
}

; Pixel based function, don't cover all buildings
/*
DestroyBuilding()
{
	; Building's info window has several sizes. In most cases "Destroy Building"
	; button overlaps in different size info windows (except "Marketplace").
	; Y = 902 is optimal coordinate to click overlapped button's region.
	MouseGetPos, _x, _y
	Click(1200, 902) ; "Destroy Building" [Fire button] except "Marketplace"
	Sleep, 50
	Click(855, 560) ; Confirm [OK button]
	MouseMove, %_x%, %_y%
}
*/

; Image based function, cover all buildings
DestroyBuilding()
{
	MouseGetPos, _x, _y
	ImageSearch, x, y, 1185, 860, 1220, 930, NorthgardDestroy.png ; DestroyBuilding
	if (ErrorLevel) {
		if (isDebug) {
			ToolTip, %A_ThisFunc%(NorthgardDestroy.png) - can't find image., 0, 0
			SoundBeep
		}
		return
	}
	Click(x, y)
	Sleep, 50
	Click(855, 560) ; Confirm [OK button]
	MouseMove, %_x%, %_y%
}

SelectAllCivUnits(unit)
{
	; Search unit icon on Civilians menu
	ImageSearch, x, y, 1665, 830, 1895, 970, %unit% ; SelectAllCivUnits
	if (ErrorLevel) {
		if (isDebug) {
			ToolTip, %A_ThisFunc%(%unit%) - can't find unit's image., 0, 0
			SoundBeep
		}
		return
	}
	MouseGetPos, _x, _y
	Click(x, y, "Right")
	Sleep, 50
	MouseMove, %_x%, %_y%
}

SelectAllCivUnitsExceptOne(unit)
{
	SelectAllCivUnits(unit)
	Sleep, 50 ; wait for bottom menu with selected units
	; Search first unit icon in first column of selected units (central bottom menu)
	ImageSearch, x, y, 860, 890, 895, 1045, %unit% ; DeselectOneUnit
	if (ErrorLevel) {
		if (isDebug) {
			ToolTip, %A_ThisFunc%(%unit%) - can't find unit's image., 0, 0
			SoundBeep
		}
		return
	}
	MouseGetPos, _x, _y
	SendRaw("{Shift down}")
	Click(x, y)
	Sleep, 50
	SendRaw("{Shift up}")
	MouseMove, %_x%, %_y%
}

;-------------------------------------------------------------
;------------------ MILITARY FORMATION CODE ------------------
;-------------------------------------------------------------

SelectAllMilUnits(unit)
{
	if (unit == idWarChief) {
		Send("1")
	} else {
		; Search unit icon on Warband menu
		ImageSearch, x, y, 1665, 695, 1895, 790, %unit% ; SelectAllMilUnits
		if (ErrorLevel) {
			if (isDebug) {
				; In this function it is normal logic, when [ImageSearch] didn't find unit's image.
				; So comment this [ToolTip], script will be not reliable with it.
				ToolTip, %A_ThisFunc%(%unit%) - can't find unit's image., 0, 0
				SoundBeep
			}
			return false
		}
		Click(x, y, "Right")
	}
	return true
}

DragBegin()
{
	MouseGetPos, x0, y0
	ShowDot(1, x0, y0)
	SetTimer, CalculateDots, %period%
	CalculateDots() ; don't wait [period], call immediately
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
		; If you use 4 units mode and has selected WarChief, script will select him again via in-game hotkey "1".
		; This second selection will move camera to WarChief and script moves units in wrong positions.
		; Select all warband to prevent camera movement.
		Send("e")
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
		; After last military unit move deselect them. [BEFORE] I send "Esc", but if user try make military formation,
		; but he hasn't any military units it will bring game's menu. [NOW] Select all warband.
		Send("e")
		BlockInput Off
		; Send {%modifierKey% Up} ; Possibly prevents "stuck down" modifier key (read BlockInput in AutoHotKey.chm).
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
			Click(x, y, "Right")
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
	CreateMouseClickTransGui("Dot" . id, dotColor)
	Gui, Dot%id%: Margin, 0, 0
	WinSet, Region, 0-0 W%d% H%d% E
}

CreateDots()
{
	Loop, % dotNum
		CreateDot(A_Index) ; create outside of screen
}

ShowDot(id, x, y)
{
	Gui, Dot%id%: Show, % "W"d " H"d " X" (x - r) " Y" (y - r) " NoActivate"
}

ShowDots()
{
	Loop, % dotNum
		ShowDot(A_Index, dotX[A_Index], dotY[A_Index])
}

HideDot(id)
{
	Gui, Dot%id%: Hide
}

HideDots()
{
	Loop, % dotNum
		HideDot(A_Index)
}

DestroyDot(id)
{
	Gui, Dot%id%: Destroy
}

DestroyDots()
{
	Loop, % dotNum
		DestroyDot(A_Index)
}

; Assign relevant unitDist[] and unitOrder[] values
ToggleWarChief()
{
	static toggle
	if (toggle := !toggle) {
		unitDist := unitDist3
		unitOrder := unitOrder3
	} else {
		unitDist := unitDist4
		unitOrder := unitOrder4
	}
	CheckMilitarySettings()
	DestroyDots() ; uses old value of [dotNum]
	dotNum := unitDist.Length()
	CreateDots() ; uses new value of [dotNum]
}

;-------------------------------------------------------------
;---------------------- RECTANGLE CODE -----------------------
;-------------------------------------------------------------

; How to use:
; * Parse script to find [ImageSearch] rectangles and [PixelGetColor] pixels with explicit parameters
;   (hardcoded numbers).
;		coords := ParseImageSearchPixelScript()
; * If parameters are implicit ([ImageSearch] or [PixelGetColor] are inside some function and parameters
;   for them passed as variables) register rectangle or pixel manually, for example before actual func call.
;		RegisterRectangleToShow(coords, A_LineNumber, "comment", varX, varY) ; adds objects to [coords] variable
;		GetSomePixelColor(color, varX, varY) ; any func
; * Draw rectangles.
;		DrawRectangles(coords)
; * Destroy rectangles.
;		DestroyRectangles(coords)
; ! Rectangle consist of four lines. Each line is [Gui] window. Create all lines (not visible) for
;   all rectangles. Show all lines. Destroy all lines.

CreateMouseClickTransGui(id, color := "")
{
	; Gui, GuiName:New [, Options, Title]
	; If [GuiName] is specified, a new GUI will be created, destroying any existing GUI with that name.
	; Otherwise, a new unnamed and unnumbered GUI will be created.
	; Calling [Gui, New] ensures that the script is creating a new GUI, not modifying an existing one.
	; +E0x20 makes GUI mouse-click transparent.
	Gui, %id%: New, -Caption -SysMenu +AlwaysOnTop +LastFound +ToolWindow +E0x20
	Gui, %id%: Color, % color
	WinSet, TransColor, 500 ; This line is necessary to working +E0x20 !!!! Very complicated theme.
}

CreateRectangleLines(id) {
	Loop, 4
		CreateMouseClickTransGui("Rect" . A_Index . id, "Red")
}

DrawRectangle(id, coord)
{
	Gui, Rect1%id%: Show, % "x" coord.X1 " y" coord.Y1 " w" coord.X2 - coord.X1 " h1 NoActivate"
	Gui, Rect4%id%: Show, % "x" coord.X1 " y" coord.Y2 " w" coord.X2 - coord.X1 " h1 NoActivate"

	Gui, Rect2%id%: Show, % "x" coord.X1 " y" coord.Y1 " w1 h" coord.Y2 - coord.Y1 " NoActivate"
	Gui, Rect3%id%: Show, % "x" coord.X2 " y" coord.Y1 " w1 h" coord.Y2 - coord.Y1 " NoActivate"

	; First [ToolTip] window is used for debug messages, start from second window. Max is 20 windows.
	ToolTip, % "Line " coord.lineNumber ": " coord.comment, % coord.X1, % coord.Y2, % id + 1
}

DrawRectangles(coords)
{
	for id, coord in coords {
		CreateRectangleLines(id)
		DrawRectangle(id, coord)
	}
}

DestroyRectangles(coords)
{
	for id, coord in coords {
		Loop, 4
			Gui, Rect%A_Index%%id%: Destroy
		ToolTip, , , , % id + 1
	}
}

ParseImageSearchPixelScript()
{
	coords := {} ; All found coordinates in script
	; Sync radius value with [RegisterRectangleToShow()]
	r := 2 ; Radius around pixel in [PixelGetColor] to show it on screen
	Loop, Read, % A_ScriptName
	{
		line := Trim(A_LoopReadLine)

		if (SubStr(line, 1, 1) == ";") ; skip comments
			continue

		; ImageSearch, x, y, (1185), (860), (1220), (930), (NorthgardDestroy.png) ; (comment)
		;                    match1 match2  match3 match4                  match5     match6
		c := {} ; Coordinates of search area rectangle
		if (RegExMatch(A_LoopReadLine, "ImageSearch\s*,.+?,.+?,\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*([^;]+)\s*;?\s*(.*)?", match)) {
			c.X1 := match1
			c.Y1 := match2
			c.X2 := match3
			c.Y2 := match4
			c.lineNumber := A_Index
			c.comment := match6
			coords.Push(c)
			continue
		}

		; PixelGetColor, color, (1658), (400), RGB ; (comment)
		;                       match1 match2           match3
		if (RegExMatch(A_LoopReadLine, "PixelGetColor\s*,.+?,\s*(\d+)\s*,\s*(\d+)\s*,?[^;]*;?\s*(.*)?", match)) {
			c.X1 := match1 - r
			c.Y1 := match2 - r
			c.X2 := match1 + r
			c.Y2 := match2 + r
			c.lineNumber := A_Index
			c.comment := match3
			coords.Push(c)
			continue
		}
	}
	return coords
}
/*
	; Test strings for RegExMatch() above in ParseImageSearchPixelScript()
	;; PixelGetColor, color1, 20, 20, RGB ; Must be not visible comment
	; PixelGetColor, color1, 20, 60, RGB ; comment
	; PixelGetColor, color2, 20, 100, RGB
	; PixelGetColor, color3, 20, 140 ; comment
	; PixelGetColor, color3, 20, 180
	; ImageSearch, x, y, 200, 60, 240, 100, NorthgardDestroy.png ; DestroyBuilding
	; ImageSearch, x, y, 200, 140, 240, 180, NorthgardDestroy.png
*/

RegisterRectangleToShow(ByRef coords, lineNumber, comment, x1, y1, x2 := "", y2 := "")
{
	c := {}
	; Sync radius value with [ParseImageSearchPixelScript()]
	r := 2 ; Radius around pixel in [PixelGetColor] to show it on screen
	if (x2 == "" and y2 == "") {
		c.X1 := x1 - r
		c.Y1 := y1 - r
		c.X2 := x1 + r
		c.Y2 := y1 + r
	} else {
		c.X1 := x1
		c.Y1 := y1
		c.X2 := x2
		c.Y2 := y2
	}
	c.lineNumber := lineNumber
	c.comment := comment
	coords.Push(c)
}

ShowImageSearchPixelAreas(coords)
{
	static toggle
	if (toggle := !toggle)
		DrawRectangles(coords)
	else
		DestroyRectangles(coords)
}

;-------------------------------------------------------------
;----------------------- GENERAL CODE ------------------------
;-------------------------------------------------------------

CheckMilitarySettings()
{
	err := ""
	if (unitDist.Length() != unitOrder.Length())
		err .= A_Tab . "unitDist.Length() != unitOrder.Length()`n"
	if (unitDist3.Length() != unitOrder3.Length())
		err .= A_Tab . "unitDist3.Length() != unitOrder3.Length()`n"
	if (unitDist4.Length() != unitOrder4.Length())
		err .= A_Tab . "unitDist4.Length() != unitOrder4.Length()`n"
	if (err) {
		str := "Error in military params:`n"
		str .= err
		str .= "Look at comments above [unitDist] and [unitOrder] declaration"
		MsgBox % str
	}
}

; ShowHelpImage(imageFile)
; {
; 	static toggle
; 	if (toggle := !toggle)
; 		SplashImage, % imageFile, B
; 	else
; 		SplashImage, OFF
; }

ShowHelpImage(imageFile)
{
	static toggle
	if (toggle := !toggle) {
		CreateMouseClickTransGui("HelpImage")
		Gui, HelpImage: Add, Picture, , % imageFile
		Gui, HelpImage: Show, NoActivate
	}
	else
		Gui, HelpImage: Destroy
}

ShowHelpText(text)
{
	static toggle
	if (toggle := !toggle) {
		CreateMouseClickTransGui("HelpText")
		Gui, HelpText: Font, s14, Consolas
		Gui, HelpText: Add, Text, , % text
		Gui, HelpText: Show, NoActivate
	}
	else
		Gui, HelpText: Destroy
}

Send(key)
{
	if (bSendInput) {
		SendInput, {%key% down}
		if (SendInputPressDuration != -1)
			Sleep, %SendInputPressDuration%
		SendInput, {%key% up}
		if (SendInputDelay != -1)
			Sleep, %SendInputDelay%
	} else {
		SendEvent, {%key%}
	}
}

SendRaw(string)
{
	if (bSendInput)
		SendInput, %string%
	else
		SendEvent, %string%
}

Click(x := "", y := "", WhichButton := "")
{
	if (bSendInput)
		SendInput, {Click %x% %y% %WhichButton%}
	else
		SendEvent, {Click %x% %y% %WhichButton%}
}

ToggleSendMode()
{
	SoundBeep
	bSendInput := !bSendInput
	if (bSendInput)
		ToolTip, SendMode: Input, 0, 0
	else
		ToolTip, SendMode: Event, 0, 0
	Sleep, 1000
	ToolTip
}

IsDebugScript() {
	FullCmdLine := DllCall("GetCommandLine", "Str")
	if(RegExMatch(FullCmdLine, "i)/debug"))
		return true
	else
		return false
}
