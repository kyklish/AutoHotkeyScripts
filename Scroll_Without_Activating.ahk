#Include <_COMMON_SETTINGS_>

;Scroll window without activating.
;SendMessage - waits respond [slow]. PostMessage - does not wait anything [fast].
;PostMessage doesn't work with remote desktop client, use SendMessage.
;If you want it to work with both x32 and x64 AutoHotKey, you will need:
;DllCall("WindowFromPoint", "int64", m_x | (m_y << 32), "Ptr")
;Use "Critical" section, for buffering events.

CoordMode, Mouse, Screen

WheelUp::
WheelDown::
MouseGetPos, x, y
hWnd := DllCall("WindowFromPoint", "int", x, "int", y) ; Retrieves a handle to the window that contains the specified point.
WHEEL_DELTA := 120 * (A_ThisHotkey = "WheelUp" ? 1 : -1)
PostMessage, 0x20A, WHEEL_DELTA << 16, (y << 16) | (x & 0xFFFF), , ahk_id %hWnd% ; WM_MOUSEWHEEL
return

/*
SetTimer, upd, 250
upd:
MouseGetPos, x, y, w1, c1, 1
MouseGetPos, , , w2, c2, 2
MouseGetPos, , , w3, c3, 3
hWnd := DllCall("WindowFromPoint", "int", x, "int", y)
SetFormat, Integer, hex
text = 
(
Win1 = %w1%
Ctr1 = %c1%
Win2 = %w2%
Ctr2 = %c2%
Win3 = %w3%
Ctr3 = %c3%
hWnd = %hWnd%
)
ToolTip, %text%
return
*/


/*
But, we don't really need WindowFromPoint. MouseGetPos returns the window ID and the name of the control under the mouse pointer. If we use them both in PostMessage, it works:
...
   MouseGetPos m_x, m_y, WinID, Ctrl
   PostMessage 0x20A,((A_ThisHotKey="WheelUp")-.5)*WCnt,(m_y<<16)|m_x,%Ctrl%,ahk_id %WinID%
...

Do you know why MouseGetPos returns a window ID which is different from what WindowFromPoint does?
	It's designed to report the parent window's unique ID, never the control's. This is because AHK is largely oriented toward parent windows when it comes to unique IDs. This philosophy may shift in the future since there is growing demand to operate upon controls individually.
By the way, the ahk_id technique can be used to directly operate on a control via PostMessage and other windowing commands. But you have to know its unique ID (HWND), either via the GetChildHWND() function (on the DllCall page) or some other function like the WindowFromPoint() you mentioned.
	Thanks, Chris. The Control, WinID combination from MouseGetPos seems to work, though.
*/


/*
WheelDown::                      ; scroll window under mouse
WheelUp::
CoordMode Mouse, Screen
SetBatchLines -1
SetMouseDelay -1
Process Priority,,R

WheelTime  = 500
WheelDelta:= 120 << 17           ; doubled
WheelMax  := 5 * WheelDelta      ; to optimize
CntDelta  := 40 << 17            ; code
Critical
If (A_ThisHotKey <> A_PriorHotKey OR A_TimeSincePriorHotkey > WheelTime)
	WCnt = %WheelDelta%
Else If (WCnt < WheelMax)
	WCnt+=  CntDelta
MouseGetPos m_x, m_y
If (m_x <> m_x0 OR m_y <> m_y0) {
	m_x0 = %m_x%
	m_y0 = %m_y%
	hw_m_target := DllCall("WindowFromPoint", "int",m_x, "int",m_y)
}
PostMessage 0x20A,((A_ThisHotKey="WheelUp")-.5)*WCnt,(m_y<<16)|m_x,,ahk_id %hw_m_target%
Return
*/
/*
CoordMode Mouse, Screen
#MaxThreadsPerHotkey 2
Loop 31
   S%A_index% := Round(.5*1.222**A_Index)*(120 << 17) ; doubled, to optimize code


WheelDown::
WheelUp::
   Speed := 1 + 300//(A_TickCount-Tick0+10)
   Tick0 = %Tick%
   Tick  = %A_TickCount%
   WCnt  += S%Speed%
   If (Tick < WTick + 30)
      Return
   WTick = %Tick%
   MouseGetPos m_x, m_y, WinID, Ctrl
   PostMessage 0x20A,((A_ThisHotKey="WheelUp")-.5)*WCnt,(m_y<<16)|m_x,%Ctrl%,ahk_id %WinID%
   WCnt = 0
Return
*/


