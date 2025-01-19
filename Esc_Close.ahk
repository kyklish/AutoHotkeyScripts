#Include <_COMMON_SETTINGS_>

; Есть программка "Esc Close", которая по сути является скомпилированным AutoHotKey скриптом
; Я решил написать свой скрипт по примеру из справки
; Третий пример из справки (SetTimer), изрядно изменил
; Example #3: Detection of single, double, and triple-presses of a hotkey.
; This allows a hotkey to perform a different operation depending on how many times you press it:

SendMode, Event ; нужен Event режим, т.к. только в этом режиме можно задать задержки для клавиш
SetKeyDelay, 50, 50 ; чтобы работало в играх, нужно использовать задержки при нажатиях (only Event mode)
timerDelay := 400 ; milliseconds. Measure interval for counting key presses

;-------------------------------------------------------------------------------------
; $ before HotKey
; This is usually only necessary if the script uses the Send command to send the keys that comprise
; the hotkey itself, which might otherwise cause it to trigger itself. The $ prefix forces the keyboard
; hook to be used to implement this hotkey, which as a side-effect prevents the Send command from
; triggering it. The $ prefix is equivalent to having specified #UseHook somewhere above the definition
; of this hotkey.
; [v1.1.06+]: #InputLevel and SendLevel provide additional control over which hotkeys and hotstrings
; are triggered by the Send command.
;-------------------------------------------------------------------------------------
$~`:: ; поменял на эту клавишу, т.к. Esc часто используется в играх, и приводит к их закрытию
    ;Send, `` ; прозрачно работаем с горячей клавишей, ` используется для форматирования строк как эскейп последовательность, поэтому нужно именно ``; ЗАМЕНИЛ на модификатор ~
    ;$~Esc::
    ;Send, {Escape} ; прозрачно работаем с горячей клавишей; ЗАМЕНИЛ на модификатор ~
    if (esc_presses > 0) { ; SetTimer already started, so we log the keypress instead.
        esc_presses += 1
        if (esc_presses = 3) {
            GoSub, KeyEsc ; Не дожидаясь окончания таймера отрабатываем тройное нажатие
        }
    }
    else { ; Otherwise, this is the first press of a new series. Set count to 1 and start the timer:
        esc_presses = 1
        SetTimer, KeyEsc, %timerDelay% ; Wait for more presses within a timerDelay millisecond window.
    }
return
;-------------------------------------------------------------------------------------
KeyEsc:
    SetTimer, KeyEsc, off
    if (esc_presses = 1) { ; The key was pressed once.
        ; ничего не делаем, т.к. Esc уже отослана сразу при срабатывании горячей клавиши
        ;Send {Escape down}{Escape up}
    } else
        if (esc_presses = 2) { ; The key was pressed twice.
            Send, ^{F4} ; Ctrl+F4
        } else
            if (esc_presses = 3) { ; The key was pressed triple.
                Send, !{F4} ; Alt+F4
            }
    ; Regardless of which action above was triggered, reset the count to prepare for the next series of presses:
    esc_presses = 0
return
