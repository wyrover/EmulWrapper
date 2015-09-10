#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

emulatorPid   := ""
imageFilePath := %0%
;imageFilePath := ""
;imageFilePath := "\\NAS\emul\image\PcEngine\hucard\Batman (J).zip"

if( VirtualDisk.open( imageFilePath, false ) = true ) {
	Run, % "pce.exe ""./cards/Super CD-ROM2 System V3.01 (En).zip""",,,emulatorPid
	WinWait, ahk_class MagicEngineWindowClass,, 5
	IfWinExist
	{
		WinWaitActive, ahk_class MagicEngineWindowClass,, 5
		;Sleep, 3000
		;ControlSend,,{Enter},emulatorPid
		;ControlSend,, {Enter},MagicEngine ahk_class MagicEngineWindowClass
		;SendInput {Enter}
		WinWaitClose
	}
	VirtualDisk.close()

} else {
	Run, % "pce.exe """ imageFilePath """"
}

ExitApp

^F3::

;MagicEngine  1.1
;ahk_class MagicEngineWindowClass
;ahk_exe pce.exe

    Tray.show( "Send Key", "Merong" )
	;SetKeyDelay(50)
	;WinActive, ahk_class MagicEngineWindowClass
	;ControlSend,, {ALT}+{F4}, ahk_class MagicEngineWindowClass
	;Send !{F4}
	SendMode InputThenPlay
	;SendEvent {Enter}
	SendInput {Enter}
	;SendPlay {Enter}
	return