/*
	Пример из документации	
	
	It has 2 parts merged, because some applications are responsive to one kind and others to the other.
	
	But it doesn't work in Excel, Access, etc.
	
	Would it be easy to adapt your vertical examples (which I hadn't had time to try yet) to horizontal scrolling?
	~RAlt & WheelDown::  ; Scroll right.
	ControlGetFocus, fcontrol, A
	MouseGetPos, , , id, control
	
	Loop 1  ; <-- Increase this value to scroll faster.
	{
		SendMessage, 0x114, 1, 0, %fcontrol%, A  ; 0x114 is WM_HSCROLL and the 1 after it is SB_LINELEFT.
		SendMessage, 0x114, 1, 0, %control%, A  ; 0x114 is WM_HSCROLL and the 1 after it is SB_LINELEFT.
	}
	return
*/


/*
	Example with IGNORING apps
	
	$WheelUp:: 
	MouseGetPos, m_x, m_y 
	hw_m_target := DllCall( "WindowFromPoint", "int", m_x, "int", m_y ) 
	WinGet,hoverproc,ProcessName,ahk_id %hw_m_target%
	WinGet,activeproc,ProcessName,A
	if (hoverproc = "trillian.exe" and activeproc = "trillian.exe")
	{
		Send,{WheelUp}
	}
	else 
	{
		SendMessage, 0x20A, 120 << 16, ( m_y << 16 )|m_x,, ahk_id %hw_m_target% 
	}
	return 
*/


/*
	WheelUp::
	WheelDown::
	MouseGetPos, MouseX, MouseY, WinID, ControlNN, 1
	WinGetClass, WinClass, % "ahk_id " WinID
	
  ; Scrolling TotalCommander's tabs
	If (WinClass = "TTOTAL_CMD" && RegExMatch(ControlNN, "TMyTabControl[12]"))
	{ PostMessage, 1075, % TC_Cmd := "400" (ControlNN = "TMyTabControl1" ? "1" : "2"), 0,, % "ahk_class " WinClass
	PostMessage, 1075, % TC_Cmd := "300" (A_ThisHotkey = "WheelDown" ? "5" : "6"), 0,, % "ahk_class " WinClass
	}
	
  ; Scrolling objects under cursor without activation.
	Else, PostMessage 0x20A, ((A_ThisHotKey="WheelUp")-.5)*A_EventInfo*(120<<17),(MouseY<<16)|MouseX, % ControlNN, % "ahk_id " WinID
		Return
*/

/*
CoordMode, Mouse, Screen
WheelDelta := 120 << 16 ;As defined by Microsoft
NormalScrollSpeed := 1 * WheelDelta
FastScrollSpeed := 3 * WheelDelta

FocuslessScroll(ScrollStep)
{
	Critical ;This fixes the stutter problem!
	
	MouseGetPos, m_x, m_y,, ControlClass1, 2
	MouseGetPos,,,, ControlClass2, 3
	
	m_x := m_x & 0xFFFF ;If m_x is negative (on multi-monitor configuration), all upper bits are 1. So you are losing the m_y information completely, when doing OR operation.
	lParam := (m_y << 16) | m_x ;Compute this just once
	
	SendMessage, 0x20A, ScrollStep, lParam,, ahk_id %ControlClass1%
	if (ControlClass1 != ControlClass2)
		SendMessage, 0x20A, ScrollStep, lParam,, ahk_id %ControlClass2%
}

WheelUp::FocuslessScroll(NormalScrollSpeed)
WheelDown::FocuslessScroll(-NormalScrollSpeed)
*/


