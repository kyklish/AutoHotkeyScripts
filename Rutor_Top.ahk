#Include <_COMMON_SETTINGS_>
#Include <Error>

savePath := "F:\"

FormatTime data, , yy.MM.dd
fileName := "Rutor.info Top " . data . ".html"
tempFile := A_Temp . "\" . fileName
resultFile := RTrim(savePath, "\") . "\" . fileName
RunWait, %ComSpec% /c wget --output-document="%fileName%" rutor.info/top , %A_Temp%, Hide
FileRead, html, %tempFile%
CheckError("Can't open file")
html := RegExReplace(html, "i)(?<=href="")(?=/)", "http://rutor.info") ; href="/ --> href="http://rutor.info/
if (FileExist(resultFile))
	FileDelete, %resultFile%
FileAppend, %html%, %resultFile%
FileDelete, %tempFile%