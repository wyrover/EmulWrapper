#NoEnv

; ## TestCode 01 : show notification
;
; Sleep 30000
; ExitApp

; ^F3::
;    Tray.showMessage( "Timed Tray Tip", "This will be displayed for 5 seconds" )
;    return
; ^F4::
;    Tray.hideMessage()
;    return
; !F4::
;    ExitApp

; ## TestCode 02 : click tray icon

; Tray.printIcons()
; Tray.printIcons( "slack.exe" )
; Tray.clickIcon( "googledrivesync.exe", "R" )
; ExitApp

/**
 * Tray
 */
class Tray {

	__New() {
	    throw Exception( "Tray is a static class, don't instant it!", -1 )
	}

  /**
   * show tray notification
   * 
   * @param  {[type]} title    : title
   * @param  {String} message  : message (default : "")
   * @param  {Number} duration : duration milisecconds to show (default : 2000)
   */
	showMessage( title, message:="", duration=2000 ) {

		this.hideMessage()

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

		SetTimer, Tray.showMessage_remove, -%duration%
		return

		Tray.showMessage_remove:
			gui, destroy
			return

	}
	
	/**
	 * Hide tray notification
	 */
	hideMessage() {
		SetTimer, Tray.showMessage_remove, off
		gui, destroy
  }

  /**
   * Print tray icon information
   * @param  {String} execNameOrPid : executable name or pid to search ( default : "" (show all) )
   */
	printIcons( execNameOrPid = "" ) {

		icons := this.getIcons( execNameOrPid )

		for index, element in icons {

			element.tooltip := RegExReplace( element.tooltip, "\n", "`n`t" )

			infoText .=    "idx: "       . element.idx
			infoText .= " | cmdID: "     . element.cmdID
			infoText .= " | pId: "       . element.pId
			infoText .= " | uId: "       . element.uId
			infoText .= " | msgId : "    . element.msgId
			infoText .= " | hIcon : "    . element.hIcon
			infoText .= " | hWnd: "      . element.hWnd
			infoText .= " | class: "     . element.class
			infoText .= " | tray: "      . element.tray
			infoText .= " | process: "   . element.process . "`n"
			infoText .= "tooltip: `t"    . element.tooltip . "`n`n"

		}

		MsgBox, %infoText%

	}

