MsgBoxA(oArray, sComment := "") ;print array in one line
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