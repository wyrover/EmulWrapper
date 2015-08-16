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

    showTip( title, message, duration=3, option=1 ) {

    	Tray.hide()

		duration := duration * 1000
		TrayTip %title%, %message%, , %option%
		SetTimer, Tray.show_remove, %duration%
		return

		Tray.show_remove:
			Tray.hide()
			return

    }
	
	hideTip() {
		SetTimer, Tray.show_remove, off
		TrayTip
    }

}


