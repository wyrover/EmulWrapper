#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

emulatorPid    := ""
imageFilePath  := %0%
;imageFilePath  := "\\NAS\emul\image\PC9801\0_imagesFdi\Ys 2 (1988)(Nihon Falcom)(T-Kr)\Disk 1.d88"
;imageFilePath  := "\\NAS\emul\image\PC9801\0_imagesFdi\Ys 1\Ys 1 (Falcom).D88"

fddContainer := new DiskContainer( imageFilePath, "i).*\.(d88|fdi)" )
fddContainer.initSlot( 2 )

if( setConfig( imageFilePath ) == true )
{

	ResolutionChanger.change( 1280, 720 )
	
	Run, % "np2nt.exe " fddContainer.toOption(),,,emulatorPid
	
	WinWait, ahk_class NP2-MainWindow,, 5
	IfWinExist
	{
		Send {F11}{S}{F}  ;Send !{Enter}
		WinWaitClose, ahk_class NP2-MainWindow
	}
	
	ResolutionChanger.restore()
	
} else {
	Run, % "np2nt.exe",,,emulatorPid
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
		Send {F11}{1}{O}  ;FDD1
	} else if( slotNo == "2" ) {
		Send {F11}{2}{O}  ;FDD2
	} else {
		return
	}
	
	WinWait, Select floppy image
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
		Send {F11}{1}{E}  ;FDD1
	} else if( slotNo == "2" ) {
		Send {F11}{2}{E}  ;FDD2
	} else {
		return
	}
    
}


setConfig( imageFilePath ) {

	currDir := FileUtil.getDir( imageFilepath )
	confDir := currDir . "\_EL_CONFIG"
	
	NekoIniFile := % A_ScriptDir "\np2nt.ini"
	
	if( currDir = "" ) {
		IniWrite, %A_ScriptDir%\font.rom, %NekoIniFile%, NekoProjectII, fontfile
		IniWrite, 0, %NekoIniFile%, NekoProjectII, windtype
		IniWrite, false, %NekoIniFile%, NekoProjectII, Mouse_sw
		return false
	}
	
	; Set font
	
	IfExist %confDir%\font
	{
		Loop, %confDir%\font\*.*
		{
			IniWrite, %A_LoopFileFullPath%, %NekoIniFile%, NekoProjectII, fontfile
			break
		}
	} else {
		IniWrite, %A_ScriptDir%\font.rom, %NekoIniFile%, NekoProjectII, fontfile
	}

	; Set WindowType
	IniWrite, 0, %NekoIniFile%, NekoProjectII, WindposX
	IniWrite, 0, %NekoIniFile%, NekoProjectII, WindposY
	IniWrite, 1, %NekoIniFile%, NekoProjectII, windtype
	
	; Lock Mouse
	IniWrite, true, %NekoIniFile%, NekoProjectII, Mouse_sw

	; Init INI

	IniWrite, %currDir%, %NekoIniFile%, NekoProjectII, FDfolder
	IniWrite, %currDir%, %NekoIniFile%, NekoProjectII, HDfolder
	
	Loop, 8
	{
		fdIndex := A_Index - 1
		IniDelete, %NekoIniFile%, NP2 tool, FD1NAME%fdIndex%
		IniDelete, %NekoIniFile%, NP2 tool, FD2NAME%fdIndex%		
	}
	
	IniDelete, %NekoIniFile%, NekoProjectII, HDD1FILE
	IniDelete, %NekoIniFile%, NekoProjectII, HDD2FILE

	; Set Hdd & Fdd
	files := FileUtil.getFiles( currDir, "i).*\.(hdi|hdd)" )
	Loop, % files.MaxIndex()
	{
		if( A_Index > 2 )
			break
		IniWrite, % files[a_index], %NekoIniFile%, NekoProjectII, HDD%a_index%FILE
	}

	files := FileUtil.getFiles( currDir, "i).*\.(d88|fdi)" )
	Loop, % files.MaxIndex()
	{
		IniWrite, % files[a_index], %NekoIniFile%, NP2 tool, FD2NAME%a_index%
		IniWrite, % files[a_index], %NekoIniFile%, NP2 tool, FD1NAME%a_index%
	}

	return true

}