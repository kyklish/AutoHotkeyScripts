#Warn
#NoEnv
#SingleInstance, Force
SetBatchLines, -1

; "initial.pak" = "SnowRunner\en_us\preload\paks\client\initial.pak"
; Make backup of the original "initial.pak" and add its path to [sInitialPak] var.
; Script unpacks "initial.pak" with WinRAR (or unpack it manually).
; Unpacked files must be in "%sWorkingDir%\initial" folder.
; Modified files will be created in "%sWorkingDir%\initial_modified" folder.
; You can run script over and over with new values.

sInitialPak := "E:\UNPROTECTED\GAMES\SnowRunner_-_Premium_Edition\preload\paks\client\initial_backup.pak"
sWorkingDir := "R:\MSE"
EnvGet, sSOFT, SOFT
sWinRAR := sSOFT "\WinRAR\WinRAR.exe"

if (!FileExist(sInitialPak)) {
    MsgBox % "File [" sInitialPak "] not found."
    ExitApp
}

; Create working directory. Skip if exist.
if (!FileExist(sWorkingDir)) {
    FileCreateDir, %sWorkingDir%
    if (ErrorLevel) {
        MsgBox % "Can't create working directory [" sWorkingDir "]"
        ExitApp
    }
}
SetWorkingDir, %sWorkingDir%

; Copy to working directory original "initial.pak". Skip if exist.
if (!FileExist("initial_original.pak"))
    FileCopy, % sInitialPak, % "initial_original.pak"

; Unpack "initial.pak" with WinRAR. Skip if unpacked.
if (!FileExist("initial")) {
    if (FileExist(sWinRAR)) {
        sUnpackCmd := "x initial_original.pak initial\"
        RunWait, %sWinRAR% %sUnpackCmd%, %sWorkingDir%
        if (ErrorLevel) {
            MsgBox % "WinRAR return ErrorLevel: " ErrorLevel
            ExitApp
        }
    }
    else {
        MsgBox % "["sWinRAR "] not found.`n`nUnpack [initial.pak] to [" sWorkingDir "\initial] folder."
        ExitApp
    }
}

oFolders := ["initial\[media]\classes", "initial\[media]\_dlc"]
global sBeginRegEx := "i)\b"
global sEndRegEx := "=""\K[^""]+(?="")"

; Create folder for modified files and do the job. Skip if exist.
if (!FileExist("initial_modified")) {
    oLogFile := FileOpen("modified_files.log", "w `n")

    For _, sFolder in oFolders {
        OutputDebug, % sFolder "`n"
        Loop, Files, % sFolder . "\*.xml", R
            Edit(A_LoopFileLongPath, oLogFile)
    }

    oLogFile.Close()
}

; Pack modified files to "initial.pak" in working directory with WinRAR. Skip if not exist.
if (FileExist("initial_modified")) {
    MsgBox, 4, , % "Pack modified files to [initial.pak] in working directory?"
    IfMsgBox, Yes
    {
        ; Overwrite old modified file with original one
        FileCopy, % "initial_original.pak", % "initial.pak", 1 ; (1 = overwrite)
        ; Move modified files into archive
        if (FileExist(sWinRAR)) {
            ; -af  = archive format
            ; -ep1 = exclude base folder from names (read "WinRAR.chm")
            ; -df  = delete files
            ; -dr  = delete files to recycle bin
            ; -r   = recursive
            sPackCmd := "m -afzip -df -ep1 -r initial.pak initial_modified\*"
            RunWait, %sWinRAR% %sPackCmd%, %sWorkingDir%
            if (ErrorLevel) {
                MsgBox % "WinRAR return ErrorLevel: " ErrorLevel
                ExitApp
            }

            Sleep, 1000 ; Wait OS file system to do the work
            if (FileExist("initial_modified")) {
                FileRemoveDir, % "initial_modified"
                if (ErrorLevel)
                    MsgBox % "[initial_modified] folder not empty."
            }

            if (FileExist("initial.pak")) {
                MsgBox, 4, , % "Overwrite [initial.pak] in game's directory?"
                IfMsgBox, Yes
                {
                    SplitPath, % sInitialPak, , sGameDir
                    FileCopy, % "initial.pak", % sGameDir, 1 ; (1 = overwrite)
                }
            }
        }
        else {
            MsgBox % "["sWinRAR "] not found.`n`nPack modified files to [initial.pak] manually."
            ExitApp
        }
    }
}

ExitApp

