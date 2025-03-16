; Print array in one line
MsgBoxA(oArray, sComment := "")
{
    str := ""
    if (sComment) {
        str .= sComment "`n`n"
    }
    str .= "["
    for k, v in oArray
        str .= v ", "
    str := SubStr(str, 1, -2)
    str .= "]"
    MsgBox % str
}
