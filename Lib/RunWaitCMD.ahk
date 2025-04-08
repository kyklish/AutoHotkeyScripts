; This is example from Autohotkey.chm, I add some fixes:
;   A_ScriptDir must be in double quotes, because in path may be spaces
;   RunWaitOne did not properly wait result from ran program. So best way use RunWaitMany, it's more reliable.
;   Rename RunWaitMany to RunWainCMD

; The following can be used to run a command and retrieve its output:
/*
    MsgBox % RunWaitCMD("dir """ . A_ScriptDir . """")
*/
; To include an actual quote-character inside a literal string, specify two consecutive quotes as shown twice in this example:
; "She said, ""An apple a day.""".

; The following can be used to  run multiple commands in one go and retrieve their output:
/*
    MsgBox % RunWaitCMD("
(
echo Put your commands here,
echo each one will be run,
echo and you'll get the output.
)")
*/

RunWaitCMD(commands) {
    ; WshShell object: http://msdn.microsoft.com/en-us/library/aew9yb99
    shell := ComObjCreate("WScript.Shell")
    ; Open cmd.exe with echoing of commands disabled
    exec := shell.Exec(A_ComSpec " /Q /K echo off")
    ; Send the commands to execute, separated by newline
    exec.StdIn.WriteLine(commands "`nexit")  ; Always exit at the end!
    ; Read and return the output of all commands
    return exec.StdOut.ReadAll()
}

;To run HIDDEN you must use shell.Run command, but it not very useful for CMD
