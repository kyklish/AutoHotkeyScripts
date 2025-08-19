#Include <_COMMON_SETTINGS_>
#Include <error>
;#Warn All


class Process
{
	iDelay := 0
	bAdmin := false
	sExeName := ""
	sParams := ""
	
	__New(oProcParams)
	{
		this.iDelay := oProcParams.iDelay ;script's sleep time before starting process
		this.bAdmin := oProcParams.bAdmin
		this.sExeName := oProcParams.sExeName
		this.sParams := oProcParams.sParams
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
		for i, oProc in this.oProcList
			oProc.Start()
	}
}

OSD(i := 0)
SetTimer, StartOSD, 1000

;CSV Example:
;"first field",SecondField,"the word ""special"" is quoted literally",,"last field, has literal comma"
;CSV Format
;StartDelay,(A)dmin|(U)ser,"Exe","Params"
;NO ANY SPACES BEFORE AND AFTER COMMA
;Comments must begin from new line and begins with ";"
sDataString =
(



	;comment
	6,A,"cmd.exe","third"			
			2,U,"calc.exe","first ""second param with spaces"""

			
	4,U,"notepad.exe"		
			
)

sDataFile := "R:\1.csv"

oMgr := new Manager(new DataFromString(sDataString), new ParserCSV())
;oMgr := new Manager(new DataFromFile(sDataFile), new ParserCSV())
oMgr.Start()

SoundBeepTwice()
Sleep, 500
SetTimer, StartOSD, Off
OSD("END")


!z::Reload
!x::ExitApp

StartOSD:
OSD(++i)
return