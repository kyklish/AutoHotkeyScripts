#Include <SearchOverlay>
#SingleInstance, Force
overlay := new SearchOverlay("ahk_exe notepad.exe")
ImageSearch, x, y, 0, 0, 19, 19, %img% ; AREA
ImageSearch, x, y, 1, 20, 19, 39, %img% ; AREA
overlay.AddSearchArea(A_LineNumber, "PIXEL", 2, 80)
F1::overlay.DrawOverlay()
F2::overlay.DestroyOverlay()
F3::overlay.ToggleOverlay()
F4::overlay.AddSearchArea(A_LineNumber, "PIXEL", 80, 80)

!z::Reload
!x::ExitApp
