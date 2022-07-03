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

oDirt_Rally := new Dirt_Series({sName: "DiRT Rally", sGameFolder: "F:\GAMES\DiRT Rally", sCarFolder: "cars\models", sFileName: "cameras.xml"})
oF1_2012 := new F1_Series({sName: "F1 2012", sGameFolder: "F:\GAMES\F1 2012", sCarFolder: "cars", sFileName: "cameras.xml"})
oF1_2013 := new F1_Series({sName: "F1 2013", sGameFolder: "F:\GAMES\F1 2013", sCarFolder: "cars", sFileName: "cameras.xml"})

oGames := {}
oGames[oF1_2012.sName] := oF1_2012
oGames[oF1_2013.sName] := oF1_2013
oGames[oDirt_Rally.sName] := oDirt_Rally

oGUI := {}
oGUI.Push({sName: "FovEdit", sType: "Edit", sValueName: "fFov"})
oGUI.Push({sName: "HeadCheckBox", sType: "CheckBox", sValueName: "sHeadBuffeting", sCheck: "true", sUnCheck: "false"})
oGUI.Push({sName: "ApexEdit", sType: "Edit", sValueName: "fYawLimitInDegrees"})
oGUI.Push({sName: "SaveButton", sType: "Button"})

oMgr := new Manager(oGames, oGUI, oF1_2012.sName)


Gui -MaximizeBox
Gui Add, Text, x8 y8 w81 h25 +0x200, 1. Select game.
Gui Add, DropDownList, x96 y8 w120 vGameDDL, % oMgr.GetDDLText()
Gui Add, Button, x3 y40 w275 h25 vLoadButton Default gLoad, 2. Convert binXML to textXML and save in TEMP folder.
Gui Add, Text, x8 y72 w81 h25 +0x200, 3. Edit cameras.
Gui Add, Edit, x24 y104 w55 h21 vFovEdit Disabled
Gui Add, Text, x88 y104 w209 h21 +0x200, "FOV"
Gui Add, CheckBox, x24 y128 w273 h21 vHeadCheckBox Disabled, "Head Buffeting"
Gui Add, Edit, x24 y152 w55 h21 vApexEdit Disabled
Gui Add, Text, x88 y152 w209 h21 +0x200, "Look to Apex"
Gui Add, Button, x3 y184 w294 h25 vSaveButton Disabled gSave, 4. Convert textXML to binXML and save as Mod for JSGME.

Gui Show, w306 h216, %sWinTitle%
Return

!z::Reload
!x::
GuiEscape:
GuiClose:
ExitApp

Load:
oMgr.Load()
return

Save:
oMgr.Save()
return


class Manager
{
	__New(oGames, oGUI, sDefaultGameName)
	{
		this.oGames := oGames
		this.oGUI := oGUI
		this.sDefaultGameName := sDefaultGameName
	}
	
	GetDDLText()
	{
		for i, oGame in this.oGames
		{
			if (oGame.sName = this.sDefaultGameName) ; make default in DropDownList
				sep := "||"
			else
				sep := "|"
			sDDLText .= oGame.sName . sep
		}
		return sDDLText
	}
	/*
		EnableAllGUI()
		{
			for i, oControl in this.oGUI
				GuiControl, Enable, % oControl.sName
		}
	*/
	DisableAllGUI()
	{
		for i, oControl in this.oGUI
			GuiControl, Disable, % oControl.sName
		this.ResetGUIValue()
	}
	
	ResetGUIValue()
	{
		for i, oControl in this.oGUI
			if (oControl.sType = "Edit")
				GuiControl, , % oControl.sName
		else if (oControl.sType = "CheckBox")
			GuiControl, , % oControl.sName, 0
	}
	
	Load()
	{
		global GameDDL
		Gui, Submit, NoHide
		this.oGame := this.oGames[GameDDL]
		this.DisableAllGUI()
		if !FileExist(this.oGame.sGameFolder)
			MsgBox, Game folder not exist.
		else {
			this.oGame.ConvCamBin2Text()
			this.oGame.ParseCamFile()
			;this.EnableAllGUI()
			this.oGame.UpdateGUI(this.oGUI)
		}
	}
	
	Save()
	{
		Gui, Submit, NoHide
		this.oGame.FormatGUI(this.oGUI)
		this.oGame.ConvCamText2Bin()
		MsgBox, , Move Files, Done, 1
	}
}


class All_Games
{
	 ; search only in HEAD cameras
	 ; \K causes any previously-matched characters to be omitted from the final matched string
	;static sCommonBeginNeedle := "si)<View type=""Head"".*?\K"
	static sCommonBeginNeedle := "si)<View type=""Head"" ident=""head-cam"".*?\K"
	
