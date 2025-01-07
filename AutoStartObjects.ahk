#Include <_COMMON_SETTINGS_>
#Include <error>
#Persistent ;We have timer and don't have hotkeys.

CopyRegKey(bUserToAdmin, sKeyName)
{
	Domain := "1335199673-1435713600-4047743105"
	AdminSID := "S-1-5-21-" Domain "-500" ;Built-in Administrator
	UserSID := "S-1-5-21-" Domain "-1000" ;First regular administrator or user
	AdminKey := "HKU\" AdminSID "\Software\" sKeyName
	UserKey := "HKU\" UserSID "\Software\" sKeyName
	
	if (bUserToAdmin)
		Run_AsAdmin("reg", "copy """ UserKey """ """ AdminKey """ /s /f", , "Hide") ;(s)ubkeys and values will be copied, (f)orce without prompt
	else
		Run_AsAdmin("reg", "copy """ AdminKey """ """ UserKey """ /s /f", , "Hide")
}


CopySettingsInRegistry(bUserToAdmin)
{
	;CopyRegKey(bUserToAdmin, "") ;Template for other apps
	CopyRegKey(bUserToAdmin, "CEZEO software") ;SSDReady
	CopyRegKey(bUserToAdmin, "FinalWire")      ;AIDA64
	CopyRegKey(bUserToAdmin, "Fraps3")
	CopyRegKey(bUserToAdmin, "HWiNFO32")
	CopyRegKey(bUserToAdmin, "KillSoft")       ;HotKey Manager
	CopyRegKey(bUserToAdmin, "SpeedFan")
	CopyRegKey(bUserToAdmin, "Sysinternals")
}


class Process
{
	iDelay := 0
	bAdmin := false
	sExeName := ""
	sParams := ""
	sWorkingDir := ""
	sWinOptions := ""
	
	__New(oProcParams)
	{
		;!!! iDelay - Script will SLEEP this time before starting process.
		;Расчет: из задержки текущего процесса вычитается задержка предыдущего.
		;Происходит последовательное "накопление" задержек от запусков предыдущих процессов.
		;Вначале присваивается целевая задержка, а потом она заменяется разницей,
		;	для корректного запуска последовательности процессов с разными задержками.
		this.iDelay := oProcParams.iDelay
		this.bAdmin := oProcParams.bAdmin
		this.sExeName := oProcParams.sExeName
		this.sParams := oProcParams.sParams
		this.sWorkingDir := oProcParams.sWorkingDir
		this.sWinOptions := oProcParams.sWinOptions
	}
	
	Start()
	{
		;Если перезапустить скрипт, когда приложения из списка уже запущены,
		;то задержка запуска незапущенного приложения будет равна разнице задержек текущего
		;и предыдущего приложений. Это удобно, когда нужно перезапустить приложение из автозагрузки:
		;закрыли приложение и перезапустили скрипт.
		if (!this.Exist()) {
			Sleep % this.iDelay "000"
			Run_As(this.bAdmin, this.sExeName, this.sParams, this.sWorkingDir, this.sWinOptions)
		}
	}
	
	Exist()
	{
		SplitPath, % this.sExeName, sFileName
		Process, Exist, % sFileName	;Sets ErrorLevel to the Process ID (PID) if a matching process exists, or 0 otherwise.
		return ErrorLevel
	}
}

;--------------------------------------------------------------------------------

class Data
{
	sData := ""
	
	DeleteCommentsEmptyLines()
	{
		cComment := ";"
		sData := ""
		sStr := ""
		Loop, Parse, % this.sData, `n, `r
		{
			sStr := Trim(A_LoopField)
			if (sStr = "" or SubStr(sStr, 1, 1) = cComment)
				Continue
			if (A_Index != 1)
				sData .= "`n"
			sData .= sStr
		}
		this.sData := Trim(sData, "`n`r")
	}
	
	GetData()
	{
		this.DeleteCommentsEmptyLines()
		return this.sData
	}
}


class DataFromFile extends Data
{
	sFileName := ""
	
	__New(sFileName)
	{
		this.sFileName := sFileName
		this.ReadFile()
	}
	
	ReadFile()
	{
		FileRead, sData, % this.sFileName
		CheckError("Problem occurs, while reading file.", this.sFileName, A_ThisFunc, A_LineFile, A_LineNumber)
		this.sData := sData
	}
}


class DataFromString extends Data
{
	__New(sData)
	{
		this.sData := sData
	}
}

;--------------------------------------------------------------------------------

class Parser
{
	
}

class ParserCSV extends Parser
{
	ParseCSVParams(oCSV)
	{
		oProcParams := {}
		oProcParams.iDelay := oCSV[1]
		oProcParams.bAdmin := (oCSV[2] = "A") ? true : false
		oProcParams.sExeName := oCSV[3]
		oProcParams.sParams := oCSV[4]
		oProcParams.sWorkingDir := oCSV[5]
		oProcParams.sWinOptions := oCSV[6]
		if (oProcParams.sExeName = "")
			throw Exception("Empty sExeName")
		if (oProcParams.sWinOptions != "" && oProcParams.sWinOptions != "Max" && oProcParams.sWinOptions != "Min" && oProcParams.sWinOptions != "Hide")
			throw Exception("Wrong sWinOptions: " oProcParams.sWinOptions "`nMust be: Max|Min|Hide")
		return oProcParams
	}
	
	Parse(sData)
	{
		oProcParamsList := []
		;Sort, sData, N ;Numeric sort, VarName cannot be an expression
		Loop, Parse, sData, `n, `r
		{
			oCSV := []
			Loop, Parse, A_LoopField, CSV
				oCSV.Push(Trim(A_LoopField))
			oProcParamsList.Push(this.ParseCSVParams(oCSV))
		}
		return oProcParamsList
	}
}

class ParserXML extends Parser
{
	
}

;--------------------------------------------------------------------------------

class Manager
{
	oData := {}
	oParser := {}
	oProcList := []
	
	__New(oData, oParser)
	{
		this.oData := oData
		this.oParser := oParser
	}
	
	Swap(ByRef oArray, i, j)
	{
		temp := oArray[i]
		oArray[i] := oArray[j]
		oArray[j] := temp
	}
	
	Sort(ByRef m) ; сортировка расческой
	{
		iSize := m.Length()
		bEnd := false
		fpDivFactor := 1.247330950103979
		iStep := iSize
		while (!bEnd) {
			iStep := iStep // fpDivFactor
			iStep := Round(iStep) ;if Places is omitted or 0, Number is rounded to the nearest integer
			if (iStep < 1) {
				iStep := 1
			}
			if (iStep = 1) {
				bEnd := true
			}
			i := 1
			while (i + iStep < iSize + 1) {
				if (m[i].iDelay > m[i + iStep].iDelay) {
					;Swap(m[i], m[i + iStep]) ;!!!regular Swap not working for array's elements
					this.Swap(m, i, i + iStep)
					bEnd := false
				}
				++i
			}
		}
	}
	
	MakeProcList()
	{
		iDelayPrev := 0
		oProcParamsList := this.oParser.Parse(this.oData.GetData())
		this.Sort(oProcParamsList)
		for i, oProcParams in oProcParamsList
		{
			iDelayBetween := oProcParams.iDelay - iDelayPrev ; we SLEEP this script between start processes
			if (iDelayBetween < 0)
				throw Exception("Wrong sorting order.`nDelay between starting processes cannot be negative.", , iDelayBetween)
			iDelayPrev := oProcParams.iDelay
			oProcParams.iDelay := iDelayBetween
			this.oProcList.Push(new Process(oProcParams))
		}
	}
	
	Start()
	{
		global g_bSkipDelay
		this.MakeProcList()
		for i, oProc in this.oProcList {
			if (g_bSkipDelay)
				oProc.iDelay := 0
			if (oProc.iDelay && !oProc.Exist()) {
				maxProgress := oProc.iDelay
				SplitPath, % oProc.sExeName, , , , exeName
				Progress, b zx0 zy0 cwFFFFFF r0-%maxProgress% y0 zh6, %exeName% ;!!!if size of progress bar equals 4 or less it may be invisible, when user set non-default Windows Theme!!!
				barPosition := 0
				;Первое обновление раньше, чтобы последнее задержалось на экране на 1000-750=250мс дольше,
				;перед тем как его обнулят, иначе прогресс дойдя до конца моментально сбрасывается в начало.
				SetTimer, FirstProgressUpdate, -750
			}
			oProc.Start() ;we Sleep here to make delay
			SetTimer, FirstProgressUpdate, Off ;stop timer after each process to prevent glitch, when reload script and all processes already exists
			SetTimer, ProgressUpdate, Off ;stop timer after each process to prevent glitch, when timer continue updates Progress while process launches and there no need for update
		}
		Progress, Off
		return
		
		FirstProgressUpdate:
		SetTimer, ProgressUpdate, 1000
		Gosub, ProgressUpdate
		return
		
		ProgressUpdate:
		Progress, % ++barPosition ;not understand how this variable stay available here, because it's local variable in method Manager.Start()
		return ;I suggest this code runs in Manager.Start() scope view, which stay alive due to Sleep in method Process.Start()
	}
}


;CSV Example:
;"first field",SecondField,"the word ""special"" is quoted literally",,"last field, has literal comma"
;CSV Format:
;StartDelay,(A)dmin|(U)ser,"Exe","Params","WorkingDir","WindowParams [Max|Min|Hide]"
;NO ANY SPACES BEFORE AND AFTER COMMA
;Comments must starts from new line and begins with ";"
/*
Menu, Tray, Icon
sDataString =
(
	;comment
;	0,A,"C:\Program Files (x86)\MSI Afterburner\MSIAfterburner.exe","/s"
;	2,A,"cmd.exe","/c dir & pause",   ,"Hide"
	5,U,"calc.exe","first ""second param with spaces""",        ,"Min"
	7,A,"D:\SERGEY\Options\Program Files\BAT\Windows Firewall Control.bat", , ,"Hide"
;	10,U,"notepad.exe",    ,   ,"Max"
)
oMgr := new Manager(new DataFromString(sDataString), new ParserCSV())
oMgr.Start()

!z::Reload
!x::ExitApp
*/

; Menu, Tray, Icon
g_bSkipDelay := false
g_bQuitProgram := false
g_bKillProgram := false
if (A_Args.Length() > 1) {
    MsgBox % A_ScriptName ": requires 0 or 1 parameter, but it received " A_Args.Length() "."
    ExitApp
} else if (A_Args.Length() == 1) {
    for n, sParam in A_Args {
        MsgBox % sParam
        if (sParam == "-SkipDelay")
            g_bSkipDelay := true
        else if (sParam == "-QuitProgram")
            g_bQuitProgram := true
        else if (sParam == "-KillProgram")
            g_bKillProgram := true
        else {
            MsgBox % A_ScriptName ": wrong parameter " sParam "."
            ExitApp
        }
    }
}

sDataFile := "AutoStart.csv"
oMgr := new Manager(new DataFromFile(sDataFile), new ParserCSV())
oMgr.Start()

;TODO Change to WinWait!
Sleep, 3000 ; Wait icon from last program AND wait starting Tray_Icon_Organize.ahk script on RELOAD all scripts

if WinExist("Tray_Icon_Organize.ahk ahk_class AutoHotkey")
	PostMessage, 0x5555, 11, 22  ; The message is sent to the "last found window" due to WinExist() above.

;if WinExist("Minimize_Discord.ahk ahk_class AutoHotkey")
;	PostMessage, 0x5555, 11, 22  ; The message is sent to the "last found window" due to WinExist() above.

;if WinExist("_AutoHotkey_.ahk ahk_class AutoHotkey")
;	PostMessage, 0x5555, 11, 22  ; The message is sent to the "last found window" due to WinExist() above.

Sleep, 1000
ExitApp

;CopySettingsInRegistry(true)
;CopySettingsInRegistry(false)


;CrystalDiskInfo gadget read data from User registry, but application runs under
;   built-in Admin, so make regular copy of data from Admin to User.
;CrystalDiskInfo := Func("CopyRegKey").Bind(false, "Crystal Dew World")
;SetTimer, % CrystalDiskInfo, % 5 * 60 * 1000 ; "CrystalDiskInfo" auto refresh period I set to 5 min, so here too.
