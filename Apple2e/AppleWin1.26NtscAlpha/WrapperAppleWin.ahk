#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

imageFilePath  := %0%
;imageFilePath  := "\\NAS\emul\image\Apple2e\Adventure\´º·Î¸Ç¼­ [Neuromancer (1988)(Interplay)]\Neuromancer (1988)(Interplay)(Disk 1 of 4).zip"
;imageFilePath  := "\\NAS\emul\image\Apple2e\Adventure\´º·Î¸Ç¼­ [Neuromancer (1988)(Interplay)]\01.zip"
;imageFilePath  := "\\NAS\emul\image\Apple2e\Adventure\´º·Î¸Ç¼­ [Neuromancer (1988)(Interplay)]"
;imageFilePath  := "\\NAS\emul\image\PC9801\0_imagesFdi\Ys 1\Ys 1 (Falcom).D88"

fddContainer := new DiskContainer( imageFilePath, "i).*\.zip" )
fddContainer.initSlot( 2 )

if( setConfig( imageFilePath ) == true )
{
	Run, % "AppleWin.exe -no-printscreen-dlg " fddOption,,,emulatorPid
	WinWait, ahk_class APPLE2FRAME,, 5
	IfWinExist
	{

		;WinSet, Style, -0xC40000, ahk_class APPLE2FRAME   ; remove the titlebar and border(s) 
		;WinMove, ahk_class APPLE2FRAME,, 0, 0, 1366, 778  ; move the window to 64,0 and reize it to 1152x720 (640x400)

		ResolutionChanger.change( 1440, 900 )
		reset()

		WinWaitClose, ahk_class APPLE2FRAME
	}
	
	ResolutionChanger.restore()
	
} else {
	Run, % "AppleWin.exe",,,emulatorPid
}

ExitApp

^+PGUP:: ; Insert Disk in Drive#1

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
	WinActivate, ahk_class APPLE2FRAME
	Send {F2}
}

insertDisk( slotNo, file ) {

	WinActivate, ahk_class APPLE2FRAME
	
	if( slotNo == "1" ) {
		Send {F3}  ;FDD1
	} else if( slotNo == "2" ) {
		Send {F4}  ;FDD2
	} else {
		return
	}
	
	WinWait, Select Disk Image For Drive
	IfWinExist
	{
		Send !{N}
		Clipboard = %file%
		Send ^v
		Send {Enter}
	}
    
}

removeDisk( slotNo ) {
	insertDisk( slotNo, "" )
}


setConfig( imageFilePath ) {

	registryPath := "Software\AppleWin\CurrentVersion"

	currDir := FileUtil.getDir( imageFilepath )
	confDir := currDir . "\_EL_CONFIG"

	if( currDir = "" )
		return false

	; Init
	;RegWrite REG_SZ, HKCU, %registryPath%\Configuration, Printer Filename, %currDir%\Printer.txt
	RegWrite REG_SZ, HKCU, %registryPath%\Configuration, Window Scale, 2
	RegWrite REG_SZ, HKCU, %registryPath%\Configuration, Confirm Reboot, 0
	RegWrite REG_SZ, HKCU, %registryPath%\Preferences, Window X-Position, 0
	RegWrite REG_SZ, HKCU, %registryPath%\Preferences, Window Y-Position, 0

	; Set Hdd

	RegWrite REG_SZ, HKCU, %registryPath%\Preferences, Starting Directory,
	RegWrite REG_SZ, HKCU, %registryPath%\Preferences, Last Harddisk Image 1,
	RegWrite REG_SZ, HKCU, %registryPath%\Preferences, Last Harddisk Image 2,

	files := FileUtil.getFiles( currDir, "i).*\.po" )
	Loop, % files.MaxIndex()
	{
		if( a_index > 2 )
			break
		
		RegWrite REG_SZ, HKCU, %registryPath%\Configuration, Harddisk Enable, 1
		RegWrite REG_SZ, HKCU, %registryPath%\Preferences, Last Harddisk Image %a_index%, % files[a_index]
	}
	
	if( files.MaxIndex() > 0 )
		RegWrite REG_SZ, HKCU, %registryPath%\Configuration, Harddisk Enable, 1
	else
		RegWrite REG_SZ, HKCU, %registryPath%\Configuration, Harddisk Enable, 0


	RegWrite REG_SZ, HKCU, %registryPath%\Preferences, Last Disk Image 1,
	RegWrite REG_SZ, HKCU, %registryPath%\Preferences, Last Disk Image 2,

	; Set Fdd

	files := FileUtil.getFiles( currDir, "i).*\.zip" )
	Loop, % files.MaxIndex()
	{
		if( a_index > 2 )
			break
		
		RegWrite REG_SZ, HKCU, %registryPath%\Preferences, % "Last Disk Image " a_index, % files[a_index]
	}
	
	return true

}