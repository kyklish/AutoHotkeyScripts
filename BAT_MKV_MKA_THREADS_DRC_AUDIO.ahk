; BAT_MKV_MKA_THREADS[1 ... 9]_DRC[2 ... 4]_AUDIO[1 ... 9].ahk - set audio stream
; number and DRC ratio in script's name (no need to edit script) or leave it
; blank to use internal variable value.

; Create BAT files with FFMPEG commands to create MKA files with DRC.
; FFMPEG is single-thread software, create multiple BAT files for multi-threading.

; Create BAT file with MKVMERGE commands to make MKV files with external MKA and SRT files.
; Replace all audio from source with external audio from MKA folder and add subtitles.
; Example File Structure:
; MKA\movie.mka
; movie.avi || movie.mkv
; movie.srt || movie.Force.srt || movie.rus.srt || rus\movie.srt || NO.SRT

; MKVMERGE: [-V, --version] Show version information and exit.
; mkvmerge v44.0.0 ('Domino') 64-bit works fine.

#NoEnv
#SingleInstance, Force
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

;=============================== DEFAULT PARAMS ================================

; [0 ... N] - audio stream id to convert with DRC (zero based numeration!)
iAudioStream := 0
; [2 ... 4] - DRC ratio above 4 has no audible difference
iDrcRatio := 2
; [1 ... N] - number of BAT files for manual multi-threading
iThreadsExe := 1
; Formats fo source files
oFormats := ["*.avi", "*.mkv", "*.mp4", "*.webm"]
sStaxRipTemplate := "SVPFlow 59.94FPS Movie (algo21)"

;===================== READ PARAMS FROM SCRIPT'S FILE NAME =====================

; Get audio stream id from file name (no need to edit script every time)
RegExMatch(A_ScriptName, "AUDIO(?P<Id>\d)", iAudio)
If iAudioId is Integer
    If (iAudioId > 0)
        iAudioStream := iAudioId - 1

; Get DRC ratio value from file name (no need to edit script every time)
RegExMatch(A_ScriptName, "DRC(?P<Value>\d)", iDrc)
If iDrcValue is Integer
{
    If (2 <= iDrcValue && iDrcValue <= 4)
        iDrcRatio := iDrcValue
    Else
        MsgBox Wrong DRC value: must be between 2 and 4
}

; Get number of threads from file name (no need to edit script every time)
RegExMatch(A_ScriptName, "THREADS(?P<Value>\d)", iThreads)
If iThreadsValue is Integer
{
    If (iThreadsValue > 0)
        iThreadsExe := iThreadsValue
}

;================================== EXECUTE ====================================

oFileNames := GetVideoFileNames(oFormats, iDrcRatio, iThreadsExe)
If (oFileNames[0].Count() > 0)
    CreateBAT(oFileNames, oFormats, iAudioStream, iDrcRatio, iThreadsExe, sStaxRipTemplate)
If (WinExist("Total Commander"))
    Send ^r ; Refresh panel to show newly created files
ExitApp

;===============================================================================

CreateBAT(oFileNames, oFormats, iAudioStream, iDrcRatio, iThreadsExe, sStaxRipTemplate) {
    ; oFileNames[0] contains all source video files
    FileWrite("!!.MOVE_HERE_MKA_TO_WATCH_MOVIE.BAT", GetMkaMoveHereCmd())
    FileWrite("!1.RE-MUX_TO_MKV_ENG_AUDIO" iAudioStream + 1 ".BAT", GetReMuxCmd(oFileNames[0], iAudioStream))
    FileWrite("!2.MOVE_HERE_RE-MUX_RESULT_DELETE_ORIGINAL_VIDEO.BAT", GetReMuxMoveHereDelOrigVideoCmd(oFileNames[0]))

    Loop % iThreadsExe {
        If (oFileNames[A_Index].Count()) {
            FileWrite("#.AUDIO" iAudioStream + 1 "_DRC" iDrcRatio "_THREAD" A_Index ".BAT"
                , GetMkaCmd(oFileNames[A_Index], iAudioStream, iDrcRatio))
        }
    }

    FileWrite("1.RUN_ALL_AUDIO_THREADS.BAT", GetThreadCmd())
    FileWrite("2.MUX_TO_MKV.BAT", GetMuxCmd(oFileNames[0]))
    FileWrite("3.MOVE_HERE_MUX_RESULT_DELETE_ORIGINAL_FILES.BAT", GetMuxMoveHereDelOrigCmd(oFileNames[0]))
    FileWrite("4.StaxRip_SVPFlow.BAT", GetStaxRipCmd(sStaxRipTemplate))
    FileWrite("4.StaxRip_SVPFlow_DELETE_ORIGINAL.BAT", GetStaxRipDelOrigCmd(sStaxRipTemplate))
    ; Use CMD extension to make it unique, we will use it to delete this file last
    FileWrite("5.DELETE_SCRIPT_FILES_HERE.CMD", GetDelScriptCmd())
}

