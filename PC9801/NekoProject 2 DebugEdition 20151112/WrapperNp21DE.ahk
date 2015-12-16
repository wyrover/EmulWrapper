#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

emulatorPid    := ""
imageFilePath  := %0%
;imageFilePath  := "\\NAS\emul\image\PC9801\0_imagesFdi\Ys 2 (1988)(Nihon Falcom)(T-Kr)\Disk 1.d88"
;imageFilePath  := "\\NAS\emul\image\PC9801\0_imagesFdi\Ys 1\Ys 1 (Falcom).D88"
;imageFilepath := "\\NAS\emul\image\PC9801\0_imagesFdi\Ys 2 (1988)(Nihon Falcom)(T-Kr)\"
imageFilepath := "\\NAS\emul\image\PC9801\0_imagesFdi\Ys 3 - Wanderers from Ys (1989)(Falcom)"

fddContainer := new DiskContainer( imageFilePath, "i).*\.(d88|fdi)" )
fddContainer.initSlot( 2 )

if( setConfig( imageFilePath ) == true )
{

	ResolutionChanger.change( 1280, 800 )
	
	Run, % "np21.exe",,,emulatorPid
	
	WinWait, ahk_class NP2-MainWindow,, 5
	IfWinExist
	{
		WinActivate, ahk_class NP2-MainWindow

		insertDisk( 1, fddContainer.getFileInSlot(1) )
		Sleep, 500
		insertDisk( 2, fddContainer.getFileInSlot(2) )
		Sleep, 500

		WinSet, Style, -0xC40000, ahk_class NP2-MainWindow   ; remove the titlebar and border(s) 
		Send {F11}{S}{Down}{Down}{Down}{Down}{Down}{Down}{Down}{Enter}

		WinWaitClose, ahk_class NP2-MainWindow
	}
	
	ResolutionChanger.restore()
	
} else {
	Run, % "np21.exe",,,emulatorPid
}

ExitApp

^+PGUP::

	If GetKeyState( "z", "P" ) ; Ctrl + Shift + Z + PgUp :: Remove Disk in Drive#1
		fddContainer.removeDisk( "1", "removeDisk" )
	else ; Ctrl + Shift + PgUp :: Insert Disk in Drive#1
		fddContainer.insertDisk( "1", "insertDisk" )
	
	return

^+PGDN:: ; Insert Disk in Drive#2

	If GetKeyState( "z", "P" ) ; Ctrl + Shift + Z + PgDn :: Remove Disk in Drive#2
		fddContainer.removeDisk( "2", "removeDisk" )
	else ; Ctrl + Shift + PgDn :: Insert Disk in Drive#2
		fddContainer.insertDisk( "2", "insertDisk" )
	
	return

^+End:: ; Cancel Disk Change	
	fddContainer.cancel()
	return

^+Del:: ; Reset
    reset()
	return

reset() {
	WinActivate, ahk_class NP2-MainWindow
	Send {F11}{E}{R}
}

insertDisk( slotNo, file ) {

	IfNotExist % file 
        return

    WinActivate, ahk_class NP2-MainWindow
	
	if( slotNo == "1" ) {
		Send {F11}{D}{Down}{Enter}{Enter} ;FDD1
	} else if( slotNo == "2" ) {
		Send {F11}{D}{Down}{Down}{Enter}{Enter}  ;FDD2
	} else {
		return
	}
	
	WinWait, Select floppy image,, 5
	IfWinExist
	{
		Send !{N}
		Clipboard = %file%
		Send ^v
		Send {Enter}
	}
    
}

removeDisk( slotNo ) {

    WinActivate, ahk_class NP2-MainWindow

	if( slotNo == "1" ) {
		Send {F11}{D}{Down}{Enter}{Down}{Enter} ;FDD1
	} else if( slotNo == "2" ) {
		Send {F11}{D}{Down}{Down}{Enter}{Down}{Enter} ;FDD2
	} else {
		return
	}
    
}


setConfig( imageFilePath ) {

	currDir := FileUtil.getDir( imageFilepath )
	confDir := currDir . "\_EL_CONFIG"
	
	NekoIniFile := % A_ScriptDir "\np21.ini"
	
	if( currDir = "" ) {
		IniWrite, %A_ScriptDir%\font.rom, %NekoIniFile%, NekoProject21, fontfile
		IniWrite, 0,                      %NekoIniFile%, NekoProject21, windtype
		IniWrite, false,                  %NekoIniFile%, NekoProject21, Mouse_sw
		return false
	}
	
	; Set font
	IfExist %confDir%\font
	{
		Loop, %confDir%\font\*.*
		{
			IniWrite, %A_LoopFileFullPath%, %NekoIniFile%, NekoProject21, fontfile
			break
		}
	} else {
		IniWrite, %A_ScriptDir%\font.rom, %NekoIniFile%, NekoProject21, fontfile
	}

	; Set WindowType
	IniWrite, 0, %NekoIniFile%, NekoProject21, WindposX
	IniWrite, 0, %NekoIniFile%, NekoProject21, WindposY
	IniWrite, 1, %NekoIniFile%, NekoProject21, windtype
	
	; Lock Mouse
	IniWrite, true, %NekoIniFile%, NekoProject21, Mouse_sw

	; Init INI
	IniDelete, %NekoIniFile%, NekoProject21, FDfolder
	IniDelete, %NekoIniFile%, NekoProject21, HDfolder
	
	Loop, 8
	{
		fdIndex := A_Index - 1
		IniDelete, %NekoIniFile%, NP2 tool, FD1NAME%fdIndex%
		IniDelete, %NekoIniFile%, NP2 tool, FD2NAME%fdIndex%		
	}
	
	IniDelete, %NekoIniFile%, NekoProject21, HDD1FILE
	IniDelete, %NekoIniFile%, NekoProject21, HDD2FILE

	; Set Hdd & Fdd
	files := FileUtil.getFiles( currDir, "i).*\.(hdi|hdd)" )
	Loop, % files.MaxIndex()
	{
		if( A_Index > 2 )
			break
		IniWrite, % files[a_index], %NekoIniFile%, NekoProject21, HDD%a_index%FILE
	}

	return true

}