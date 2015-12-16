#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

emulatorPid   := ""
imageFilePath := %0%
;imageFilePath := ""
;imageFilePath := "\\NAS\emul\image\SuperFamicom\action\Act Raiser 1 (En)\Act Raiser 1 (US).zip"

romFile := FileUtil.getFile( imageFilepath, "i).*\.(zip|iso)" )
if( romFile != "" ) {
	RunWait, Fusion.exe "%romFile%"	
	ExitApp
}

ExitApp