FileWrite(sFileName, sStr) {
    oFile := FileOpen(sFileName, "w `n")
    oFile.Write(sStr)
    oFile.Close()
}

GetMkaCmd(oFileNames, iAudioStream, iDrcRatio) {
    sCmd := ""
    sCmd .= "@ECHO OFF`n"
    sCmd .= "CD /D ""%~dp0""`n"
    sCmd .= "IF NOT EXIST ""MKA"" MKDIR ""MKA""`n"
    For _, oFileName in oFileNames {
        sCmd .= "`n"
        sCmd .= "ffmpeg ^`n"
        sCmd .= "    -y -i """ oFileName["path"] """ ^`n"
        sCmd .= "    -map 0:a:" iAudioStream " -c:a:0 aac -b:a:0 192k -ac 2 ^`n"
        sCmd .= "        -filter:a:0 ""acompressor=ratio=" iDrcRatio ":mode=upward"" ^`n"
        sCmd .= "        ""MKA\" oFileName["mka"] """`n"
    }
    Return sCmd
}

GetMuxCmd(oFileNames) {
    sCmd := ""
    sCmd .= "@ECHO OFF`n"
    sCmd .= "CD /D ""%~dp0""`n"
    sCmd .= "SETLOCAL EnableDelayedExpansion`n"
    sCmd .= "IF NOT EXIST ""MKV"" MKDIR ""MKV""`n"
    sCmd .= "`n"
    For _, oFileName in oFileNames {
        sCmd .= "mkvmerge ^`n"
        sCmd .= "    --output ""MKV\" oFileName["name"] "." oFileName["suffix"] ".mkv"" ^`n"
        sCmd .= "    --no-audio --subtitle-tracks ukr,rus,eng,und """ oFileName["path"] """ ^`n"
        sCmd .= "    --language 0:eng --track-name 0:""" oFileName["suffix"] """ ""MKA\" oFileName["mka"] """"
        For _, sExt in ["ass", "srt"]
            Loop, Files, % oFileName["name"] "*." sExt, R
            {
                bForced := false
                sLng := "rus"
                If (InStr(A_LoopFileName, ".ukr." sExt) || InStr(A_LoopFileDir, "ukr"))
                    sLng := "ukr"
                If (InStr(A_LoopFileName, ".eng." sExt) || InStr(A_LoopFileDir, "eng"))
                    sLng := "eng"
                If (InStr(A_LoopFileName, ".forc." sExt) || InStr(A_LoopFileName, ".forced." sExt))
                    bForced := true
                If (bForced)
                    sCmd .= " ^`n    --language 0:rus --track-name 0:""Forced"" """ A_LoopFilePath """"
                Else
                    sCmd .= " ^`n    --language 0:" sLng " """ A_LoopFilePath """"
            }
        sCmd .= "`n"
        sCmd .= "CALL :CHECK_ERROR || GOTO :EOF`n"
        sCmd .= "`n"
    }
    sCmd .= "GOTO :EOF`n"
    sCmd .= "`n"
    sCmd .= ":CHECK_ERROR`n"
    sCmd .= "IF !ERRORLEVEL! NEQ 0 (`n"
    sCmd .= "    @ECHO: & CHOICE /M ""SOMETHING WENT WRONG, CONTINUE?""`n"
    sCmd .= "    IF !ERRORLEVEL! EQU 2 EXIT /B 1`n"
    sCmd .= ")`n"
    sCmd .= "EXIT /B 0`n"
    sCmd .= "`n"
    Return sCmd
}

GetThreadCmd() {
    sCmd := ""
    sCmd .= "@ECHO OFF`n"
    sCmd .= "CD /D ""%~dp0""`n"
    sCmd .= "FOR %%F IN (""*AUDIO*_DRC*_THREAD*.BAT"") DO START CMD /C ""%%F""`n"
    Return sCmd
}

GetMkaMoveHereCmd() {
    sCmd := ""
    sCmd .= "@ECHO OFF`n"
    sCmd .= "CD /D ""%~dp0""`n"
    sCmd .= "MOVE MKA\*.mka`n"
    sCmd .= "RMDIR MKA`n"
    Return sCmd
}

GetReMuxMoveHereDelOrigVideoCmd(oFileNames) {
    sCmd := ""
    sCmd .= "@ECHO OFF`n"
    sCmd .= "CD /D ""%~dp0""`n"
    sCmd .= "ECHO !!!SCRIPT WILL DELETE ORIGINAL VIDEO FILES!!!`n"
    sCmd .= "ECHO !!!SCRIPT WILL DELETE ORIGINAL VIDEO FILES!!!`n"
    sCmd .= "ECHO !!!SCRIPT WILL DELETE ORIGINAL VIDEO FILES!!!`n"
    sCmd .= "CHOICE /M ""Move here MKV & Delete original VIDEO files?""`n"
    sCmd .= "IF %ERRORLEVEL% EQU 1 (`n"
    sCmd .= "    GOTO :DELETE_MOVE_FILES`n"
    sCmd .= ") ELSE (`n"
    sCmd .= "    GOTO :EOF`n"
    sCmd .= ")`n"
    sCmd .= "`n"
    sCmd .= ":DELETE_MOVE_FILES`n"
    For _, oFileName in oFileNames
        sCmd .= "DEL """ oFileName["path"] """`n"
    sCmd .= ":: Move re-muxed MKV files`n"
    sCmd .= "MOVE MKV\*.mkv`n"
    sCmd .= "RMDIR MKV`n"
    sCmd .= ":: Delete outdated scripts`n"
    sCmd .= "DEL /F /Q *.cmd`n"
    sCmd .= ":: Delete BAT scripts LAST!!! (Script deletes himself)`n"
    sCmd .= "DEL /F /Q *.bat`n"
    Return sCmd
}

GetReMuxCmd(oFileNames, iAudioStream) {
    sCmd := ""
    sCmd .= "@ECHO OFF`n"
    sCmd .= "CD /D ""%~dp0""`n"
    sCmd .= "SETLOCAL EnableDelayedExpansion`n"
    sCmd .= "IF NOT EXIST ""MKV"" MKDIR ""MKV""`n"
    sCmd .= "`n"
    sCmd .= "ECHO Copy ENG audio track from MKV files...`n"
    sCmd .= "`n"
    sCmd .= "FOR %%F IN (""*.mkv"") DO (`n"
    sCmd .= "    mkvmerge -o ""MKV\%%~nF.mkv"" -a eng -s ukr,rus,eng,und ""%%F""`n"
    sCmd .= ")`n"
    sCmd .= "`n"
    sCmd .= "ECHO Copy AUDIO" iAudioStream + 1 " track from other files...`n"
    sCmd .= "`n"
    For _, oFileName in oFileNames
        If (oFileName["ext"] != "MKV") {
            sCmd .= "mkvmerge -o ""MKV\" oFileName["name"] ".mkv"" -a " iAudioStream + 1 " """ oFileName["path"] """`n"
            sCmd .= "CALL :CHECK_ERROR || GOTO :EOF`n"
            sCmd .= "`n"
        }
    sCmd .= "GOTO :EOF`n"
    sCmd .= "`n"
    sCmd .= ":CHECK_ERROR`n"
    sCmd .= "IF !ERRORLEVEL! NEQ 0 (`n"
    sCmd .= "    @ECHO: & CHOICE /M ""SOMETHING WENT WRONG, CONTINUE?""`n"
    sCmd .= "    IF !ERRORLEVEL! EQU 2 EXIT /B 1`n"
    sCmd .= ")`n"
    sCmd .= "EXIT /B 0`n"
    sCmd .= "`n"
    Return sCmd
}

GetMuxMoveHereDelOrigCmd(oFileNames) {
    sCmd := ""
    sCmd .= "@ECHO OFF`n"
    sCmd .= "CD /D ""%~dp0""`n"
    sCmd .= "ECHO !!!SCRIPT WILL DELETE ALL FOLDERS!!!`n"
    sCmd .= "ECHO !!!SCRIPT WILL DELETE ALL FOLDERS!!!`n"
    sCmd .= "ECHO !!!SCRIPT WILL DELETE ALL FOLDERS!!!`n"
    sCmd .= "CHOICE /M ""Delete source files?""`n"
    sCmd .= "IF %ERRORLEVEL% EQU 1 (`n"
    sCmd .= "    GOTO :DELETE_SOURCE_FILES`n"
    sCmd .= ") ELSE (`n"
    sCmd .= "    GOTO :EOF`n"
    sCmd .= ")`n"
    sCmd .= "`n"
    sCmd .= ":DELETE_SOURCE_FILES`n"
    For _, oFileName in oFileNames
        sCmd .= "DEL """ oFileName["path"] """`n"
    sCmd .= "MOVE MKV\*.mkv`n"
    sCmd .= "RMDIR MKV`n" ; No /S /Q, because MKV must be empty already!
    sCmd .= "RMDIR /S /Q MKA`n"
    Loop, Files, *, D
        sCmd .= "RMDIR /S /Q """ A_LoopFileName """`n" ; Folders with subs
    sCmd .= "DEL /F /Q *.ass`n"
    sCmd .= "DEL /F /Q *.srt`n"
    Return sCmd
}

GetStaxRipCmd(sStaxRipTemplate) {
    sCmd := ""
    sCmd .= "@ECHO OFF`n"
    sCmd .= "CD /D ""%~dp0""`n"
    sCmd .= "SETLOCAL EnableDelayedExpansion`n"
    sCmd .= "`n"
    sCmd .= "SET Template=""" sStaxRipTemplate """`n"
    sCmd .= "`n"
    sCmd .= "FOR %%F IN (""*.AVI"") DO SET FileList=!FileList!""%%F"";`n"
    sCmd .= "FOR %%F IN (""*.MKV"") DO SET FileList=!FileList!""%%F"";`n"
    sCmd .= "FOR %%F IN (""*.MP4"") DO SET FileList=!FileList!""%%F"";`n"
    sCmd .= "`n"
    sCmd .= "START """" /B StaxRip -ClearJobs -LoadTemplate:%Template% -AddBatchJobs:%FileList% -StartJobs -Exit`n"
    Return sCmd
}

GetStaxRipDelOrigCmd(sStaxRipTemplate) {
    sCmd := ""
    sCmd .= "@ECHO OFF`n"
    sCmd .= "CD /D ""%~dp0""`n"
    sCmd .= "SETLOCAL EnableDelayedExpansion`n"
    sCmd .= "`n"
    sCmd .= "SET Template=""" sStaxRipTemplate """`n"
    sCmd .= "`n"
    sCmd .= "CALL :ENCODE *.AVI`n"
    sCmd .= "CALL :ENCODE *.MKV`n"
    sCmd .= "CALL :ENCODE *.MP4`n"
    sCmd .= "CALL :BELL`n"
    sCmd .= "CALL :BELL`n"
    sCmd .= "GOTO :EOF`n"
    sCmd .= "`n"
    sCmd .= ":ENCODE`n"
    sCmd .= "FOR %%F IN (""%~1"") DO (`n"
    sCmd .= "    StaxRip -ClearJobs -LoadTemplate:%Template% -AddBatchJob:""%%F"" -StartJobs -Exit`n"
    sCmd .= "    DEL /F ""%%F""`n"
    sCmd .= "    ECHO DONE: ""%%F""`n"
    sCmd .= "    CALL :BELL`n"
    sCmd .= ")`n"
    sCmd .= "EXIT /B`n"
    sCmd .= "`n"
    sCmd .= ":BELL`n"
    sCmd .= "ECHO `n"
    sCmd .= "ping -n 2 google.com > NUL`n"
    sCmd .= "EXIT /B`n"
    Return sCmd
}

GetDelScriptCmd() {
    sCmd := ""
    sCmd .= "@ECHO OFF`n"
    sCmd .= "CD /D ""%~dp0""`n"
    sCmd .= "DEL /F /Q *.ahk`n"
    sCmd .= "DEL /F /Q *.bat`n"
    sCmd .= ":: Delete CMD script LAST!!! (Script deletes himself)`n"
    sCmd .= "DEL /F /Q *.cmd`n"
    Return sCmd
}

GetVideoFileNames(oFilePatterns, iDrcRatio, iThreadsExe) {
    oFileNames := { 0: {} }
    Loop % iThreadsExe
        oFileNames[A_Index] := []
    For _, sFilePattern in oFilePatterns
        Loop, Files, %sFilePattern%
        {
            SplitPath, A_LoopFileName,,,, sNameNoExt
            sSuffix := "DRC" iDrcRatio "_UPWARD"
            oFileElement := { 0:""
                , "ext": A_LoopFileExt
                , "mka": sNameNoExt "." sSuffix ".mka"
                , "name": sNameNoExt
                , "path": A_LoopFilePath
                , "suffix": sSuffix }
            iIndex := Mod(A_Index, iThreadsExe)
            ; Modulo returns 0 when [A_Index == iTreads]
            ; [A_Index] can't be 0 inside [Loop] command, make it equal [iThreadsExe]
            iIndex := iIndex ? iIndex : iThreadsExe
            ; FFMPEG: distribute to multiple BAT files for multi-threading
            oFileNames[iIndex].Push(oFileElement)
            ; MKVMERGE: all files in one BAT file
            oFileNames[0].Push(oFileElement)
        }
    Return oFileNames
}
