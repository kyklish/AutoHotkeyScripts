#Include <_COMMON_SETTINGS_>

; С админ правами вешает Explorer!!!
Reload_AsUser()

if (A_IsAdmin) {
	MsgBox, Run as regular user, NOT admin!!!
	ExitApp
}


; Передвигаем иконки в трее, согласно содержимому CSV файла
; Формат CSV файла:
;	первое значение - EXE
;	последующие - если у одного приложения есть несколько иконок, то это RegExp части строки,
;				  по которой находятся нужные иконки [текст ToolTip-а] (CaseSensitive по-умолчанию), 
;				  этот параметр можно опустить, если у приложения только одна иконка
; Порядок строк в CSV файле определяет результирующий порядок иконок
; Сортировка вниз работает, даже если указаны одинаковые ToolTip-ы для поиска
; Сортировка вверх не срабоает в этом случае, нужно указывать уникальный текст поиска
; Можно посмотреть всю инфу по текущим иконкам с помощью функции ShowTrayInfo()

csvFile := "Tray_Icon_Organize.csv"
iUpdatePeriod := 2000 ; период автосортировки

OnMessage(0x5555, "AutoStartObjectsComplete") ; Wait message from AutoStartObjects.ahk script

AutoStartObjectsComplete() ; Returning from this function quickly is often important
{	; Heavy job don't work here, because script didn't respond to windows messages here
	global iUpdatePeriod
	SetTimer, SortIconsUp, %iUpdatePeriod%
}

;Sleep % 4*60*1000 ;иконка ОС "Action Center" (белый флажок) появляются через минуты 3, поэтому такая большая задержка
;Sleep % 45*1000 ;ждем пока запустятся приложения из скрипта автозапуска
;TrayIcon_SortUp(csvFile)
;SetTimer, SortIconsUp, %iUpdatePeriod%

;#!v:: TrayIcon_SortDown(csvFile)
#!c:: TrayIcon_SortUp(csvFile)
#!b:: ShowTrayInfo()


SortIconsUp:
iIcons := TrayIcon_GetInfo().Count()
if (iIcons != iIconsPrev) {
	TrayIcon_SortUp(csvFile)
	iIconsPrev := iIcons
}
return


; сортируем и перемещаем вниз иконки
TrayIcon_SortDown(sFilePath)
{
	Loop, Read, %sFilePath%
	{
		sStr := Trim(A_LoopReadLine)
		if (SubStr(sStr, 1, 1) = ";" or sStr = "")
			Continue
		ParseString(sStr, sExeName, oToolTip)
		TrayIcon_MoveToEnd(sExeName, oToolTip)
	}
	TrayIcon_ShowError()
}


; сортируем и перемещаем вверх иконки 
TrayIcon_SortUp(sFilePath)
{
	sFile := []
	Loop, Read, %sFilePath%
	{
		sStr := Trim(A_LoopReadLine)
		if (SubStr(sStr, 1, 1) = ";" or sStr = "")
			Continue
		sFile.InsertAt(1, sStr)
	}
	Loop, % sFile.MaxIndex()
	{
		ParseString(sFile[A_Index], sExeName, oToolTip)
		TrayIcon_MoveToTop(sExeName, oToolTip)
	}
	TrayIcon_ShowError()
}


; выделяем EXE и ToolTip Needle из строки sStr
ParseString(sStr, ByRef sExeName, ByRef oToolTip)
{
	oToolTip := []
	sExeName := ""
	Loop, Parse, sStr, csv
	{
		if (A_Index == 1) {
			sExeName := A_LoopField
		} else {
			oToolTip.Push(A_LoopField)
		}
	}
}

/*
; показать сообщение на экране
	TrayIcon_ShowError(sExeName, sToolTip)
	{
		sMsg =
	(LTrim
	Can't find this tray icon:
	ExeName: %sExeName%
	SearchToolTipNeedle: %sToolTip%
	)
		SoundBeepTwice()
		ToolTip(sMsg, 2000, true)
	}
*/

