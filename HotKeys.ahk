﻿#Include <_COMMON_SETTINGS_>

;-------------------------------------------------------------------------------------
; Ctrl+L Alt+D - adress bar
; Ctrl+E - Search bar

Process, Priority, , H
SetKeyDelay, 50, 10 ; задержки при нажатиях (only Event mode)

GroupAdd, Browser, ahk_exe opera.exe
GroupAdd, Browser, ahk_exe chrome.exe
GroupAdd, Browser, ahk_exe firefox.exe

GroupAdd, AHK_Studio, AHK Studio ahk_exe AutoHotkey.exe
GroupAdd, AHK_Studio, Variable Browser ahk_exe AutoHotkey.exe
debugger := "Variable Browser ahk_exe AutoHotkey.exe"

GroupAdd, PDF_DJVU_Viewer, ahk_exe SumatraPDF.exe
GroupAdd, PDF_DJVU_Viewer, ahk_exe STDUViewerApp.exe

GroupAdd, Desktop, ahk_class Progman
GroupAdd, Desktop, ahk_class WorkerW
GroupAdd, Desktop, ahk_class Shell_TrayWnd

#IfWinActive ahk_group Browser
;^b:: SendEvent, ^l^v{Enter} ; Ctrl+B = (Ctrl+L Ctrl+V Enter) - [вместо Ctrl+L можно использовать Ctrl+E] как в старой Opera, вставить ссылку из буфера обмена и перейти по ней. Иронично что в новой Опере не работает нормально, если включена любая не английская раскладка клавиатуры.
;^b:: SendEvent, {Ctrl down}{ASC 00108}{Ctrl up}{Ctrl down}{ASC 00118}{Ctrl up}{Enter}
;^b:: ControlSend,, ^{l}^{v}{Enter}, A
;^b:: SendInput, {Ctrl down}l{Ctrl up}{Ctrl down}v{Ctrl up}{Enter}
^b:: SendEvent, ^{vk4C}^{vk56}{Enter} ; only working variant for Opera!!!
^z:: SendEvent, ^+{vk54} ; Ctrl+Z = Ctrl+Shift+T - restore closed tab
^d:: ; Ctrl+D - поиск в YouTube выделенного текста
Clipboard := "" ; Empty the clipboard
SendEvent, ^{vk43} ; Ctrl+C
ClipWait, 2
if (ErrorLevel) {
    MsgBox, The attempt to copy text onto the clipboard failed.
    return
}
Clipboard := "https://www.youtube.com/results?search_query=" . StrReplace(Clipboard, A_Space, "+")
Gosub, ^b
return
F9:: SendEvent, ^+{Tab} ; Prev Tab
F10:: SendEvent, ^{Tab} ; Next Tab

