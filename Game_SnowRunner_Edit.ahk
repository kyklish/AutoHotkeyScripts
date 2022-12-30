#NoEnv
#SingleInstance, Force
SetBatchLines, -1
SetWorkingDir, R:\

;Unpack "SnowRunner\en_us\preload\paks\client\initial.pak" to "R:\initial"
;Modified files will be created in "R:\initial_modified"
;Original files are not touched, you can run script over and over with new values

oFolders := ["R:\initial\[media]\classes", "R:\initial\[media]\_dlc"]
global sBeginRegEx := "i)\b"
global sEndRegEx := "=""\K[^""]+(?="")"

global oLogFile := FileOpen("R:\initial_modified_files.log", "w")

For i, sFolder in oFolders
{
	OutputDebug, % sFolder "`n"
	Loop, Files, % sFolder . "\*.xml", R
	{
		Edit(A_LoopFilePath)
	}
}

oLogFile.Close()
SoundBeep

Edit(sFilePath)
{
	FileRead, sData, %sFilePath%
	sOriginalData := sData

	;UNLOCK ================================================================
	;sData := Replace(sData, "UnlockByExploration", "false")
	;sData := Replace(sData, "UnlockByRank", "1")
	;WINCHES ===============================================================
	;sData := Replace(sData, "Length", "50")
	;sData := Replace(sData, "StrengthMult", "2.0")
	sData := ReplaceDigitMul(sData, "Length", 2)
	;sData := ReplaceDigitMul(sData, "StrengthMult", 1.5)
	sData := Replace(sData, "IsEngineIgnitionRequired", "false")
	;TRUCKS ================================================================
	;sData := ReplaceDigitMul(sData, "SteerSpeed", 2)
	;sData := ReplaceDigitMul(sData, "BackSteerSpeed", 0)
	;sData := ReplaceDigitMul(sData, "Responsiveness", 1.0)
	;ENGINES ===============================================================
	;sData := ReplaceDigitMul(sData, "Torque", 1.5)
	;GRAPHICS ==============================================================
	sData := Replace(sData, "BloomEnabled", "false")
	sData := Replace(sData, "Fog Density", "0.0")
	sData := Replace(sData, "SecondaryFog Density", "0.0")
	;CAMERAS ===============================================================
	sData := AllowCameraPassThroughObjects(sData) ;No camera jump.
	sData := MoveCockpitCameraBackward(sData, 0.2)
	;=======================================================================

	if (sOriginalData != sData) {
		oLogFile.Write(sFilePath . "`n")
		sModifiedFilePath := StrReplace(sFilePath, "\initial\", "\initial_modified\",, 1)
		sModifiedFileDir := RegExReplace(sModifiedFilePath, "i)\\[^\\]+xml$") ;Cut file name
		if not FileExist(sModifiedFileDir)
			FileCreateDir, %sModifiedFileDir%
		oModifiedFile := FileOpen(sModifiedFilePath, "w") ;[w]==[Overwrite existing file]
		oModifiedFile.Write(sData)
		oModifiedFile.Close()
	}
}

;Replace all occurrences in file
Replace(sData, sParamName, sNewVal, iStartingPos := 1, iLimit := -1)
{
	return RegExReplace(sData, sBeginRegEx . sParamName . sEndRegEx, sNewVal, , iLimit, iStartingPos)
}

;Multiply each parsed value by iMul and write it back
ReplaceDigitMul(sData, sParamName, iMul)
{
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

MoveCockpitCameraBackward(sData, fCameraOffset)
{
	sRegEx := sBeginRegEx . "ViewPos=""\(\K[^;]+(?=;)"
	RegExMatch(sData, sRegEx, fCameraPosition)
	if fCameraPosition is number
	{
		;Subtract to move camera backward
		fCameraPosition -= fCameraOffset
		fCameraPosition := Format("{:.3f}", fCameraPosition) ;Example: '1.250'
		sData := RegExReplace(sData, sRegEx, fCameraPosition)
	}
	return sData
}

AllowCameraPassThroughObjects(sData)
{
	sSearchText := "<ModelBrand"
	sInsertText := "`n`tClipCamera=""false""" ;Add new line: [ClipCamera="false"]
	return RegExReplace(sData, "i)" . sSearchText . "\b", sSearchText . sInsertText)
}
