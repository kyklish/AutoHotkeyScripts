#Include <_COMMON_SETTINGS_>
#Include <error>
#Warn All

CopyRegKey(bUserToAdmin, sKeyName)
{
	Domain := "1335199673-1435713600-4047743105"
	AdminSID := "S-1-5-21-" Domain "-500" ;Built-in Administrator
	UserSID := "S-1-5-21-" Domain "-1000" ;First regular administrator or user
	AdminKey := "HKU\" AdminSID "\Software\" sKeyName
	UserKey := "HKU\" UserSID "\Software\" sKeyName
	
	if (bUserToAdmin)
		Run_AsAdmin("reg", "copy """ UserKey """ """ AdminKey """ /s /f") ;(s)ubkeys and values will be copied, (f)orce without prompt
	;else
		;Run_AsAdmin("reg", "copy """ AdminKey """ """ UserKey """ /s /f")
}


CopySettingsInRegistry(bUserToAdmin)
{
	;CopyRegKey(bUserToAdmin, "")
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
	
	__New(oProcParams)
	{
		;!!! iDelay - Script will SLEEP this time before starting process.
		;Расчет: из задержки текущего процесса вычитается задержка предыдущего.
		;Происходит последовательное "накопление" задержек от запусков предыдущих процессов.
		;Вначале присваевается целевая задержка, а потом она заменяется разницей,
		;	для коррекного запуска последоваетльности процессов с разными задержками.
		this.iDelay := oProcParams.iDelay
		this.bAdmin := oProcParams.bAdmin
		this.sExeName := oProcParams.sExeName
		this.sParams := oProcParams.sParams
	}
	
	Start()
	{
		SplitPath, % this.sExeName, sFileName
		Process, Exist, % sFileName
		if (!ErrorLevel) { ;if process not exist
			;MsgBox % this.sExeName
			Sleep % this.iDelay "000"
			Run_As(this.bAdmin, this.sExeName, this.sParams)
		}
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
		if (oProcParams.sExeName = "")
			throw Exception("Empty sExeName")
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
				oCSV.Push(A_LoopField)
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
				throw Exception("Wrong sorting order.`nDelay berween starting processes cannot be negative.", , iDelayBetween)
			iDelayPrev := oProcParams.iDelay
			oProcParams.iDelay := iDelayBetween
			this.oProcList.Push(new Process(oProcParams))
		}
	}
	
	Start()
	{
		this.MakeProcList()
		for i, oProc in this.oProcList {
			if(oProc.iDelay) {
				maxProgress := oProc.iDelay
				SplitPath, % oProc.sExeName, , , , exeName
				Progress, b zx0 zy0 cwFFFFFF r0-%maxProgress% y0 zh4, %exeName%
				timer := 0
				Progress, % timer
				;Первое обновление раньше, чтобы последнее задержалось на экране на 1000-750=250мс дольше,
				;перед тем как его обнулят, иначе прогресс дойдя до конца моментально сбрасывается в начало.
				SetTimer, ProgressUpdate, 750
			}
			oProc.Start()
			SetTimer, ProgressUpdate, Off
			Progress, Off
		}
		return
		
		ProgressUpdate:
		SetTimer, %A_ThisLabel%, 1000
		Progress % ++timer
		return
	}
}



;CSV Example:
;"first field",SecondField,"the word ""special"" is quoted literally",,"last field, has literal comma"
;CSV Format:
;StartDelay,(A)dmin|(U)ser,"Exe","Params"
;NO ANY SPACES BEFORE AND AFTER COMMA
;Comments must starts from new line and begins with ";"
/*
sDataString =
(
	;comment
	0,A,"C:\Program Files (x86)\MSI Afterburner\MSIAfterburner.exe","/s"
 ;2,A,"cmd.exe","third"			
 ;5,U,"calc.exe","first ""second param with spaces"""
;10,U,"notepad.exe"		
)
oMgr := new Manager(new DataFromString(sDataString), new ParserCSV())
oMgr.Start()
return
*/

sDataFile := "AutoStart.csv"
oMgr := new Manager(new DataFromFile(sDataFile), new ParserCSV())
oMgr.Start()



;CopySettingsInRegistry(true)
;CopySettingsInRegistry(false)