+Delete:: ; delete mail
; SendMode - Also makes Click and MouseMove/Click/Drag use the specified method
; When you wish to use a different mode for a particular mouse event the easiest way to do this is via {Click}. For example: SendEvent {Click 100, 200}
; Включить в Gmail 'Быстрые клавиши'
if WinActive("Gmail") {
	;MouseGetPos, X, Y
	Send {#} ; or Click 416, 158 ; click 'Trash' icon to delete email
	WinWait, Inbox, , 3
	if !ErrorLevel
		Send, {Enter} ; or Click 416, 195 ; open next email
	;MouseMove, X, Y
}
return

;-------------------------------------------------------------------------------------

;By default in Win7 pressing Backspace in Explorer goes back in history, but in WinXP - goes back in file system hierarchy
;This hotkey brings back WinXP behavior
#IfWinActive, ahk_class CabinetWClass
Backspace::
ControlGet renameStatus, Visible, , Edit1, A
ControlGetFocus focussed, A
if(renameStatus != 1 && (focussed = "DirectUIHWND3" || focussed = "SysTreeView321")) {
	Send {Alt Down}{Up}{Alt Up}
} else {
	Send {Backspace}
}
return

;-------------------------------------------------------------------------------------

#IfWinActive, ahk_group PDF_DJVU_Viewer
Pause:: ;Close app and open next file from Total Commander or Explorer
Send, !{F4}
Sleep 250
if (WinExist("ahk_exe TOTALCMD.exe") || WinExist("ahk_class CabinetWClass")) {
	WinActivate
	Send, {Down}{Enter}
}
return

;-------------------------------------------------------------------------------------

#IfWinActive, ahk_class ConsoleWindowClass
^v:: ;Paste text to CMD
Send, {Raw}%Clipboard% ; Raw mode - SendRaw or {Raw}: The characters ^+!#{} are interpreted literally rather than translating {Enter} to Enter, ^c to Control+C, etc.
;Send, {Text}%Clipboard% ; Raw mode - SendRaw or {Raw}: The characters ^+!#{} are interpreted literally rather than translating {Enter} to Enter, ^c to Control+C, etc.
;ControlSend, , {Raw}%Clipboard%, ahk_exe cmd.exe  ; Send directly to a command prompt window. {Text} sends a stream of characters rather than keystrokes. Like Raw mode, Text mode causes the following characters to be interpreted literally: ^+!#{}.
;ControlSend, , {Text}%Clipboard%, ahk_exe cmd.exe  ; Send directly to a command prompt window. {Text} sends a stream of characters rather than keystrokes. Like Raw mode, Text mode causes the following characters to be interpreted literally: ^+!#{}.
;WinMenuSelectItem ahk_exe cmd.exe,, 0&, Edit, Paste ; Paste a command into cmd.exe without activating the window. Menu can be 0& to select an item within the window's system menu, which typically appears when the user presses Alt+Space or clicks on the icon in the window's title bar.
return
!F4:: Send, exit{Enter}

;-------------------------------------------------------------------------------------

#IfWinActive, ahk_exe notepad++.exe
; Debug AutoHotkey Scripts
F7::ControlClick, TBitBtn10,,,,, NA ;Step Into
F8::ControlClick, TBitBtn9,,,,, NA ;Step Over
+F8::ControlClick, TBitBtn8,,,,, NA ;Step Out
F9::ControlClick, TBitBtn2,,,,, NA ;Run
^F9::PostMessage, 0x111, 22008 ; Toggle BreakPoint

;-------------------------------------------------------------------------------------

#IfWinActive ahk_group AHK_Studio
; Debug AutoHotkey Scripts
F7::ControlClick, Button2, %debugger%,,,, NA
F8::ControlClick, Button4, %debugger%,,,, NA
+F8::ControlClick, Button3, %debugger%,,,, NA
F9::ControlClick, Button1, %debugger%,,,, NA

;-------------------------------------------------------------------------------------

#IfWinActive, SsdReady
#Up::
WinGetPos,,, Width
WinMove,,, (A_ScreenWidth/2)-(Width/2), 0,, A_ScreenHeight
Return

;-------------------------------------------------------------------------------------

;In Total Commander hit Alt+F7 to open search window, it will have "ahk_class TFindFile"
;Then hit Alt+F7 again to check checkbox "С текстом:" to find text in files.
#IfWinActive, ahk_class TFindFile
!F7::Control, Check, , TCheckBox11
#IfWinActive, ahk_class TDLGUNZIPALL
!F9::Control, Check, , TCheckBox1

;-------------------------------------------------------------------------------------

#IfWinActive

;-------------------------------------------------------------------------------------

;Simple word-delete shortcuts for all Edit controls.
#If ActiveControlIsOfClass("Edit")
^BS::Send ^+{Left}{Del}
^Del::Send ^+{Right}{Del}

ActiveControlIsOfClass(Class) {
	ControlGetFocus, FocusedControl, A
	ControlGet, FocusedControlHwnd, Hwnd,, %FocusedControl%, A
	WinGetClass, FocusedControlClass, ahk_id %FocusedControlHwnd%
	return (FocusedControlClass = Class)
}

;-------------------------------------------------------------------------------------
#If
;-------------------------------------------------------------------------------------

;Win+Fxx
#F1::Run_AsUser(A_ComSpec)
#F2::Run_AsAdmin(A_ComSpec)
;#F2::Run_AsUser("D:\SERGEY\Options\Program Files\BAT\Browser\Opera.bat")
;#F3::Run_AsUser("D:\SERGEY\Options\Program Files\BAT\Browser\Chrome.bat")
;#F4::Run_AsUser("D:\SERGEY\Options\Program Files\BAT\Browser\Firefox.bat")
;#F5::Run_AsUser("D:\SERGEY\Options\Program Files\SimpleDLNA\SimpleDLNA.exe")
;#F11::Run_ScriptAsUser("D:\SERGEY\Options\Program Files\AutoHotkey\Scripts\Set_Windows_Theme.ahk", "%LocalAppData%\Microsoft\Windows\Themes\MyTheme.theme")
;#F12::Run_ScriptAsUser("D:\SERGEY\Options\Program Files\AutoHotkey\Scripts\Set_Windows_Theme.ahk", "%LocalAppData%\Microsoft\Windows\Themes\win7msa.theme")
#F11::Run, D:\SERGEY\Options\Program Files\Winaero Theme Switcher\ThemeSwitcher.exe "C:\Users\Fixer\AppData\Local\Microsoft\Windows\Themes\MyTheme.theme"
#F12::Run, D:\SERGEY\Options\Program Files\Winaero Theme Switcher\ThemeSwitcher.exe "C:\Users\Fixer\AppData\Local\Microsoft\Windows\Themes\win7msa.theme"


;CTRL+ALT+SHIFT
;Empty Recycle Bin ;FileRecycleEmpty and "nircmd.exe empybin" not work, if launched from another account!!!
^!+k::Run_AsUser("D:\SERGEY\Options\Program Files\NirLauncher\NirSoft\nircmd.exe", "emptybin")
^!+m::Run_AsAdmin("D:\SERGEY\Options\Program Files\NirLauncher\Sysinternals\Procmon.exe") ;Process Monitor
^!+p::Run_AsAdmin("D:\SERGEY\Options\Program Files\NirLauncher\Sysinternals\procexp64.exe") ;Process Explorer
;Reboot ;AutoHotkey commands "Shutdown" not work, if launched from another account!!!
^!+r::Run_AsUser("D:\SERGEY\Options\Program Files\NirLauncher\NirSoft\nircmd.exe", "exitwin reboot") ;there is "force" parameter can be used
^!+s::Run_AsUser("D:\SERGEY\Options\Program Files\NirLauncher\NirSoft\nircmd.exe", "exitwin shutdown") ;Shutdown
^!+l:: ;Logoff
MsgBox, % 4 + 256,, Log off?
IfMsgBox, Yes
	Run_AsUser("D:\SERGEY\Options\Program Files\NirLauncher\NirSoft\nircmd.exe", "exitwin logoff")
return


;WIN+CTRL+ALT
#^!1::Run_AsUser("D:\SERGEY\Options\Program Files\1by1\1by1.exe", "/r")
#^!2::Run_AsUser("D:\SERGEY\Options\Program Files\Download Master Portable\dmaster.exe")
#^!3::Run_AsUser("D:\SERGEY\Options\Program Files\uTorrent\2.0.4\utorrent.exe", "/RECOVER /NOINSTALL")
#^!4::Run_AsUser("D:\SERGEY\Options\Program Files\uTorrent\3.5.5\uTorrent.exe", "/RECOVER /NOINSTALL")
#^!0:: ;Eject\Close CD tray.
Drive, Eject
if (A_TimeSinceThisHotkey < 1000) ;If the command completed quickly, the tray was probably already ejected. ; Adjust this time if needed.
	Drive, Eject, , 1 ;In that case, retract it.
return


;WIN+CTRL+ALT
;SSD - Visible - 1:BenQ - 2:Edifier - 3:TV
#^!F1::Run_AsUser("D:\SERGEY\Options\Program Files\SSD (Set Sound Device)\SSD.exe", "1")
#^!F2::Run_AsUser("D:\SERGEY\Options\Program Files\SSD (Set Sound Device)\SSD.exe", "2")
#^!F3::Run_AsUser("D:\SERGEY\Options\Program Files\SSD (Set Sound Device)\SSD.exe", "3")
#^!F4::WinClose, A ;Force close active window


;WIN+CTRL+ALT
#^!f::Run_AsUser("C:\Users\Fixer\AppData\Local\FluxSoftware\Flux\flux.exe")
#^!k::Run_AsUser("D:\SERGEY\Options\Program Files\NirLauncher\Sysinternals\pskill.exe", "-t mpc-hc.exe") ;PSKill MPC-HC
#^!m::Run_AsUser("D:\SERGEY\Options\Program Files\NirLauncher\NirSoft\nircmd.exe", "monitor off")


^+f::Run_AsUser("D:\SERGEY\Options\Program Files\Everything x64\Everything.exe")
!+Esc::Run_AsAdmin("C:\Windows\System32\resmon.exe") ;Resource Monitor
#`::WinSet, AlwaysOnTop, Toggle, A
#Insert::Run_AsAdmin("D:\SERGEY\Options\Program Files\ClickMonitorDDC\ClickMonitorDDC.exe", "t b 0 t b 50")
Launch_Mail::Run_AsUser("D:\SERGEY\Options\Program Files\Sylpheed\sylpheed.exe")

/*
	!+t:: ;Hide/Show taskbar & Desktop icons
	If (toggle := !toggle) {
		WinHide, ahk_class Shell_TrayWnd ; TaskBar
		WinHide, Start ahk_class Button  ; "Start" button
		
		;WinActivate, ahk_class WorkerW
		;WinWaitActive, ahk_class WorkerW, , 0
		;If (!ErrorLevel)
			;Control, Hide,, SysListView321, ahk_class WorkerW ; Icons
	} Else {
		WinShow, ahk_class Shell_TrayWnd
		WinShow, Start ahk_class Button
		
		;WinActivate, ahk_class WorkerW
		;WinWaitActive, ahk_class WorkerW, , 0
		;If (!ErrorLevel)
			;Control, Show,, SysListView321, ahk_class WorkerW
	}
	return
	
*/

#IfWinActive ahk_group Desktop
Pause:: ShowHelpWindow("
(
[Browser]
   ^B -> Paste clipboard and Go
   ^D -> Search in YouTube selected text
   ^Z -> Restore recently closed tab
   F9 -> Previous Tab
  F10 -> Next Tab
 +Del -> Delete main in Gmail and open next
[Explorer]
 BS -> Go back in file system hierarchy
[SumatraPDF + STDU Viewer]
 Pause -> Close app and open next file from Total Commander or Explorer
[CMD]
  ^V -> Paste text to CMD
 !F4 -> Close CMD
[Notepad++] debug AutoHotkey scripts
[AHK Studio] debug AutoHotkey scripts
  F7 -> Step Into
  F8 -> Step Over
 +F8 -> Step Out
  F9 -> Run
[SsdReady]
 #Up -> Maximize window
[Total Commander]
 !F7 -> Search text in files
 !F9 -> Unpack archive to folder
[Edit]
  ^BS -> Delete word to left
 ^Del -> Delete word to right
[Win+Fxx]
  #F1 -> CMD User
  #F2 -> CMD Admin
 #F11 -> Set Dark Windows Theme
 #F12 -> Set White Windows Theme
[Ctrl+Alt+Shift]
 ^!+K -> Empty Recycle Bin
 ^!+M -> Process Monitor
 ^!+P -> Process Explorer
 ^!+R -> Reboot
 ^!+S -> Shutdown
 ^!+L -> Logoff
[Win+Ctrl+Alt]
 #^!1 -> 1by1
 #^!2 -> Download Master
 #^!3 -> uTorrent
 #^!0 -> Eject\Close CD tray
[Win+Ctrl+Alt]
 #^!F1 -> SSD - BenQ
 #^!F2 -> SSD - Edifier
 #^!F3 -> SSD - TV
 #^!F4 -> Force close active window
[Win+Ctrl+Alt]
 #^!F -> f.lux
 #^!K -> Kill MPC-HC
 #^!M -> Monitor Off
[Other]
  Mail -> Sylpheed
 !+Esc -> Resource Monitor
   ^+F -> Everything x64
  #Ins -> Toggle monitor brightness
    #`` -> Always On Top
   !+t -> Hide/Show taskbar (Disabled)
)")