Edit(sFilePath, oLogFile)
{
    FileRead, sData, %sFilePath%
    sOriginalData := sData

    ;Epic Games\SnowRunner\en_us\Sources\BinEditor\Guides\Integration_of_Trucks_and_Addons.pdf
    ;UNLOCK ================================================================
    ;sData := Replace(sData, "Country", "US,NE,CE,RU,CAS") ; Unlock trucks for all regions.
    ;sData := Replace(sData, "UnlockByExploration", "false")
    ;sData := Replace(sData, "UnlockByRank", "1")
    ;sData := ReplaceDigitMul(sData, "Price", 0.5)
    ;WINCHES ===============================================================
    ;sData := Replace(sData, "Length", "50") ; Maximum length of the winch rope. Value: [0.0: 100.0], by default: 14.
    ;sData := Replace(sData, "StrengthMult", "2.0") ; Winch power. Value: [0.0: 10.0], by default: 1.
    sData := ReplaceDigitMul(sData, "Length", 2)
    ;sData := ReplaceDigitMul(sData, "StrengthMult", 1.5)
    sData := Replace(sData, "IsEngineIgnitionRequired", "false")
    ;TRUCKS ================================================================
    ;sData := ReplaceDigitMul(sData, "SteerSpeed", 2) ; Steering speed of the steering wheel. Value: [0.0: 1.0].
    ;sData := ReplaceDigitMul(sData, "BackSteerSpeed", 0) ; After turning, wheels return to their original position. This parameter is the speed with which they return to this position. Value: [0.0:1.0].
    ;sData := ReplaceDigitMul(sData, "Responsiveness", 1.0) ; Responsiveness of the steering wheel. Value: [0.0: 1.0].
    ;FUEL ==================================================================
    ;sData := ReplaceDigitMul(sData, "FuelCapacity", 2) ; The capacity of the fuel tanks. Integer values only. For a truck: No explicit limit for the value. For an addon: [0:64000].
    ;ENGINES ===============================================================
    ;sData := ReplaceDigitMul(sData, "EngineResponsiveness", 0.5) ; Engine responsiveness (speed of increase of the engine speed). By default: 0.04. Value range: [0.01; 1].
    ;sData := ReplaceDigitMul(sData, "Torque", 1.5) ; Torque. By default: 0. Value range: [0; 1000000].
    ;sData := ReplaceDigitMul(sData, "MaxDeltaAngVel", 0.5) ; Limiter for the maximum angular acceleration of the wheels. The smaller it is, the slower the car accelerates. By default: 0. Value range: [0; 1000000].
    ;GRAPHICS ==============================================================
    sData := Replace(sData, "BloomEnabled", "false")
    sData := Replace(sData, "Fog Density", "0.0")
    sData := Replace(sData, "SecondaryFog Density", "0.0")
    sData := Replace(sData, "VolumeFog Density", "0.0")
    ;TRAILERS ==============================================================
    sData := AllowTrailer(sData) ; Allow attach truck trailer to scout.
    sData := AllowScoutTrailer(sData) ; Allow attach scout trailer to truck.
    ;CAMERAS ===============================================================
    sData := AllowCameraPassThroughObjects(sData) ; No camera jump.
    sData := MoveCockpitCameraBackward(sData, 0.22) ; More then 0.22 will produce visual glitches on trucks with short cabin.
    ;sData := ReplaceDigitMul(sData, "WindshieldDetailDensity", 0.1) ; Tiling of the detailed texture (one common texture for all trucks, chips on the windshield). By default: 0.4

    ; <Camera>
    ; External camera.
    ; •
    ; Center="(-1.7; 0; 0)"
    ; Point that the external camera is directed to.
    ; •
    ; RadiusMultiplier="0.8"
    ; Scale of the distance to the Center. By default: 1. For large trucks, it is typically equal to
    ; 1.1, For scouts - to 0.8
    ; •
    ; ParentFrame="BoneCabin_cdt"
    ; The bone from the physical model hierarchy, which the camera is attached to. If the
    ; parameter is not specified, then it will be the root bone of the physical model.

    ; <Cockpit>
    ; Internal camera and windshield.
    ; •
    ; WindshieldDetailDensity="0.6"
    ; Tiling of the detailed texture (one common texture for all trucks, chips on the
    ; windshield). By default: 0.4
    ; •
    ; WindshieldDiffuseTexture="trucks/cat_ct680_glass__d_a.tga"
    ; Diffuse map of the windshield texture (same as on the outside window of the truck).
    ; Located in the .../textures/ folder.
    ; •
    ; WindshieldShadingTexture="trucks/cat_ct680_glass__d_a.tga"
    ; Shading map of the windshield texture (same as on the outside window of the truck).
    ; Located in the .../textures/ folder.
    ; •
    ; WindshieldDiffuseCleanAlpha="0.5"
    ; Transparency of the alpha channel. By default: 0
    ; •
    ; WindshieldDiffuseAlphaContrast="0.5"
    ; Contrast of the alpha channel. By default: 1
    ; •
    ; ViewPos="(1.148; 2.6; 0.488)"
    ; * Default position of the internal camera.
    ; •
    ; ViewDir="(1; -0.05; 0)"
    ; * Default direction vector of the internal camera.
    ; •
    ; LimitsHor="(-2.8; 2.4)"
    ; * Limits for the horizontal rotation of the camera. Value in radians.
    ; •
    ; LimitsVer="(-0.32; 0.2)"
    ; * Limits for the vertical rotation of the camera. Value in radians.
    ; •
    ; ZoomViewDirOffset="(0; -0.05; 0)"
    ; * Shift of the direction vector in case of the camera zoom
    ; •
    ; ZoomViewPosOffset="(0.2; 0; 0)"
    ; * Shift of the camera in case of the zoom.
    ;=======================================================================

    if (sOriginalData != sData) {
        oLogFile.Write(sFilePath "`n")
        sModifiedFilePath := StrReplace(sFilePath, "\initial\", "\initial_modified\", , 1)
        SplitPath, sModifiedFilePath, , sModifiedFileDir
        if (!FileExist(sModifiedFileDir))
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

;Add ability to attach scout trailers to trucks.
AllowScoutTrailer(sData)
{
    ;Developers make grammatical mistake in word "Scout"!
    ;They use word "Skaut" for scout trailer!
    ;Developers enumerate trailers with coma and space (like regular text in document):
    ;   Names="Trailer, LogTrailer"
    ;We will use CSV syntax and enumerate with coma without space:
    ;   Names="Trailer,ScautTrailer, LogTrailer"
    sSearchText := "<Socket Names=""Trailer"
    sInsertText := ",ScautTrailer"
    return RegExReplace(sData, "i)" . sSearchText . "\b", sSearchText . sInsertText)
}

;Add ability to attach trailers to scouts.
AllowTrailer(sData)
{
    sSearchText := "<Socket Names=""ScautTrailer"
    sInsertText := ",Trailer"
    return RegExReplace(sData, "i)" . sSearchText . "\b", sSearchText . sInsertText)
}