  /**
   * Get tray icon information
   * 
   * @param  {String} execNameOrPid : executable name or pid to search ( default : "" (show all) )
   * @return {Array} tray icon information
   *   - idx     : tray icon index
   *   - cmdID   : command id
   *   - pid     : processId
   *   - uid     : ?
   *   - msgId   : messageId
   *   - hWnd    : window handler
   *   - class   : window class
   *   - tray    : tray class name be included in
   *   - process : process name
   *   - tooltip : tooltip
   */
	getIcons( execNameOrPid = "" ) {

		Setting_A_DetectHiddenWindows := A_DetectHiddenWindows
		DetectHiddenWindows, On

		trayIcons := {}

		For key, trayClass in [ "Shell_TrayWnd", "NotifyIconOverflowWindow" ] {
			
			WinGet, pidTaskbar, PID, ahk_class %trayClass%

			hProc := DllCall("OpenProcess", UInt, 0x38, Int, 0, UInt, pidTaskbar)
			pRB   := DllCall("VirtualAllocEx", Ptr, hProc, Ptr, 0, UInt, 20, UInt, 0x1000, UInt, 0x4)

			SendMessage, 0x418, 0, 0, ToolbarWindow321, ahk_class %trayClass%   ; TB_BUTTONCOUNT
			
			szBtn := VarSetCapacity(btn, (A_Is64bitOS ? 32 : 24))
			szNfo := VarSetCapacity(nfo, (A_Is64bitOS ? 32 : 24))
			szTip := VarSetCapacity(tip, 128 * 2)
			
			Loop, %ErrorLevel% {

				SendMessage, 0x417, A_Index - 1, pRB, ToolbarWindow321, ahk_class %trayClass%   ; TB_GETBUTTON
				DllCall("ReadProcessMemory", Ptr, hProc, Ptr, pRB, Ptr, &btn, UInt, szBtn, UInt, 0)

				iBitmap := NumGet(btn, 0)
				cmdID   := NumGet(btn, 4)
				statyle := NumGet(btn, 8)
				dwData  := NumGet(btn, (A_Is64bitOS ? 16 : 12))
				iString := NumGet(btn, (A_Is64bitOS ? 24 : 16))

				DllCall("ReadProcessMemory", Ptr, hProc, Ptr, dwData, Ptr, &nfo, UInt, szNfo, UInt, 0)

				hWnd  := NumGet(nfo, 0)
				uID   := NumGet(nfo, (A_Is64bitOS ? 8 : 4))
				msgID := NumGet(nfo, (A_Is64bitOS ? 12 : 8))
				hIcon := NumGet(nfo, (A_Is64bitOS ? 24 : 20))

				WinGet, pID, PID, ahk_id %hWnd%
				WinGet, sProcess, ProcessName, ahk_id %hWnd%
				WinGetClass, sClass, ahk_id %hWnd%

				If ( ! execNameOrPid || (execNameOrPid = sProcess) || (execNameOrPid = pID) ) {
					DllCall("ReadProcessMemory", Ptr, hProc, Ptr, iString, Ptr, &tip, UInt, szTip, UInt, 0)
					Index := ( trayIcons.MaxIndex() > 0 ? trayIcons.MaxIndex() + 1 : 1 )
					trayIcons[ Index, "idx"     ] := A_Index - 1
					trayIcons[ Index, "cmdID"   ] := cmdID
					trayIcons[ Index, "pID"     ] := pID
					trayIcons[ Index, "uID"     ] := uID
					trayIcons[ Index, "msgID"   ] := msgID
					trayIcons[ Index, "hIcon"   ] := hIcon
					trayIcons[ Index, "hWnd"    ] := hWnd
					trayIcons[ Index, "class"   ] := sClass
					trayIcons[ Index, "process" ] := sProcess
					trayIcons[ Index, "tooltip" ] := StrGet(&tip, "UTF-16")
					trayIcons[ Index, "tray"    ] := trayClass
				}

			}

			DllCall("VirtualFreeEx", "Uint", hProc, "Uint", pProc, "Uint", 0, "Uint", 0x8000)
			DllCall("CloseHandle", "Uint", hProc)

		}

		DetectHiddenWindows, %Setting_A_DetectHiddenWindows%
		Return trayIcons

	}

  /**
   * Click tray icon
   * 
   * @param  {String}  execNameOrPid : executable name or pid to search ( default : "" (show all) )
   * @param  {String}  buttonName    :             [description]
   * @param  {Boolean} isDoubleClick :             [description]
   * @param  {Number}  iconIndex     :             [description]
   * @return {[type]}                [description]
   */
	clickIcon( execNameOrPid := "", buttonName := "L", isDoubleClick := false, iconIndex := 1 ) {

		Setting_A_DetectHiddenWindows := A_DetectHiddenWindows
		DetectHiddenWindows, On

		WM_MOUSEMOVE	   = 0x0200
		WM_LBUTTONDOWN	 = 0x0201
		WM_LBUTTONUP	   = 0x0202
		WM_LBUTTONDBLCLK = 0x0203
		WM_RBUTTONDOWN	 = 0x0204
		WM_RBUTTONUP	   = 0x0205
		WM_RBUTTONDBLCLK = 0x0206
		WM_MBUTTONDOWN	 = 0x0207
		WM_MBUTTONUP	   = 0x0208
		WM_MBUTTONDBLCLK = 0x0209

		buttonName := "WM_" buttonName "BUTTON"

		icons := this.getIcons( execNameOrPid )

		if( icons.MaxIndex() < 1 )
			return

		msgID  := icons[iconIndex].msgID
		uID    := icons[iconIndex].uID
		hWnd   := icons[iconIndex].hWnd

		if ( isDoubleClick ) {
			PostMessage, msgID, uID, %buttonName%DBLCLK, , ahk_id %hWnd%
		} else {
			PostMessage, msgID, uID, %buttonName%DOWN, , ahk_id %hWnd%
			PostMessage, msgID, uID, %buttonName%UP,   , ahk_id %hWnd%
		}

		DetectHiddenWindows, %Setting_A_DetectHiddenWindows%

	}

}

