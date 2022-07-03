#SingleInstance Force
#NoEnv
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

bIsDebug := true

sWinTitle := "F1 EGO Cameras"
sBinXmlName := "binXml.exe"
sModsFolderName := "MODS\BenQ Custom Camera"

if (!FileExist(sBinXmlName)) {
	MsgBox, 16, , %sBinXmlName% converter not found.
	ExitApp
}
Loop, Files, % sBinXmlName
	sBinXmlLongPath := A_LoopFileLongPath

oMgr := ManagerFactory()


Gui -MaximizeBox
Gui Add, Text, x8 y8 w81 h25 +0x200, 1. Select game.
Gui Add, DropDownList, x96 y8 w120 vGameDDL gNewGameSelected, % oMgr.GetDDLText()
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

NewGameSelected:
oMgr.DisableAllGUI()
return

class Manager
{
	__New(oGames, sDefaultGameName)
	{
		this.oGames := oGames
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
	
	Load()
	{
		global GameDDL
		Gui, Submit, NoHide
		this.oGame := this.oGames[GameDDL]
		if !FileExist(this.oGame.sGameFolder)
			MsgBox % "Game folder not exist:`n" this.oGame.sGameFolder
		else {
			this.oGame.ConvCamBin2Text()
			this.oGame.UpdateGUI(this.oGUI)
		}
	}
	
	Save()
	{
		Gui, Submit, NoHide
		this.oGame.ConvCamText2Bin()
		MsgBox, , Move Files, Done, 1
	}
	
	DisableAllGUI()
	{
		; Before first calling method "Load" (pressing button "2. Convert binXML to textXML and save in TEMP folder.") all GUI are disabled AND there are no variable "this.oGame".
		; Call method in non-existent object gives nothing, no error, etc.
		this.oGame.DisableAllGUI()
	}
}


class GameType
{
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
	
	SetParams(oGUI, oRegExs)
	{
		this.oGUI := oGUI
		this.oRegExs := oRegExs
		return this
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
		}
	}
	
