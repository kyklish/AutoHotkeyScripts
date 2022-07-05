#Include <_COMMON_SETTINGS_>

;Переключение по принципу левый Shift нажал - гарантированно будет русский, правый Shift - гарантированно будет английский.
;Для переключения нажатие должно быть коротким. Если нажатие длинное, либо же нажатие было вместе с какой-нибудь клавишей - смена раскладки не срабатывает.
;Даже никогда не смотрю вниз какая раскладка включена. Легче быстро нажать по нужному Shift.

;~ - when the hotkey fires, its key's native function will not be blocked (hidden from the system)
;-------------------------------------------------------------------------------------
~LShift:: ;to russian layout
startLShift := A_TickCount
Input last_key, L1 V, {RShift}
return
;-------------------------------------------------------------------------------------
~LShift UP::
endLShift := A_TickCount
elapsed_LShift := endLShift - startLShift
if (not last_key and elapsed_LShift < 300) {
	PostMessage 0x50, 0, 0x4190419,, A	; Change layout to Russian
}
Send {RShift} ; To end Input after LShift keydown
last_key =
return
;-------------------------------------------------------------------------------------
~RShift:: ;to english layout
startRShift := A_TickCount
Input last_key, L1 V, {LShift}
return
;-------------------------------------------------------------------------------------
~RShift UP::
endRShift := A_TickCount
elapsed_RShift := endRShift - startRShift
if (not last_key and elapsed_RShift < 300) {
	PostMessage 0x50, 0, 0x4090409,, A	; Change layout to English
}
Send {LShift}	; To end Input after RShift keydown
last_key =
return
;-------------------------------------------------------------------------------------
;Предположил нажимаете LShift (левый Shift) сразу в переменную startLShift заносится временная метка.
;Следующая команда Input last_key, L1 V, {RShift} ждет нажатия клавиши клавиатуры (если вы нажимаете Shift чтобы ввести прописную букву, а не переключить язык).
;Далее, когда отпускаете Shift срабатывает код после ~LShift UP:: - снимается временная метка и проверяется, а сколько времени вы держали Shift нажатым?
;Если недолго и при этом last_key ничему не равно, т.е. во время нажатия и удержания Shift никакая другая клавиша не была нажата, то надо переключить раскладку.
;Потом Send {RShift} завершает Input, нужна обязательно.
