;Exception will break execution, unless you will use "catch e {}".
;Usage:
;   #Include <Error>
;
;   CheckError(sMessage [, aExtra, sWhat, sFile, sLine, sFuncNameFinally]) - use this, if command set ErrorLevel
;   throw Exception(sMessage, , aExtra) - use this in all other cases

;Example:
/*
    foo()
    {
        path := "R:\TestFile.png"

        ImageSearch, , , 295, 85, 325, 115, %path%
        CheckError("ImageSearch", path, A_ThisFunc, A_LineFile, A_LineNumber, Func("final"))

        if !FileExist(path)
            throw Exception("File not exist", , path)
    }

    final()
    {
        WinHide
    }
*/

OnError("ShowError")

CheckError(sMessage, aExtra := "", sWhat := "", sFile := "", sLine := "", sFuncNameFinally := "") ; sLine := A_LineNumber ==> Unsupported parameter default.
{
    if (ErrorLevel)
        throw { message: sMessage, extra: aExtra, what: sWhat, file: sFile, line: sLine, err: ErrorLevel, func: sFuncNameFinally }
}

ShowError(e)
{
    what := e.what, line := e.line, message := e.message, extra := e.extra, err := e.err, func := e.func
    SplitPath, % e.file, file
    ;------------------ERROR MESSAGE---------------------
    if (err)
        sText := "Error Occurs!`n`n"
    else
        sText := "Exception thrown!`n`n"
    sText = %sText%
    (LTrim
        File: %file%
        What: %what%
        Line: %line%
        Message: %message%
        Extra: %extra%
    )
    if (err)
        sText .= "`nErrorLevel: " err
    sText .= "`n`n"
    sText = %sText%
    (LTrim
        EXIT FROM CURRENT THREAD.
        To change this behavior edit ".\Lib\Error.ahk"
    )
    ;----------------------------------------------------
    MsgBox, 16, , %sText%
    if (func)
        Func(func).Call()
    ;ExitApp ;Uncomment this if you want exit entire script
    return true ; block default error dialog
}
