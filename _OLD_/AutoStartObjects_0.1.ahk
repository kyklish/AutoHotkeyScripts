#Include <_COMMON_SETTINGS_>
#Include <error>
;#Warn All


class Process
{
	iDelay := 0
	bAdmin := false
	sExeName := ""
	sParams := ""
	
	__New(iDelay, bAdmin, sExeName, sParams := "")
	{
		this.iDelay := iDelay
		this.bAdmin := bAdmin
		this.sExeName := sExeName
		this.sParams := sParams
	}
	
	Start()
	{
		Sleep % this.iDelay "000"
		
		SplitPath, % this.sExeName, sFileName
		Process, Exist, % sFileName
		if (!ErrorLevel) { ;if process not exist
			if (this.bAdmin)
				Run_AsAdmin(this.sExeName, this.sParams)
			else
				Run_AsUser(this.sExeName, this.sParams)
		}
	}
}


class Data
{
	sData := ""
	
	SortDataNumericaly()
	{
		str := this.sData
		Sort, str, N ;VarName cannot be an expression
		this.sData := str
	}
	
	GetData()
	{
		this.SortDataNumericaly()
		return this.sData
	}
}


class DataFromFile extends Data
{
	sFileName := ""
	
	__New(sFileName)
	{
		this.sFilePath := sFileName
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


class Manager
{
	oProcList := []
	oData := {}
	
	__New(oData)
	{
		this.oData := oData
	}
	
	ParseCSVParams(oCSV, ByRef iDelay, ByRef bAdmin, ByRef sExeName, ByRef sParams)
	{
		iDelay := oCSV[1]
		bAdmin := (oCSV[2] = "A") ? true : false
		sExeName := oCSV[3]
		sParams := oCSV[4]
	}
	
	MakeProcList()
	{
		iDelayPrev := 0
		Loop, Parse, % this.oData.GetData(), `n, `r
		{
			oCSV := []
			Loop, Parse, A_LoopField, CSV
			{
				sCSVParam := Trim(A_LoopField)
				oCSV.Push(sCSVParam)
			}
			this.ParseCSVParams(oCSV, iDelay, bAdmin, sExeName, sParams)
			if (!sExeName)
				Continue
			iDelayBetween := iDelay - iDelayPrev ; we SLEEP script between start processes
			if (iDelayBetween < 0)
				throw Exception("Wrong sorting order.`nDelay berween starting processes cannot be negative.", , iDelayBetween)
			this.oProcList.Push(new Process(iDelayBetween, bAdmin, sExeName, sParams))
			iDelayPrev := iDelay
		}
	}
	
	Start()
	{
		this.MakeProcList()
		Loop % this.oProcList.Count() {
			this.oProcList[A_Index].Start()
		}
	}
}

i := 0
SetTimer, StartOSD, 1000

;CSV Example:
;"first field",SecondField,"the word ""special"" is quoted literally",,"last field, has literal comma"
;CSV Format
;StartDelay,(A)dmin|(U)ser,"Exe","Params"
;NO ANY SPACES BEFORE AND AFTER COMMA
sDataString =
(
6,A,"cmd.exe","third"
2,U,"calc.exe","first ""second param with spaces"""

)

sDataFile := "R:\1.csv"

oMgr := new Manager(new DataFromString(sDataString))
;oMgr := new Manager(new DataFromFile(sDataFile))
oMgr.Start()
SoundBeepTwice()
Sleep, 500
SetTimer, StartOSD, Off


!z::Reload
!x::ExitApp

StartOSD:
OSD(++i)
return