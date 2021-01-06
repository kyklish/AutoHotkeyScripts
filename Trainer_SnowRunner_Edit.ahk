#NoEnv
#SingleInstance, Force
SetWorkingDir %A_ScriptDir%

oFolders := ["engines", "gearboxes", "suspensions", "trucks", "wheels", "winches"]
sBeginRegEx := "i)\b"
sEndRegEx := "=""\K[^""]+(?="")"

For i, sFolder in oFolders
{
	Loop, Files, % sFolder . "\*.xml", R
	{
		Edit(A_LoopFilePath)
	}
}
SoundBeep


Edit(sFilePath)
{
	FileRead, sData, %sFilePath%
	{
		;Unlock
		;sData := Replace(sData, "UnlockByExploration", "false")
		;sData := Replace(sData, "UnlockByRank", 1)
		;Winches
		;sData := Replace(sData, "Length", 50)
		;sData := Replace(sData, "StrengthMult", 2.0)
		;sData := ReplaceDigitMul(sData, "Length", 4)
		;sData := ReplaceDigitMul(sData, "StrengthMult", 1.5)
		;sData := Replace(sData, "IsEngineIgnitionRequired", "false")
		;Trucks
		;sData := ReplaceDigitMul(sData, "SteerSpeed", 2)
		;sData := ReplaceDigitMul(sData, "BackSteerSpeed", 0)
		;Unlock
		sData := Replace(sData, "UnlockByExploration", "false")
		sData := Replace(sData, "UnlockByRank", "1")
		
		oFile := FileOpen(A_LoopFilePath, "w")
		oFile.Write(sData)
		oFile.Close()
	}
}


Replace(sData, sParamName, sNewVal, iStartingPos := 1, iLimit := -1) { ;Replace all occurens in file
	global sEndRegEx, sBeginRegEx
	return RegExReplace(sData, sBeginRegEx . sParamName . sEndRegEx, sNewVal, , iLimit, iStartingPos)
}


ReplaceDigitMul(sData, sParamName, iMul) { ;Multiply each parsed value by iMul and write it back
	global sEndRegEx, sBeginRegEx
	iFoundPos := 1
	Loop {
		iFoundPos := RegExMatch(sData, sBeginRegEx . sParamName . sEndRegEx, sVal, iFoundPos)
		if (iFoundPos == 0)
			break
		if sVal is number
		{
			sNewVal := sVal * iMul
			if sVal is float
			{
				sNewVal := RTrim(sNewVal, "0")
				sNewVal := RTrim(sNewVal, ".")
			}
			else
			{
				if sVal is integer
				{
					sNewVal := Round(sNewVal)
				}
			}
		}
		sData := Replace(sData, sParamName, sNewVal, iFoundPos - StrLen(sParamName . "="""), 1)
		iFoundPos += StrLen(sNewVal)
	}
	return sData
}