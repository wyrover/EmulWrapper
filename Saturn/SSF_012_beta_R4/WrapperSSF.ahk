#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

emulatorPid   := ""
imageFilePath := %0%


if( VirtualDisk.open( imageFilePath ) = false ) {
	Run, % "SSF.exe"
    ExitApp
}

setConfig( imageFilePath )

RunWait, % "SSF.exe",,,emulatorPid

VirtualDisk.close()

ExitApp



^F3::
    Tray.showMessage( "Merong", "blablah" )
	return


getImageFileDir( imageFilePath ) {
	
	IfNotExist %imageFilepath%
	{
		return ""
	}
	
	SplitPath, imageFilePath, , imageDir
	
	return imageDir
	
}


setConfig( imageFilePath ) {
	
}