#Include <_COMMON_SETTINGS_>

;Переключение по принципу левый Shift нажал - гарантированно будет русский, правый Shift - гарантированно будет английский.
;Для переключения нажатие должно быть коротким. Если нажатие длинное, либо же нажатие было вместе с какой-нибудь клавишей - смена раскладки не срабатывает.
;Даже никогда не смотрю вниз какая раскладка включена. Легче быстро нажать по нужному Shift.

;~ - when the hotkey fires, its key's native function will not be blocked (hidden from the system)
;-------------------------------------------------------------------------------------
~LControl:: ;to russian layout
    startLControl := A_TickCount
    Input last_key, L1 V, {RControl}
return
;-------------------------------------------------------------------------------------
~LControl UP::
    endLControl := A_TickCount
    elapsed_LControl := endLControl - startLControl
    if (not last_key and elapsed_LControl < 300) {
        PostMessage 0x50, 0, 0x4190419,, A	; Change layout to Russian
    }
    Send {RControl} ; To end Input after LControl keydown
    last_key := ""
return
;-------------------------------------------------------------------------------------
~RControl:: ;to english layout
    startRControl := A_TickCount
    Input last_key, L1 V, {LControl}
return
;-------------------------------------------------------------------------------------
~RControl UP::
    endRControl := A_TickCount
    elapsed_RControl := endRControl - startRControl
    if (not last_key and elapsed_RControl < 300) {
        PostMessage 0x50, 0, 0x4090409,, A	; Change layout to English
    }
    Send {LControl}	; To end Input after RControl keydown
    last_key := ""
return
;-------------------------------------------------------------------------------------
;Предположил нажимаете LControl (левый Shift) сразу в переменную startLControl заносится временная метка.
;Следующая команда Input last_key, L1 V, {RControl} ждет нажатия клавиши клавиатуры (если вы нажимаете Shift чтобы ввести прописную букву, а не переключить язык).
;Далее, когда отпускаете Shift срабатывает код после ~LControl UP:: - снимается временная метка и проверяется, а сколько времени вы держали Shift нажатым?
;Если недолго и при этом last_key ничему не равно, т.е. во время нажатия и удержания Shift никакая другая клавиша не была нажата, то надо переключить раскладку.
;Потом Send {RControl} завершает Input, нужна обязательно.