	ConvCamText2Bin()
	{
		global sModsFolderName, sBinXmlLongPath
		
		sFileList := ""
		Loop, Files, % this.sTempFilePattern, R
			sFileList .= A_LoopFileLongPath "`n"
		Loop, Parse, % SubStr(sFileList, 1, -StrLen("`n")), `n
		{
			FileRead, sData, %A_LoopField%
			
			for i, oRegEx in this.oRegExs
				oRegEx.Replace(sData)
			
			oFile := FileOpen(A_LoopField, "w")
			oFile.Write(sData)
			oFile.Close()
			
			RunWait, %sBinXmlLongPath% --binxml "%A_LoopField%" "%A_LoopField%", , Hide
		}
		FileMoveDir, % this.sTempFolder, % this.sGameFolder "\" sModsFolderName, 2
		this.DisableAllGUI()
	}
	
	UpdateGUI()
	{
		Loop, Files, % this.sTempFilePattern, R
			FileRead, sData, %A_LoopFileLongPath%
		Until A_Index == 1 ; Read first file
		
		for i, oControl in this.oGUI
			oControl.Update(sData)
	}
	
	DisableAllGUI()
	{
		for i, oControl in this.oGUI
			oControl.Disable()
	}
}


ManagerFactory()
{
	; search only in HEAD cameras
	; \K causes any previously-matched characters to be omitted from the final matched string
	;sCommonBeginNeedle := "si)<View type=""Head"".*?\K"
	sCommonBeginNeedle := "si)<View type=""Head"" ident=""head-cam"".*?\K"
	oFovRegEx  := new RegExType(sCommonBeginNeedle "(?<=<Parameter name=""fov"" type=""scalar"" value="")[^""]+?(?="" />)")
	oHeadRegEx := new RegExType(sCommonBeginNeedle "(?<=<Parameter name=""headBuffeting"" type=""bool"" value="")[^""]+?(?="" />)")
	oApexRegEx := new RegExType(sCommonBeginNeedle "(?<=<Parameter name=""yawLimitInDegrees"" type=""scalar"" value="")[^""]+?(?="" />)")
	
	oGUI_F1 := []
	oGUI_F1.Push(oFovEdit := new ControlEdit(oFovRegEx, "FovEdit"))
	oGUI_F1.Push(oHeadCheckBox := new ControlCheckbox(oHeadRegEx, "HeadCheckBox", "true", "false"))
	oGUI_F1.Push(oApexEdit := new ControlEdit(oApexRegEx, "ApexEdit"))
	oGUI_F1.Push(oSaveButton := new ControlButton(oFovRegEx, "SaveButton"))
	
	oRegExs := []
	oRegExs.Push(oFovRegEx.SetGui(oFovEdit))
	oRegExs.Push(oHeadRegEx.SetGui(oHeadCheckBox))
	oRegExs.Push(oApexRegEx.SetGui(oApexEdit))
	
	oDirt_Rally := new GameType({sName: "DiRT Rally", sGameFolder: "F:\GAMES\DiRT Rally", sCarFolder: "cars\models", sFileName: "cameras.xml"})
	oF1_2012 := new GameType({sName: "F1 2012", sGameFolder: "F:\GAMES\F1 2012", sCarFolder: "cars", sFileName: "cameras.xml"})
	oF1_2013 := new GameType({sName: "F1 2013", sGameFolder: "F:\GAMES\F1 2013", sCarFolder: "cars", sFileName: "cameras.xml"})
	oF1_2014 := new GameType({sName: "F1 2014", sGameFolder: "F:\GAMES\F1 2014", sCarFolder: "cars", sFileName: "cameras.xml"})
	;oF1_2015 := new GameType({sName: "F1 2015", sGameFolder: "F:\GAMES\F1 2015", sCarFolder: "cars", sFileName: "cameras.xml"})
	;oF1_2016 := new GameType({sName: "F1 2016", sGameFolder: "F:\GAMES\F1 2016", sCarFolder: "cars", sFileName: "cameras.xml"})
	;oF1_2017 := new GameType({sName: "F1 2017", sGameFolder: "F:\GAMES\F1 2017", sCarFolder: "cars", sFileName: "cameras.xml"})
	;oF1_2018 := new GameType({sName: "F1 2018", sGameFolder: "F:\GAMES\F1 2018", sCarFolder: "cars", sFileName: "cameras.xml"})
	
	oGames := {}
	oGames[oF1_2012.sName] := oF1_2012.SetParams(oGUI_F1, oRegExs)
	oGames[oF1_2013.sName] := oF1_2013.SetParams(oGUI_F1, oRegExs)
	oGames[oF1_2014.sName] := oF1_2014.SetParams(oGUI_F1, oRegExs)
	;oGames[oF1_2015.sName] := oF1_2015.SetParams(oGUI_F1, oRegExs)
	;oGames[oF1_2016.sName] := oF1_2016.SetParams(oGUI_F1, oRegExs)
	;oGames[oF1_2017.sName] := oF1_2017.SetParams(oGUI_F1, oRegExs)
	;oGames[oF1_2018.sName] := oF1_2018.SetParams(oGUI_F1, oRegExs)
	oGames[oDirt_Rally.sName] := oDirt_Rally.SetParams([oFovEdit, oSaveButton], [oFovRegEx])
	
	return new Manager(oGames, oF1_2012.sName)
}


class ControlBase
{
	__New(oRegEx, sName)
	{
		this.oRegEx := oRegEx
		this.sName := sName
	}
	
	GetParsedValue(ByRef sData)
	{
		if !this.oRegEx
			MsgBox Assign RegEx to Control!
		value := this.oRegEx.Match(sData)
		this.LogData(value)
		return value
	}
	
	Disable()
	{
		GuiControl, Disable, % this.sName
		this.ResetValue()
	}
	
	LogData(data)
	{
		OutputDebug(this.sName " -> " data)
	}
}


class ControlEdit extends ControlBase
{
	Update(ByRef sData)
	{
		value := this.GetParsedValue(sData)
		if value is float ; if var is type - not support expressions
		{
			GuiControl, , % this.sName, % value
			GuiControl, Enable, % this.sName
		}
	}
	
	GetValue()
	{
		sGuiControlName := this.sName ; Get GuiControl name
		value := Format("{:.4f}", %sGuiControlName%) ; Dereference GuiControl name to it's value
		GuiControl, , % this.sName, % value
		return value
	}
	
	ResetValue()
	{
		GuiControl, , % this.sName
	}
}


class ControlCheckbox extends ControlBase
{
	__New(oRegEx, sName, sCheck, sUnCheck)
	{
		base.__New(oRegEx, sName)
		this.sCheck := sCheck
		this.sUnCheck := sUnCheck
	}
	
	Update(ByRef sData)
	{
		value := this.GetParsedValue(sData)
		if (value = this.sCheck) {
			GuiControl, , % this.sName, 1
			GuiControl, Enable, % this.sName
		}
		else if (value = this.sUnCheck) {
			GuiControl, , % this.sName, 0
			GuiControl, Enable, % this.sName
		}
	}
	
	GetValue()
	{
		sGuiControlName := this.sName ; Get GuiControl name
		value := %sGuiControlName% ; Dereference GuiControl name to it's value
		if value
			return this.sCheck
		else
			return this.sUnCheck
	}
	
	ResetValue()
	{
		GuiControl, , % this.sName, 0
	}
}


class ControlButton extends ControlBase
{
	Update(ByRef sData)
	{
		value := this.GetParsedValue(sData)
		if value is float
			GuiControl, Enable, % this.sName
	}
}


class RegExType
{
	__New(sNeedle)
	{
		this.sNeedle := sNeedle
	}
	
	SetGui(oGui)
	{
		this.oGui := oGui
		return this
	}
	
	Match(ByRef sData)
	{
		RegExMatch(sData, this.sNeedle, result)
		return result
	}
	
	Replace(ByRef sData)
	{
		sData := RegExReplace(sData, this.sNeedle, this.oGui.GetValue())
	}
}


OutputDebug(sText)
{
	global bIsDebug
	if bIsDebug
		OutputDebug, %sText%
}
