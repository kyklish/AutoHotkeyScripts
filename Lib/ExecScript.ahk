; ExecScript: Executes the given code as a new AutoHotkey process.
ExecScript(Script, Wait:=true)
{
	shell := ComObjCreate("WScript.Shell")
	exec := shell.Exec("AutoHotkey.exe /ErrorStdOut *")
	exec.StdIn.Write(Script)
	exec.StdIn.Close()
	if Wait
		return exec.StdOut.ReadAll()
	else
		return exec.ProcessID
}

; Example:
;InputBox expr,, Enter an expression to evaluate as a new script.,,,,,,,, Asc("*")
;result := ExecScript("FileAppend % (" expr "), *")
;MsgBox % "Result: " result
