#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

emulatorPid   := ""
imageFilePath := %0%
;imageFilePath := ""
;imageFilePath := "\\NAS\emul\image\SuperFamicom\action\Act Raiser 1 (En)\Act Raiser 1 (US).zip"

romFile := getRomFile( imageFilepath )

MouseCursor.hide()

RunWait, snes9x.exe -fullscreen "%romFile%"

MouseCursor.show()

ExitApp

getRomFile( imageFilePath ) {

	if ( FileUtil.isFile(imageFilepath) )  {
		return imageFilepath
	}

	currDir := FileUtil.getDir( imageFilepath )
	confDir := currDir . "\_EL_CONFIG"

	files := FileUtil.getFiles( currDir, "i).*\.(zip|7z)" )
	Loop, % files.MaxIndex()
	{
		if( a_index > 2 )
			break
		
		return files[a_index]
	}

}