/*
I found this topic very helpful and interesting. Since I was looking for the simplest possible solution without any bells and whistles, I trimmed the code down to this.
CoordMode, Mouse, Screen

WheelUp::Scroll(7864320)  ;WHEEL_DELTA := (120 << 16)
WheelDown::Scroll(-7864320)

Scroll(WHEEL_DELTA) {
 MouseGetPos, mX, mY, hWin, hCtrl, 2
 PostMessage, 0x20A, WHEEL_DELTA, (mY << 16) | mX,,% "ahk_id" (hCtrl ? hCtrl:hWin)
}  ;WM_MOUSEWHEEL
*/


/*
MinLinesPerNotch: Minimum number of lines scrolled per notch, which applies when scrolling slowly. This is the base scroll speed value.
MaxLinesPerNotch: Target maximum number of lines scrolled per notch, which applies when scrolling fast. The higher this value, the greater the acceleration.
AccelerationThreshold: The number of milliseconds elapsed between scroll notches below which acceleration becomes effective. The higher this value, the easier it is to engage acceleration (i.e. slower scrolling speeds will be able to make acceleration kick in). For example, if AccelerationThreshold = 200, scroll events more than or exactly 200 ms apart will scroll at a speed of MinLinesPerNotch, and scroll events less than 200 ms apart will scroll at speeds greater than MinLinesPerNotch up to MaxLinesPerNotch.
AccelerationType: Two flavours of acceleration are available: "P" (parabolic) or "L" (linear), details below. Specifying a random string for this parameter results in the linear acceleration being used by default. The parabolic curve produces a smoother scroll speed rise giving you a more precise feel, whilst the linear curve offers a snappier feel.
StutterThreshold: Stutter is essentially a rapid succession of spurious up and/or down scroll events. When stutter occurs, the scrolled control will momentarily shake up and down rather than move in a continuous unidirectional fashion. Stutter is more common with cheap mice. The StutterThreshold parameter adjusts the sensitivity of the stutter filter. For example, if StutterThreshold = 14, a scroll event that occurs less than 14 ms after the previous scroll event will be regarded as spurious and be completely ignored.

Return value: None.

Parameter ranges: I haven't built any safeguards into this code, so for best results keep parameters within the following ranges:

0 >= StutterThreshold >= AccelerationThreshold
- StutterThreshold <= 0 disables stutter filtering (so stutter may occur, not recommended)
- StutterThreshold > AccelerationThreshold disables scrolling when AccelerationThreshold is reached. This can be used to prevent fast scrolling.
- Behaviour for other scenarious is undefined.

0 <= MinLinesPerNotch <= MaxLinesPerNotch (both should be integers, otherwise implicit rounding may produced unexpected behaviour)
- MinLinesPerNotch = 0 disables scrolling
- MinLinesPerNotch = MaxLinesPerNotch disables acceleration (constant lines-per-notch regardless of scroll speed)
- Behaviour for other scenarios is undefined.[/list][/list]
On my system, I find that the following choice of values feels natural and will be a good starting point for first-time users. However, the choice of values is very personal and is also largely dependent on the mouse being used.

- Control Panel > Mouse Settings > Wheel > Scroll lines per notch: 1
- MinLinesPerNotch: 1
- MaxLinesPerNotch: 5
- AccelerationThreshold: 100 ms
- AccelerationType: "L"
- StutterThreshold: 10 ms

Note: Value in Control Panel Mouse Settings acts as a multiplier for both MinLinesPerNotch and MaxLinesPerNotch.

More about the acceleration curve:

The graph below illustrates the meaning of the acceleration parameters. In this example, the following values have been used:

- MinLinesPerNotch: 1 (red horizontal line)
- MaxLinesPerNotch: 10 (top black dot)
- AccelerationThreshold: 20 ms (at bottom black dot, which is the vertex of the parabola when AccelerationType = "P")
- AccelerationType: "P" (black curve, a parabola), and "L" (green straight line).
- StutterThreshold: In this case it is 0, a higher value would simply

The vertical axis represents lines per notch and the horizontal axis represents scroll event separation in milliseconds.

Note: In this graph, the maximum scroll speed of 10 lines per notch is in theory impossible to reach because two scroll events must be some time apart, i.e., they cannot occur simultaneously. In practice it can be reached because a value of say 9.6 lines per notch can be reached, and the script rounds the values up or down to the nearest integer, therefore 9.6 would become 10.
*/

