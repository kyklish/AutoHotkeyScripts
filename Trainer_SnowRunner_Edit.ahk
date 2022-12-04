#NoEnv
#SingleInstance, Force
SetWorkingDir %A_ScriptDir%

; oFolders := ["daytimes", "engines", "gearboxes", "suspensions", "trucks", "wheels", "winches"]
oFolders := ["R:\initial\[media]\classes", "R:\initial\[media]\_dlc\"]
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
		;sData := Replace(sData, "UnlockByRank", "1")
		;Winches
		;sData := Replace(sData, "Length", "50")
		;sData := Replace(sData, "StrengthMult", "2.0")
		;sData := ReplaceDigitMul(sData, "Length", 4)
		;sData := ReplaceDigitMul(sData, "StrengthMult", 1.5)
		sData := Replace(sData, "IsEngineIgnitionRequired", "false")
		;Trucks
		;sData := ReplaceDigitMul(sData, "SteerSpeed", 2)
		;sData := ReplaceDigitMul(sData, "BackSteerSpeed", 0)
		;sData := ReplaceDigitMul(sData, "Responsiveness", 1.0)
		;Engines
		;sData := ReplaceDigitMul(sData, "Torque", 1.5)
		;Graphics
		sData := Replace(sData, "BloomEnabled", "false")
		sData := Replace(sData, "Fog Density", "0.0")
		sData := Replace(sData, "SecondaryFog Density", "0.0")
		;Camera
		sData := Insert(sData, "<ModelBrand", "`n`tClipCamera=""false""") ;Allows camera to pass through objects, no camera jump in different directions.
		
		oFile := FileOpen(A_LoopFilePath, "w")
		oFile.Write(sData)
		oFile.Close()
	}
}


Insert(sData, sSearchText, sInsertText, iStartingPos := 1, iLimit := -1) { ;Insert text after [sSearchText]
	return RegExReplace(sData, "i)" . sSearchText . "\b", sSearchText . " " . sInsertText, , iLimit, iStartingPos)
}


Replace(sData, sParamName, sNewVal, iStartingPos := 1, iLimit := -1) { ;Replace all occurrences in file
	global sBeginRegEx, sEndRegEx
	return RegExReplace(sData, sBeginRegEx . sParamName . sEndRegEx, sNewVal, , iLimit, iStartingPos)
}


ReplaceDigitMul(sData, sParamName, iMul) { ;Multiply each parsed value by iMul and write it back
	global sBeginRegEx, sEndRegEx
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
