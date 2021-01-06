#SingleInstance Force
#NoEnv
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

sWinTitle := "F1 EGO Cameras"
sBinXmlName := "binXml.exe"
sModsFolderName := "MODS\BenQ Custom Camera"

if (!FileExist(sBinXmlName)) {
	MsgBox, 16, , %sBinXmlName% converter not found.
	ExitApp
}
Loop, Files, % sBinXmlName
	sBinXmlLongPath := A_LoopFileLongPath

oF1_2012 := {name: "F1 2012", gameFolder: "F:\GAMES\F1 2012", carFolder: "cars", fileName: "cameras.xml"}
oF1_2013 := {name: "F1 2013", gameFolder: "F:\GAMES\F1 2013", carFolder: "cars", fileName: "cameras.xml"}
oGames := {oF1_2012.name: oF1_2012, oF1_2013.name: oF1_2013}
for key in oGames
{
	if (key == oF1_2012.name) ; make default in DropDownList
		sep := "||"
	else
		sep := "|"
	sDDLText .= key . sep
}

Gui -MaximizeBox
Gui Add, Text, x8 y8 w81 h25 +0x200, 1. Select game.
Gui Add, DropDownList, x96 y8 w120 vsGame, %sDDLText%
Gui Add, Button, x3 y40 w155 h25 vLoadButton Default gLoad, 2. Convert binXML to textXML.
Gui Add, Text, x8 y72 w81 h25 +0x200, 3. Edit cameras.
Gui Add, Text, x24 y104 w33 h21 +0x200, FOV:
Gui Add, Edit, x64 y104 w55 h21 vFovEdit Disabled
Gui Add, CheckBox, x24 y128 w150 h23 vHeadCheckBox Disabled, Disable "Head Buffeting".
Gui Add, CheckBox, x24 y152 w150 h23 vApexCheckBox Disabled, Set to zero "Look to Apex".
Gui Add, Button, x3 y184 w296 h25 vSaveButton Disabled gSave, 4. Convert textXML to binXML and save as Mod for JSGME.

Gui Show, w304 h216, %sWinTitle%
Return

!z::Reload
!x::
GuiEscape:
GuiClose:
ExitApp

Load:
Gui, Submit, NoHide
oGame := oGames[sGame]
if !FileExist(oGame.gameFolder) {
	MsgBox, Game not installed.
	GuiControl, Disable, FovEdit
	GuiControl, Disable, HeadCheckBox
	GuiControl, Disable, ApexCheckBox
	GuiControl, Disable, SaveButton
	GuiControl, , FovEdit
	GuiControl, , HeadCheckBox, 0
	GuiControl, , ApexCheckBox, 0
	WinSetTitle, A, , %sWinTitle%
	return
}
;--------------------------------------------------------------------
;Convert files
SetWorkingDir % oGame.gameFolder
sTempFolder := A_Temp "\" oGame.name
sTempFilePattern := sTempFolder "\" oGame.carFolder "\" oGame.fileName
sFilePattern := oGame.carFolder "\" oGame.fileName
Loop, Files, %sFilePattern%, R
{
	sOutputDir := sTempFolder "\" A_LoopFileDir
	FileCreateDir % sOutputDir
	RunWait, %sBinXmlLongPath% --textxml "%sOutputDir%\%A_LoopFileName%" "%A_LoopFileLongPath%", , Hide
}
;--------------------------------------------------------------------
;Scan one file
Loop, Files, %sTempFilePattern%, R
	FileRead, sData, %A_LoopFileLongPath%
Until A_Index == 1
; Legacy assign to avoid problems with quotes
sCommonBeginNeedle = si)<View type="Head".*?\K ; search only in HEAD cameras; \K causes any previously-matched characters to be omitted from the final matched string
sFOVRegEx  = %sCommonBeginNeedle%(?<=<Parameter name="fov" type="scalar" value=")[^"]+?(?=" />)
sHeadRegEx = %sCommonBeginNeedle%(?<=<Parameter name="headBuffeting" type="bool" value=")[^"]+?(?=" />)
sApexRegEx = %sCommonBeginNeedle%(?<=<Parameter name="yawLimitInDegrees" type="scalar" value=")[^"]+?(?=" />)
RegExMatch(sData, sFovRegEx,  fFov)
RegExMatch(sData, sHeadRegEx, sHeadBuffeting)
RegExMatch(sData, sApexRegEx, fYawLimitInDegrees)
;ToolTip % "FOV = " fFov "`nHead = " sHeadBuffeting "`nApex = " sYawLimitInDegrees
;--------------------------------------------------------------------
;Update GUI
GuiControl, Enable, FovEdit
GuiControl, Enable, HeadCheckBox
GuiControl, Enable, ApexCheckBox

if fFov is float
{
	GuiControl, , FovEdit, %fFov%
	GuiControl, Enable, SaveButton
}
else
	GuiControl, Disable, FovEdit

if (sHeadBuffeting = "true")
	GuiControl, , HeadCheckBox, 0
else if (sHeadBuffeting = "false")
	GuiControl, , HeadCheckBox, 1
else
	GuiControl, Disable, HeadCheckBox

if (fYawLimitInDegrees == 0)
	GuiControl, , ApexCheckBox, 1
else if fYawLimitInDegrees is float
	GuiControl, , ApexCheckBox, 0
else
	GuiControl, Disable, ApexCheckBox

WinSetTitle, A, , Look to Apex = %fYawLimitInDegrees%
return


Save:
Gui, Submit, NoHide
GuiControl, , FovEdit, % Format("{:.4f}", FovEdit)
sFileList := ""
Loop, Files, %sTempFilePattern%, R
	sFileList .= A_LoopFileLongPath "`n"
Loop, Parse, % SubStr(sFileList, 1, -1), `n
{
	FileRead, sData, %A_LoopField%
	sData := RegExReplace(sData, sFovRegEx, Format("{:.4f}", FovEdit))
	sReplace := HeadCheckBox ? "false" : "true"
	sData := RegExReplace(sData, sHeadRegEx, sReplace)
	sReplace := ApexCheckBox ? "0" : "10"
	sData := RegExReplace(sData, sApexRegEx, Format("{:.4f}", sReplace))
	oFile := FileOpen(A_LoopField, "w")
	oFile.Write(sData)
	oFile.Close()
	RunWait, %sBinXmlLongPath% --binxml "%A_LoopField%" "%A_LoopField%", , Hide
}
FileMoveDir, %sTempFolder%, % oGame.gameFolder "\" sModsFolderName, 2
MsgBox, , Move Files, Done, 1
return