/*
;Directives
#NoEnv
#SingleInstance Force
#MaxHotkeysPerInterval 100 ;Avoid warning when mouse wheel turned very fast

;Autoexecute code
MinLinesPerNotch := 1
MaxLinesPerNotch := 5
AccelerationThreshold := 100
AccelerationType := "L" ;Change to "P" for parabolic acceleration
StutterThreshold := 10

;Function definitions

;See above for details
FocuslessScroll(MinLinesPerNotch, MaxLinesPerNotch, AccelerationThreshold, AccelerationType, StutterThreshold)
{
	SetBatchLines, -1 ;Run as fast as possible
	CoordMode, Mouse, Screen ;All coords relative to screen
	
	;Stutter filter: Prevent stutter caused by cheap mice by ignoring successive WheelUp/WheelDown events that occur to close together.
	If(A_TimeSincePriorHotkey < StutterThreshold) ;Quickest succession time in ms
		If(A_PriorHotkey = "WheelUp" Or A_PriorHotkey ="WheelDown")
			Return

	MouseGetPos, m_x, m_y,, ControlClass2, 2
	ControlClass1 := DllCall( "WindowFromPoint", "int64", (m_y << 32) | (m_x & 0xFFFFFFFF), "Ptr") ;32-bit and 64-bit support

	lParam := (m_y << 16) | (m_x & 0x0000FFFF)
	wParam := (120 << 16) ;Wheel delta is 120, as defined by MicroSoft

	;Detect WheelDown event
	If(A_ThisHotkey = "WheelDown" Or A_ThisHotkey = "^WheelDown" Or A_ThisHotkey = "+WheelDown" Or A_ThisHotkey = "*WheelDown")
		wParam := -wParam ;If scrolling down, invert scroll direction
	
	;Detect modifer keys held down (only Shift and Control work)
	If(GetKeyState("Shift","p"))
		wParam := wParam | 0x4
	If(GetKeyState("Ctrl","p"))
		wParam := wParam | 0x8

	;Adjust lines per notch according to scrolling speed
	Lines := LinesPerNotch(MinLinesPerNotch, MaxLinesPerNotch, AccelerationThreshold, AccelerationType)

	If(ControlClass1 != ControlClass2)
	;If(ControlClass1 != ControlClass2 and !MouseIsOver("ahk_class TscShellContainerClass")) ;Exception for "Microsoft Remote Desktop"
	{
		Loop %Lines%
		{
			SendMessage, 0x20A, wParam, lParam,, ahk_id %ControlClass1%
			SendMessage, 0x20A, wParam, lParam,, ahk_id %ControlClass2%
		}
	}
	Else ;Avoid using Loop when not needed (most normal controls). Greately improves momentum problem!
	{
		SendMessage, 0x20A, wParam * Lines, lParam,, ahk_id %ControlClass1%
	}
}

;All parameters are the same as the parameters of FocuslessScroll()
;Return value: Returns the number of lines to be scrolled calculated from the current scroll speed.
LinesPerNotch(MinLinesPerNotch, MaxLinesPerNotch, AccelerationThreshold, AccelerationType)
{
	T := A_TimeSincePriorHotkey

	;Normal slow scrolling, separationg between scroll events is greater than AccelerationThreshold miliseconds.
	If((T > AccelerationThreshold) Or (T = -1)) ;T = -1 if this is the first hotkey ever run
	{
		Lines := MinLinesPerNotch
	}
	;Fast scrolling, use acceleration
	Else
	{
		If(AccelerationType = "P")
		{
			;Parabolic scroll speed curve
			;f(t) = At^2 + Bt + C
			A := (MaxLinesPerNotch-MinLinesPerNotch)/(AccelerationThreshold**2)
			B := -2 * (MaxLinesPerNotch - MinLinesPerNotch)/AccelerationThreshold
			C := MaxLinesPerNotch
			Lines := Round(A*(T**2) + B*T + C)
		}
		Else
		{
			;Linear scroll speed curve
			;f(t) = Bt + C
			B := (MinLinesPerNotch-MaxLinesPerNotch)/AccelerationThreshold
			C := MaxLinesPerNotch
			Lines := Round(B*T + C)
		}
	}
	Return Lines
}

;All hotkeys with the same parameters can use the same instance of FocuslessScroll(). No need to have separate calls unless each hotkey requires different parameters (e.g. you want to disable acceleration for Ctrl-WheelUp and Ctrl-WheelDown). If you want a single set of parameters for all scrollwheel actions, you can simply use *WheelUp:: and *WheelDown:: instead.

#MaxThreadsPerHotkey 6 ;Adjust to taste. The lower the value, the lesser the momentum problem on certain smooth-scrolling GUI controls (e.g. AHK helpfile main pane, WordPad...), but also the lesser the acceleration feel. The good news is that this setting does no affect most controls, only those that exhibit the momentum problem. Nice.
;Scroll with acceleration
WheelUp::
WheelDown::FocuslessScroll(MinLinesPerNotch, MaxLinesPerNotch, AccelerationThreshold, AccelerationType, StutterThreshold)
;Ctrl-Scroll zoom with no acceleration (MaxLinesPerNotch = MinLinesPerNotch).
^WheelUp::
^WheelDown::FocuslessScroll(MinLinesPerNotch, MinLinesPerNotch, AccelerationThreshold, AccelerationType, StutterThreshold)
;If you want zoom acceleration, replace above line with this:
;FocuslessScroll(MinLinesPerNotch, MaxLinesPerNotch, AccelerationThreshold, AccelerationType, StutterThreshold)
#MaxThreadsPerHotkey 1 ;Restore AHK's default  value i.e. 1
*/


