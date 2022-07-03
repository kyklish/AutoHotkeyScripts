#Include <_COMMON_SETTINGS_>

Menu, Tray, Icon

AC := "AssettoCorsa (vFOV°)"
rF2 := "rFactor (1 + 2), GSC, GSCE, SCE, AMS (vFOV°)"
pCARS := "Project CARS (hFOV°)"
RRRE := "RaceRoom Racing Experience (vFOVx)"
Race07 := "Race 07, GTR Evo (vFOV%)"
GAS := "GRID Autosport, DiRT Rally (vFOV° x2)"
GTR2 := "GTR2 (vFOVx)"
RBR := "Richard Burns Rally (hFOVrad)"

pi := 3.141592653589793

monSize := 27
distToMon := 27

;-------------------------------------------------
Gui -MaximizeBox
Gui Font, , Fixedsys
Gui Add, Text, w80 +Center, # Monitors
Gui Add, DropDownList, wp vMonQty gUpdate, Single||Triple
Gui Add, Text, ym wp +Center, Ratio
Gui Add, DropDownList, wp vMonRatio gUpdate, 16:9||16:10|21:9|5:4|4:3|32:9
Gui Add, Text, ym wp +Center, Units
Gui Add, DropDownList, wp vDistUnit gUpdate, inches||cm
Gui Add, Text, xm y+15 +Center, Select Game
Gui Add, DropDownList, w380 vGame gUpdate, %AC%||%rF2%|%pCARS%|%RRRE%|%Race07%|%GAS%|%GTR2%|%RBR%
Gui Add, Text, y+15 section, FOV:
Gui Add, Text, ys w360 r2 HwndOutputHwnd

Gui Show, , fovCalc

Gosub, Update
Return

GuiEscape:
GuiClose:
!x::ExitApp
!z::Reload
;-------------------------------------------------



Update:
;Here hidden semantics!!! Only this order needed.
GetGuiData()
CalcScreenSize()
CalcFOV()
ShowResultText(OutputHwnd)
return

GetGuiData() {
	global
	Gui Submit, NoHide
	
	if (monQty == "Single")
		monQty := 1
	else if (monQty == "Triple")
		monQty := 3
	
	if (distUnit == "inches")
		unit := """"
	else if (distUnit == "cm")
		unit := "cm"
}

ShowResultText(ControlHwnd)
{
	global
	fovTypeLabel := "FOV Type, Unit: " . fovType
	;ControlSetText, , % fov " " fovType, ahk_id %ControlHwnd%
	ControlSetText, , % fov " " fovType "`r`n" game, ahk_id %ControlHwnd%
}

DistInUnit(distToMon, unit)
{
	if (unit == "cm") ; convert to inches
		distToMon := Round(distToMon * 2.54)
	return distToMon
}

CalcScreenSize()
{
	global
	local size := StrSplit(monRatio, ":")
	ratioMultiplier := size[2] / size[1]
	screenWidth := Cos(ATan(ratioMultiplier)) * monSize
	screenHeight := Sin(ATan(ratioMultiplier)) * monSize
}

LimitFOV(fovAngle, minFOV, maxFOV)
{
	if (fovAngle < minFOV)
		fovAngle := minFOV
	if (fovAngle > maxFOV)
		fovAngle := maxFOV
	return fovAngle
}

CalcFOV()
{
	global
	local calc
	if (game == pCARS || game == RBR)
		calc := screenWidth
	else
		calc := screenHeight
	angleRad := ATan(calc / 2 / DistInUnit(distToMon, unit)) * 2
	fovAngle := angleRad * 180 / pi
	if (game == rF2) {
		fovType := "Vertical, Degrees."
		fovAngle := LimitFOV(fovAngle, 10, 100)
		fovAngle := Round(fovAngle)
	} else if (game == AC) {
		fovType := "Vertical, Degrees."
		fovAngle := LimitFOV(fovAngle, 10, 120)
		fovAngle := Round(fovAngle)
	}
	fov := fovAngle . "° (vFOV)"
	if (game == pCARS) {
		fovType := "Horizontal, Degrees."
		fovAngle := fovAngle * monQty
		fovAngle := LimitFOV(fovAngle, 35, 180)
		fov := Round(fovAngle) . "° (hFOV)"
	} else if (game == RBR) {
		fovType := "Horizontal, Radians."
		fovAngle := fovAngle * monQty
		fovAngle := LimitFOV(fovAngle, 10, 180)
		radAngle := fovAngle * (pi / 180)
		fov := Format("{:.6f}", radAngle) . "rad (hFOVrad)"
	} else if (game == GAS) {
		fovType := "Vertical, Degrees x2."
		fovAngle := LimitFOV(fovAngle, 10, 115)
		fovAngle := Round(fovAngle * 100) / 100
		fov := Round(fovAngle * 2) . "° (vFOV x2)"
	} else if (game == RRRE) {
		fovType := "Vertical, Multiplier of base FOV."
		if (monQty == 3)
			baseFOV := 40
		else
			baseFOV := 58
		fovAngle := LimitFOV(fovAngle, baseFOV * 0.5, baseFOV * 1.3)
		fov := Format("{:.1f}", fovAngle / baseFOV) . "x (vFOV)"
	} else if (game == GTR2) {
		fovType := "Vertical, Multiplier of base FOV."
		local baseFOV := 58
		fovAngle := LimitFOV(fovAngle, baseFOV * 0.5, baseFOV * 1.5)
		fov := Format("{:.1f}", fovAngle / baseFOV) . "x (vFOV)"
	} else if (game == Race07) {
		fovType := "Vertical, Percentage of base FOV."
		local baseFOV := 58
		fovAngle := LimitFOV(fovAngle, baseFOV * 0.4, baseFOV * 1.5)
		fov := Round(fovAngle / baseFOV * 100) . "% (vFOV)"
	}
}
