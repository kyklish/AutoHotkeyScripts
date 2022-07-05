#NoEnv ;It significantly improves performance whenever empty variables are used in an expression or command. It prevents script bugs caused by environment variables whose names unexpectedly match variables used by the script.
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Client
CoordMode, Pixel, Client
CoordMode, ToolTip, Screen
SendMode Input ;"Input" mode are generally faster and more reliable. In addition, they buffer any physical keyboard or mouse activity during the send, which prevents the user's keystrokes from being interspersed with those being sent.
#SingleInstance Force
SetTitleMatchMode 2 ;A window's title can contain WinTitle anywhere inside it to be a match.
DetectHiddenWindows On
#WinActivateForce ;Skips the gentle method of activating a window and goes straight to the forceful method.
;SetControlDelay 1 ;Sets the delay that will occur after each control-modifying command (Control, ControlMove, ControlClick, ControlFocus ...). Time in milliseconds. Use -1 for no delay at all, 0 for the smallest possible delay. If unset, the default delay is 20.
;SetWinDelay 0 ;Sets the delay that will occur after each windowing command (WinActivate ...). -//- If unset, the default delay is 100.
SetKeyDelay -1 ;Sets the delay that will occur after each keystroke sent by Send and ControlSend. -//- The default delay for the traditional SendEvent mode is 10. For SendPlay mode, the default delay is -1. The default PressDuration (below) is -1 for both modes.
SetMouseDelay -1 ;Sets the delay that will occur after each mouse movement or click. -//- The default delay is 10.
SetBatchLines -1 ;Determines how fast a script will run (affects CPU utilization). Use -1 to never sleep (run at maximum speed). See Help.

#NoTrayIcon
;Menu, Tray, NoIcon ;The only drawback of using Menu, Tray, NoIcon at the very top of the script is that the tray icon might be briefly visible when the script is first launched. To avoid that, use #NoTrayIcon instead.
Menu, Tray, Tip, %A_ScriptName%

;В некоторых играх не работают горячие клавиши AutoHotKey скриптов без этого хука.
#UseHook ;The responsiveness of hotkeys might be better under some conditions if the keyboard hook is used. Turning this directive ON is equivalent to using the $ prefix in the definition of each affected hotkey. By default, hotkeys that use the keyboard hook cannot be triggered by means of the Send command.
