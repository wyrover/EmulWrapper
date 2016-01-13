#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

emulatorPid   := ""
imageFilePath := %0%
;imageFilePath := ""

romFile := FileUtil.getFile( imageFilePath, "i).*\.(zip|7z)" )

if ( romFile != "" ) {
	RunWait, % "mednafen.exe """ romFile """",,,emulatorPid
}

ExitApp

!F4:: ; ALT + F4
	Process, Close, %emulatorPid%
    ExitApp