#NoEnv

; TestCode
;
;Sleep 30000
;ExitApp
;
;^F3::
;	Tray.show( "Timed Tray Tip", "This will be displayed for 5 seconds" )
;	return
;^F4::
;	Tray.hide()
;	return
;!F4::
;	ExitApp

class Tray {

    __New() {
        throw Exception( "Tray is a static class, dont instante it!", -1 )
    }

    show( title, message:="", duration=2000 ) {

		this.hide()

		gui -Caption +ToolWindow +AlwaysOnTop

		; rather than transperency, below setting shows notification in FullScreen Mode
		Gui +LastFound
		WinSet, TransColor, White 250

		gui, font, s10 bold
		gui, add, text, cblue w200, %title%
		gui, font, s8 Normal
		gui, add, text, w200, %message%

		; draw tray
		gui, show, NoActivate y9999, EmulLoaderNotificator
		WinGetPos,,, vWidth, vHeight, EmulLoaderNotificator
		WinMove, EmulLoaderNotificator,, A_ScreenWidth - vWidth, A_ScreenHeight - vHeight

		SetTimer, Tray.show_remove, -%duration%
		return

		Tray.show_remove:
			gui, destroy
			return

    }
	
	hide() {
		SetTimer, Tray.show_remove, off
		gui, destroy
    }

}

