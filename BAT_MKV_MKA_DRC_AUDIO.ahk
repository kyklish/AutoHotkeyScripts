﻿; BAT_MKV_MKA_DRC[2 ... 4]_AUDIO[1 ... 9].ahk - set audio stream number and DRC
; ratio in script's name (no need to edit script) or leave it blank to use
; internal variable value.

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

; [0 ... N] - audio stream id to convert with DRC (zero based numeration!)
iAudioStream := 0
; [2 ... 4] - DRC ratio above 4 has no audible difference
iDrcRatio := 2
; [1 ... N] - number of BAT files for manual multi-threading
iThreads := 4

; Get audio stream id from file name (no need to edit script every time)
RegExMatch(A_ScriptName, "AUDIO(?P<Id>\d)", iAudio)
If iAudioId is Integer
    If (iAudioId > 0)
        iAudioStream := iAudioId - 1

; Get DRC ratio value from file name (no need to edit script every time)
RegExMatch(A_ScriptName, "DRC(?P<Value>\d)", iDrc)
If iDrcValue is Integer
    If (2 <= iDrcValue && iDrcValue <= 4)
        iDrcRatio := iDrcValue

oFileNames := GetVideoFileNames(["*.avi", "*.mkv"], iDrcRatio, iThreads)
If (oFileNames[0].Count() > 0)
    CreateBAT(oFileNames, iThreads)
ExitApp

CreateBAT(oFileNames, iThreads) {
    global iAudioStream, iDrcRatio
    Loop % iThreads {
        If (oFileNames[A_Index].Count()) {
            oFile := FileOpen("!.AUDIO" iAudioStream + 1 "_DRC" iDrcRatio "_THREAD" A_Index ".BAT", "w")
            oFile.Write(GetMkaCmd(oFileNames[A_Index], iAudioStream, iDrcRatio))
            oFile.Close()
        }
    }
    oFile := FileOpen("1.RUN_ALL_AUDIO_THREADS.BAT", "w")
    oFile.Write(GetThreadCmd())
    oFile.Close()
    oFile := FileOpen("2.MUX_MKV.BAT", "w")
    oFile.Write(GetMkvCmd(oFileNames[0]))
    oFile.Close()
    ; Use CMD extension to make it unique, we will use it to delete this file last
    oFile := FileOpen("3.DEL_SOURCE_FILES.CMD", "w")
    oFile.Write(GetDelCmd(oFileNames[0]))
    oFile.Close()
}

GetMkaCmd(oFileNames, iAudioStream, iDrcRatio) {
    sCmd := ""
    sCmd .= "@ECHO OFF`n"
    sCmd .= "IF NOT EXIST ""MKA"" MKDIR ""MKA""`n"
    For _, oFileName in oFileNames {
        sCmd .= "`n"
        sCmd .= "ffmpeg ^`n"
        sCmd .= "    -y -i """ oFileName["path"] """ ^`n"
        sCmd .= "    -map 0:a:" iAudioStream " -c:a:0 aac -b:a:0 192k -ac 2 ^`n"
        sCmd .= "        -filter:a:0 ""acompressor=ratio=" iDrcRatio ":mode=upward"" ^`n"
        sCmd .= "        ""MKA\" oFileName["mka"] """`n"
    }
    sCmd .= "`nPAUSE`n"
    Return sCmd
}

GetMkvCmd(oFileNames) {
    sCmd := ""
    sCmd .= "@ECHO OFF`n"
    sCmd .= "IF NOT EXIST ""MKV"" MKDIR ""MKV""`n"
    For _, oFileName in oFileNames {
        sCmd .= "`n"
        sCmd .= "mkvmerge ^`n"
        sCmd .= "    --output ""MKV\" oFileName["name"] ".mkv"" ^`n"
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
    }
    sCmd .= "`nPAUSE`n"
    Return sCmd
}

GetThreadCmd() {
    sCmd := ""
    sCmd := "@ECHO OFF`n"
    sCmd := "FOR %%F IN (""*AUDIO*_DRC*_THREAD*.BAT"") DO START CMD /C ""%%F""`n"
    Return sCmd
}

; GetDelCmd(oFileNames) {
;     sCmd := ""
;     sCmd .= "@ECHO OFF`n"
;     sCmd .= "CHOICE /M ""Delete source files?""`n"
;     sCmd .= "IF %ERRORLEVEL%==1 GOTO :DELETE_SOURCE ELSE GOTO :EOF`n`n"
;     sCmd .= ":DELETE_SOURCE`n"
;     For _, oFileName in oFileNames
;         sCmd .= "DEL """ oFileName["path"] """ ""MKA\" oFileName["mka"] """`n"
;     Return sCmd
; }

GetDelCmd(oFileNames) {
    sCmd := ""
    sCmd .= "@ECHO OFF`n"
    sCmd .= "CHOICE /M ""Delete source files?""`n"
    sCmd .= "IF %ERRORLEVEL%==1 GOTO :DELETE_SOURCE ELSE GOTO :EOF`n`n"
    sCmd .= ":DELETE_SOURCE`n"
    For _, oFileName in oFileNames
        sCmd .= "DEL """ oFileName["path"] """`n"
    sCmd .= "MOVE MKV\*.mkv`n"
    sCmd .= "RMDIR MKV`n" ; No /S /Q, because MKV must be empty already!
    sCmd .= "RMDIR /S /Q MKA`n"
    Loop, Files, *, D
        sCmd .= "RMDIR /S /Q """ A_LoopFileName """`n" ; Folders with subs
    sCmd .= "DEL /F /Q *.ahk`n"
    sCmd .= "DEL /F /Q *.ass`n"
    sCmd .= "DEL /F /Q *.srt`n"
    sCmd .= "DEL /F /Q *.bat`n"
    sCmd .= "DEL /F /Q *.cmd`n"
    ; Delete CMD script LAST!!! (Script deletes himself)
    Return sCmd
}

GetVideoFileNames(oFilePatterns, iDrcRatio, iThreads) {
    oFileNames := { 0: {} }
    Loop % iThreads
        oFileNames[A_Index] := []
    For _, sFilePattern in oFilePatterns
        Loop, Files, %sFilePattern%
        {
            sName := SubStr(A_LoopFileName, 1, -4) ; File name without extension
            sSuffix := "DRC" iDrcRatio "_UPWARD"
            oFileElement := { 0:""
                ; , "ext": A_LoopFileExt
                , "mka": sName "." sSuffix ".mka"
                , "name": sName
                , "path": A_LoopFilePath
                , "suffix": sSuffix }
            iIndex := Mod(A_Index, iThreads)
            ; Modulo returns 0 when [A_Index == iTreads]
            ; [A_Index] can't be 0 inside [Loop] command, make it equal [iThreads]
            iIndex := iIndex ? iIndex : iThreads
            ; FFMPEG: distribute to multiple BAT files for multi-threading
            oFileNames[iIndex].Push(oFileElement)
            ; MKVMERGE: all files in one BAT file
            oFileNames[0].Push(oFileElement)
        }
    Return oFileNames
}
