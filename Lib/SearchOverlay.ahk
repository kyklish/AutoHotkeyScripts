; Overlay to show search areas of [ImageSearch], [PixelSearch], [PixelGetColor]
; Use [Screen] or [Client] coordinates!
; On start script automatically converts [Client] to [Screen] coordinates.
; Usage:
;   1. Launch game.
;   2. Restart script:
;       2.1 Script detects coordinates of currently active window.
;       2.2 Script moves overlay coordinates to currently active window position.
;   3. Show overlay (hardcoded search areas).
;   4. Press script's hotkeys to add dynamic search areas to overlay.
; Initial code was written in Trainer_Northgard.ahk

; Changelog
;  + added
;  * changed
;  - deleted
;  ! bug fixed
;
; v1.0.0
;  + Initial release

;-------------------------------------------------------------
;---------------------- RECTANGLE CODE -----------------------
;-------------------------------------------------------------

; How to use ORIGINAL:
; * Write [ImageSearch] or [PixelSearch] or [PixelGetColor] command and add comment after it.
;       ImageSearch, x, y, 1, 1, 2, 2, %img% ; ThisCommentWillBeVisibleInOverlay
; * Parse script to find [ImageSearch] or [PixelSearch] rectangles and [PixelGetColor] pixels with explicit
;   parameters (hardcoded numbers).
;       coords := ParseScriptForOverlay()
; * If parameters are implicit ([ImageSearch] or [PixelGetColor] are inside some function and parameters
;   for them passed as variables) register rectangle or pixel manually, for example before actual func call.
;       AddSearchArea(coords, A_LineNumber, "comment", varX, varY) ; adds objects to [coords] variable
;       GetSomePixelColor(color, varX, varY) ; any func
; * Draw rectangles.
;       DrawOverlay(coords)
; * Destroy rectangles.
;       DestroyOverlay(coords)
; ! Rectangle consist of four lines. Each line is [Gui] window. Create all lines (not visible) for
;   all rectangles. Show all lines. Destroy all lines.