	__New(oGameParams)
	{
		this.sName := oGameParams.sName
		this.sGameFolder := oGameParams.sGameFolder
		this.sCarFolder := oGameParams.sCarFolder
		this.sFileName := oGameParams.sFileName
		
		this.sTempFolder := A_Temp "\" this.sName
		this.sTempFilePattern := this.sTempFolder "\" this.sCarFolder "\" this.sFileName
		; using relative path without beginning ".\", Loop(Files) will give "nice" folder path.
		this.sFilePattern := this.sCarFolder "\" this.sFileName
	}
	
	ConvCamBin2Text()
	{
		global sBinXmlLongPath
		; we will use relative path, easier coding
		SetWorkingDir % this.sGameFolder
		
		Loop, Files, % this.sFilePattern, R
		{
			sOutputDir := this.sTempFolder "\" A_LoopFileDir
			FileCreateDir % sOutputDir
			RunWait, %sBinXmlLongPath% --textxml "%sOutputDir%\%A_LoopFileName%" "%A_LoopFileLongPath%", , Hide
		} Until A_Index = 2
	}
	
	ConvCamText2Bin()
	{
		return
		global sModsFolderName, FovEdit, HeadCheckBox, ApexEdit
		
		sFileList := ""
		Loop, Files, % this.sTempFilePattern, R
			sFileList .= A_LoopFileLongPath "`n"
		Loop, Parse, % SubStr(sFileList, 1, -StrLen("`n")), `n
		{
			; REFACTOR!!!!!!!!
			FileRead, sData, %A_LoopField%
			
			if (this.sFovRegEx)
				sData := RegExReplace(sData, this.sFovRegEx, Format("{:.4f}", FovEdit))
			if (this.sHeadRegEx)
				sData := RegExReplace(sData, this.sHeadRegEx, HeadCheckBox ? "true" : "false")
			if (this.sApexRegEx)
				sData := RegExReplace(sData, this.sApexRegEx, Format("{:.4f}", ApexEdit))
			
			oFile := FileOpen(A_LoopField, "w")
			oFile.Write(sData)
			oFile.Close()
			
			RunWait, %sBinXmlLongPath% --binxml "%A_LoopField%" "%A_LoopField%", , Hide
		}
		FileMoveDir, % this.sTempFolder, % this.sGameFolder "\" sModsFolderName, 2
	}

	ParseCamFile()
	{
		this.fFov := ""
		this.sHeadBuffeting := ""
		this.fYawLimitInDegrees := ""
		
		Loop, Files, % this.sTempFilePattern, R
			FileRead, sData, %A_LoopFileLongPath%
		Until A_Index == 1
		
		if (this.sFovRegEx) {
			RegExMatch(sData, this.sFovRegEx, result)
			this.fFov := result ; you can't pass this.fFov directly to func as Output Var
		}
		if (this.sHeadRegEx) {
			RegExMatch(sData, this.sHeadRegEx, result)
			this.sHeadBuffeting := result
		}
		if (this.sApexRegEx) {
			RegExMatch(sData, this.sApexRegEx, result)
			this.fYawLimitInDegrees := result
		}
		ToolTip % "FOV = " this.fFov "`nHead = " this.sHeadBuffeting "`nApex = " this.fYawLimitInDegrees
	}
	
	UpdateGUI(oGUI)
	{
		for i, oControl in oGUI
		{
			if (oControl.sType = "Edit") {
				value := this[oControl.sValueName]
				if value is float ; if var is type - not support expressions
				{
					GuiControl, , % oControl.sName, % value
					GuiControl, Enable, % oControl.sName
				}
			}
			else if (oControl.sType = "CheckBox") {
				value := this[oControl.sValueName]
				if (value = oControl.sCheck) {
					GuiControl, , % oControl.sName, 1
					GuiControl, Enable, % oControl.sName
				}
				else if (value = oControl.sUnCheck) {
					GuiControl, , % oControl.sName, 0
					GuiControl, Enable, % oControl.sName
				}
			}
		}
		
		value := this.fFov
		if value is float
			GuiControl, Enable, SaveButton
	}
	
	FormatGUI(oGUI)
	{
		for i, oControl in oGUI
			if (oControl.sType = "Edit") {
				value := oControl.sName
				GuiControl, , % oControl.sName, % Format("{:.4f}", %value%)
			}
	}
}


class F1_Series extends All_Games
{
	static sFovRegEx  := All_Games.sCommonBeginNeedle "(?<=<Parameter name=""fov"" type=""scalar"" value="")[^""]+?(?="" />)"
	static sHeadRegEx := All_Games.sCommonBeginNeedle "(?<=<Parameter name=""headBuffeting"" type=""bool"" value="")[^""]+?(?="" />)"
	static sApexRegEx := All_Games.sCommonBeginNeedle "(?<=<Parameter name=""yawLimitInDegrees"" type=""scalar"" value="")[^""]+?(?="" />)"
}


class Dirt_Series extends All_Games
{
	static sFovRegEx := F1_Series.sFovRegEx
}