/*
FocuslessScrollHorizontal(MinLinesPerNotch, MaxLinesPerNotch, AccelerationThreshold, AccelerationType, StutterThreshold)
{
	SetBatchLines, -1 ;Run as fast as possible
	CoordMode, Mouse, Screen ;All coords relative to screen

	;Stutter filter: Prevent stutter caused by cheap mice by ignoring successive WheelUp/WheelDown events that occur to close together.
	If(A_TimeSincePriorHotkey < StutterThreshold) ;Quickest succession time in ms
		If(A_PriorHotkey = "WheelUp" Or A_PriorHotkey ="WheelDown")
			Return

	MouseGetPos, m_x, m_y,, ControlClass2, 2
	ControlClass1 := DllCall( "WindowFromPoint", "int64", (m_y << 32) | (m_x & 0xFFFFFFFF), "Ptr") ;32-bit and 64-bit support

	ctrlMsg := 0x114	; WM_HSCROLL
	wParam := 0 		; Left

	;Detect WheelDown event
	If(A_ThisHotkey = "WheelDown" Or A_ThisHotkey = "^WheelDown" Or A_ThisHotkey = "+WheelDown" Or A_ThisHotkey = "*WheelDown")
		wParam := 1 ; Right

	;Adjust lines per notch according to scrolling speed
	Lines := LinesPerNotch(MinLinesPerNotch, MaxLinesPerNotch, AccelerationThreshold, AccelerationType)

	Loop %Lines%
	{
		SendMessage, ctrlMsg, wParam, 0,, ahk_id %ControlClass1%
		If(ControlClass1 != ControlClass2)
			SendMessage, ctrlMsg, wParam, 0,, ahk_id %ControlClass2%
	}
}

;Shift-Scroll scroll horizontally
+WheelUp::
+WheelDown::FocuslessScrollHorizontal(MinLinesPerNotch, MaxLinesPerNotch, AccelerationThreshold, AccelerationType, StutterThreshold)
*/