; How to use NEW:
;   so := new SearchOverlay() ; parse script in class constructor
;   ...
;   ; Caution! All [AddSearchArea()] must be called before showing overlay. Because if not, some areas
;   ; will be missed in overlay :( Later, when some [AddSearchArea()] called, just hide and show overlay.
;   so.AddSearchArea(A_LineNumber, "comment", varX, varY) ; add custom rectangle
;   GetSomePixelColor(color, varX, varY) ; any func
;   ...
;   so.DrawOverlay()
;   so.DestroyOverlay()
;   so.ToggleOverlay() ; same as above, but single function

class SearchOverlay
{
    coords := {} ; All found coordinates in script
    hWnd := ""
    isOverlayVisible := false
    r := 2 ; Radius around pixel in [PixelGetColor] to show it on screen
    winTitle := ""

    __New(winTitle := "A")
    {
        this.winTitle := winTitle
        this.ParseScriptForOverlay()
    }

    CreateMouseClickTransGui(id, color := "")
    {
        ; Gui, GuiName:New [, Options, Title]
        ; If [GuiName] is specified, a new GUI will be created, destroying any existing GUI with that name.
        ; Otherwise, a new unnamed and unnumbered GUI will be created.
        ; Calling [Gui, New] ensures that the script is creating a new GUI, not modifying an existing one.
        ; +E0x20 makes GUI mouse-click transparent.
        Gui, %id%: New, -Caption -SysMenu +AlwaysOnTop +LastFound +ToolWindow +E0x20
        Gui, %id%: Color, % color
        WinSet, TransColor, 500 ; This line is necessary to working +E0x20 !!!! Very complicated theme.
    }

    CreateComment(id)
    {
        this.CreateMouseClickTransGui("RectToolTip" . id)
        Gui, RectToolTip%id%: Margin, 0, 0
        Gui, RectToolTip%id%: Font, , Consolas
    }

    CreateRectangle(id, color) {
        ; Create 4 rectangle lines
        Loop, 4
            this.CreateMouseClickTransGui("Rect" . A_Index . id, color)
    }

    DrawRectangle(id, coord)
    {
        Gui, Rect1%id%: Show, % "x" coord.X1 " y" coord.Y1 " w" coord.X2 - coord.X1 " h1 NoActivate"
        Gui, Rect4%id%: Show, % "x" coord.X1 " y" coord.Y2 " w" coord.X2 - coord.X1 " h1 NoActivate"

        Gui, Rect2%id%: Show, % "x" coord.X1 " y" coord.Y1 " w1 h" coord.Y2 - coord.Y1 " NoActivate"
        Gui, Rect3%id%: Show, % "x" coord.X2 " y" coord.Y1 " w1 h" coord.Y2 - coord.Y1 " NoActivate"
    }

    DrawComment(id, coord)
    {
        ; First [ToolTip] window is used for debug messages, start from second window. Max is 20 windows.
        ; [ToolTip] has word wrap and automatically create window inside screen area.
        ; But it's not mouse-click transparent.
        ; ToolTip, % "Line " coord.lineNumber ": " coord.comment, % coord.X1, % coord.Y2, % id + 1

        comment := "Line " coord.lineNumber ": " coord.comment

        ; Gui has no limitation in window number, is mouse-click transparent.
        ; Shows text in one line if we don't specify height of [Text] control.
        ; But we must manually calculate is it inside or outside of screen and correct position.

        ; Variant 1 (hardcoded char size): fix position (calculate variables) and show gui window.
        ; 6px is char width and 13px is char height of 'Consolas' font with default size.
        ; w := StrLen(comment) * 6 ; width
        ; h := 13                  ; height
        ; x := (coord.X1 + w) < A_ScreenWidth ? coord.X1 : A_ScreenWidth - w
        ; y := (coord.Y2 + h) < A_ScreenHeight ? coord.Y2 : A_ScreenHeight - h

        ; Gui, RectToolTip%id%: Add, Text, , % comment
        ; Gui, RectToolTip%id%: Show, % "x" x " y" y + 1 " NoActivate" ; Move 1px below to not overlap with rectangle

        ; Variant 2 (universal): show gui window outside of screen, measure text area, fix position, show on proper position.
        ; WinMove is very slow command!!!
        Gui, RectToolTip%id%: Add, Text, , % comment
        Gui, RectToolTip%id%: Show, % "x" A_ScreenWidth + coord.X1 " y" A_ScreenHeight + coord.Y2 " NoActivate" ; Show window out of screen

        Gui, RectToolTip%id%: +LastFoundExist
        VarSetCapacity(rect, 16, 0)
        DllCall("GetClientRect", uint, myGuiHWND := WinExist(), uint, &rect)
        w := NumGet(rect, 8, "int")
        h := NumGet(rect, 12, "int")
        x := (coord.X1 + w) < A_ScreenWidth ? coord.X1 : A_ScreenWidth - w
        y := (coord.Y2 + h) < A_ScreenHeight ? coord.Y2 : A_ScreenHeight - h
        Gui, RectToolTip%id%: Show, % "x" x " y" y + 1 " NoActivate" ; Move 1px below to not overlap with rectangle
    }

    DrawOverlay()
    {
        if (this.isOverlayVisible)
            return
        else
            this.isOverlayVisible := true

        if (!this.hWnd) {
            this.hWnd := WinExist(this.winTitle)
        }
        this.ConvertClientToScreenCoordinates(this.hWnd)

        for id, coord in this.coords {
            this.CreateRectangle(id, "Red")
            this.DrawRectangle(id, coord)
            this.CreateComment(id)
            this.DrawComment(id, coord)
        }
    }

    DestroyOverlay()
    {
        this.isOverlayVisible := false
        for id, coord in this.coords {
            Loop, 4
                Gui, Rect%A_Index%%id%: Destroy
            Gui, RectToolTip%id%: Destroy
        }
    }

    ToggleOverlay()
    {
        if (!this.isOverlayVisible)
            this.DrawOverlay()
        else
            this.DestroyOverlay()
    }

    ; Parse script text to find [ImageSearch] and [PixelSearch] areas and [GetPixelColor] pixels for overlay
    ParseScriptForOverlay()
    {
        Loop, Read, % A_ScriptName
        {
            line := Trim(A_LoopReadLine)

            if (SubStr(line, 1, 1) == ";") ; skip comments
                continue

            ; ImageSearch, x, y, (1185), (860), (1220), (930), (NorthgardDestroy.png) ; (comment)
            ;                    match1 match2  match3 match4                  match5     match6
            c := {} ; Coordinates of search area rectangle
            if (RegExMatch(A_LoopReadLine, "ImageSearch\s*,.+?,.+?,\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*([^;]+)\s*;?\s*(.*)?", match)) {
                c.X1 := match1
                c.Y1 := match2
                c.X2 := match3
                c.Y2 := match4
                c.lineNumber := A_Index
                c.comment := match6
                this.AddCoord(c)
                continue
            }

            ; PixelSearch, x, y, (860), (890), (1185), (1045), color, options ; (comment)
            ;                   match1 match2  match3  match4                      match5
            if (RegExMatch(A_LoopReadLine, "PixelSearch\s*,.+?,.+?,\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*[^;]*;?\s*(.*)?", match)) {
                c.X1 := match1
                c.Y1 := match2
                c.X2 := match3
                c.Y2 := match4
                c.lineNumber := A_Index
                c.comment := match5
                this.AddCoord(c)
                continue
            }

            ; PixelGetColor, color, (1658), (400), RGB ; (comment)
            ;                       match1 match2           match3
            if (RegExMatch(A_LoopReadLine, "PixelGetColor\s*,.+?,\s*(\d+)\s*,\s*(\d+)\s*,?[^;]*;?\s*(.*)?", match)) {
                c.X1 := match1 - this.r
                c.Y1 := match2 - this.r
                c.X2 := match1 + this.r
                c.Y2 := match2 + this.r
                c.lineNumber := A_Index
                c.comment := match3
                this.AddCoord(c)
                continue
            }
        }
        /*
        ; Test strings for RegExMatch() above in ParseScriptForOverlay()
        ;; PixelGetColor, color1, 20, 20, RGB ; Must be not visible comment
        ; PixelGetColor, color1, 20, 60, RGB ; comment
        ; PixelGetColor, color2, 20, 100, RGB
        ; PixelGetColor, color3, 20, 140 ; comment
        ; PixelGetColor, color3, 20, 180
        ; ImageSearch, x, y, 200, 60, 240, 100, NorthgardDestroy.png ; DestroyBuilding
        ; ImageSearch, x, y, 200, 140, 240, 180, NorthgardDestroy.png
        */
    }

    ; Add search area (rectangle or pixel) to overlay
    AddSearchArea(lineNumber, comment, x1, y1, x2 := "", y2 := "")
    {
        c := {}
        if (x2 == "" and y2 == "") {
            c.X1 := x1 - this.r
            c.Y1 := y1 - this.r
            c.X2 := x1 + this.r
            c.Y2 := y1 + this.r
        } else {
            c.X1 := x1
            c.Y1 := y1
            c.X2 := x2
            c.Y2 := y2
        }
        c.lineNumber := lineNumber
        c.comment := comment
        this.AddCoord(c)
    }

    IsUniqueCoord(testCoord)
    {
        isUnique := true
        for _, coord in this.coords {
            if (    coord.XC1 == testCoord.X1
                and coord.YC1 == testCoord.Y1
                and coord.XC2 == testCoord.X2
                and coord.YC2 == testCoord.Y2 ) {
                isUnique := false
                break
            }
        }
        return isUnique
    }

    ; Add coordinates with search area to [coords] (skip, if already there)
    AddCoord(coord)
    {
        if (this.IsUniqueCoord(coord)) {
            ; Current [X] and [Y] are [Client] coordinates, but later [DrawOverlay()]
            ; will convert them to [Screen] coordinates, so we must save them to [XC]
            ; and [YC] for future use in [IsUniqueCoord()] (Overlay is on screen,
            ; we add new search area and must check if it is unique. During checking
            ; we use [Client] coordinates of new search area, but all other areas
            ; has [Screen] coordinates. To fix this, we save [Client] coordinates
            ; in separate properties [XC] and [YC] for later use).
            coord.XC1 := coord.X1
            coord.YC1 := coord.Y1
            coord.XC2 := coord.X2
            coord.YC2 := coord.Y2
            this.coords.Push(coord)
            if (this.isOverlayVisible) {
                this.DestroyOverlay()
                this.DrawOverlay()
            }
        }
    }

    ; Convert from [Client] to [Screen] coordinates
    ConvertClientToScreenCoordinates(hWnd)
    {
        for _, coord in this.coords {
            if (!coord.isScreenCoordMode) {
                coord.isScreenCoordMode := true
                this.ConvertClientToScreenCoordinate(hWnd, coord)
            }
        }
    }

    ; Convert from [Client] to [Screen] coordinate
    ConvertClientToScreenCoordinate(hWnd, ByRef coord)
    {
        ; Fields of objects are not considered variables for the purposes of ByRef.
        ; For example, if foo.bar is passed to a ByRef parameter, it will behave as
        ; though ByRef was omitted.
        this.JEE_ClientToScreen(hWnd, coord.X1, coord.Y1, X1, Y1)
        coord.X1 := X1
        coord.Y1 := Y1
        this.JEE_ClientToScreen(hWnd, coord.X2, coord.Y2, X2, Y2)
        coord.X2 := X2
        coord.Y2 := Y2
    }

    JEE_ClientToScreen(hWnd, vPosX, vPosY, ByRef vPosX2, ByRef vPosY2)
    {
        VarSetCapacity(POINT, 8)
        NumPut(vPosX, &POINT, 0, "Int")
        NumPut(vPosY, &POINT, 4, "Int")
        DllCall("user32\ClientToScreen", Ptr,hWnd, Ptr,&POINT)
        vPosX2 := NumGet(&POINT, 0, "Int")
        vPosY2 := NumGet(&POINT, 4, "Int")
    }
}
