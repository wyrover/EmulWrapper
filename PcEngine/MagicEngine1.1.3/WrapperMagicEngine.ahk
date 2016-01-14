#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk


sendKey( "F1" )

ExitApp

emulatorPid   := ""
imageFilePath := %0%
;imageFilePath := ""
;imageFilePath := "\\NAS\emul\image\PcEngine\hucard\Batman (J).zip"

if ( (romFile := FileUtil.getFile(imageFilepath, "i).*\.(mdx|mdf|cue)" )) != "" ) {

	if ( VirtualDisk.open(romFile) != true )
		ExitApp

	Run, % "pce.exe ""./cards/Super CD-ROM2 System V3.01 (En).zip"" -cd",,,emulatorPid
	WinWait, ahk_class MagicEngineWindowClass,, 10
	IfWinExist
	{
		WinWaitActive, ahk_class MagicEngineWindowClass,, 10
		sendKey( "Enter" )
		WinWaitClose
	}
	VirtualDisk.close()

} else if( (romFile := FileUtil.getFile(imageFilepath, "i).*\.(zip|pce)" )) != "" ) {
	RunWait, % "pce.exe""" romFile """"
} else {
	Run, % "pce.exe"
}

ExitApp

^+Del:: ; Reset
	return

^+Insert:: ; Toggle Speed
	Tray.showMessage( "Toggle speed" )
	return