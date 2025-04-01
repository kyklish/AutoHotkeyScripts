; Write text to %A_Temp%\%A_ScriptName%.log. Call func once without params on script's launch to write %A_NOW% (mark start). Call func with desired text after that.
WriteLog(sText := "") {
    If (!sText)
        FileAppend, ====%A_NOW%====`n, %A_Temp%\%A_ScriptName%.log
    Else
        FileAppend, %sText%`n, %A_Temp%\%A_ScriptName%.log
}