; собрать все ошибки и за один раз показать сообщение на экране
TrayIcon_ShowError(sExeName := "", sToolTip := "")
{
	static sList := []
	if (sExeName) {
		sList.Push({ExeName: sExeName, ToolTip: sToolTip})
	}
	else {
		if (sList.MaxIndex()) { ;if not empty
			sMsg := "Can't find this tray icons:"
			Loop	% sList.maxIndex()
			{
				sMsg .= "`n" sList[A_Index].ExeName
				if (sList[A_Index].ToolTip)
					 sMsg .= " - " sList[A_Index].ToolTip
			}
			sList := []
			SoundBeepTwice()
			ToolTip(sMsg, 4000, true)
		}
	}
}


; перемещаем иконки одного приложения вниз
TrayIcon_MoveToEnd(sExeName, oToolTip := "")
{
	idxNew := 255 ; 65535 works too
	Loop
	{
		idxOld := TrayIcon_GetIdx(sExeName, oToolTip[A_Index])
		if (idxOld == -1) {
			TrayIcon_ShowError(sExeName, oToolTip[A_Index])
		} else {
			TrayIcon_Move(idxOld, idxNew)
		}
	} Until !(A_Index < oToolTip.MaxIndex()) ; условие в Loop---Until работает наоборот!!!
}


; перемещаем иконки одного приложения вверх
TrayIcon_MoveToTop(sExeName, oToolTip := "")
{
	idxNew := 0
	maxIndex := oToolTip.MaxIndex() + 1
	Loop
	{
		idxOld := TrayIcon_GetIdx(sExeName, oToolTip[maxIndex - A_Index])
		if (idxOld == -1) {
			TrayIcon_ShowError(sExeName, oToolTip[maxIndex - A_Index])
		} else {
			TrayIcon_Move(idxOld, idxNew)
		}
	} Until !(A_Index < oToolTip.MaxIndex())
}


; ищем порядковый номер иконки определенного процесса и определенного текста в трее (нумерация начинатеся с 0)
TrayIcon_GetIdx(sExeName, sToolTip := "")
{
	idx := -1 ; -1 is error value
	if WinExist("ahk_exe " sExeName) {
		oIcons := TrayIcon_GetInfo(sExeName)
		Loop
		{
		;if (InStr(oIcons[A_Index].tooltip, sToolTip, true)) {
			if (RegExMatch(oIcons[A_Index].tooltip, sToolTip)) {
				idx := oIcons[A_Index].idx
				break ; нашли первое совпадение, выходим из цикла
			}
		} Until !(A_Index < oIcons.MaxIndex())
	}
	return idx
}


; показать всю инфу по иконкам в трее
ShowTrayInfo()
{
	; Removes previosly created GUI
	Gui Destroy
	
	; Create a ListView to display the list of info gathered
	Gui Add, ListView, Grid r42 w900 Sort, idx|Process|Tooltip|Visible|Handle|IDcmd|msgID|uID|Class
	
	; Get all of the icons in the system tray using Sean's TrayIcon library
	oIcons := TrayIcon_GetInfo()
	
	; Loop through the info we obtained and add it to the ListView
	Loop, % oIcons.MaxIndex()
	{
		proc  := oIcons[A_Index].Process
		ttip  := oIcons[A_Index].tooltip
		tray  := oIcons[A_Index].Tray
		hWnd  := oIcons[A_Index].hWnd
		idx   := oIcons[A_Index].idx
		IDcmd := oIcons[A_Index].IDcmd
		msg   := oIcons[A_Index].msgID
		uID   := oIcons[A_Index].uID
		class := oIcons[A_Index].Class
		
		vis := (tray == "Shell_TrayWnd") ? "Yes" : "No"
		
		LV_Add(, idx, proc, ttip, vis, hWnd, IDcmd, msg, uID, Class)
	}
	
	LV_ModifyCol()
	LV_ModifyCol(1, "Integer Sort")
	Loop, 4
		LV_ModifyCol(A_Index + 4, "Integer")
	
	Gui Show, Center, System Tray Icons
}