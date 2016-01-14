#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

emulatorPid    := ""
imageFilePath  := %0%
;imageFilePath  := "\\NAS\emul\image\MSX\MSX1 Various\007 - A View to a Kill (1986)(Domark)"

fddContainer := new DiskContainer( imageFilePath, "i).*\.dsk\.zip" )
fddContainer.initSlot( 2 )

option := setConfig( imageFilePath )

if( option != false ) {

	Run, % "d:\app\Emul\MSX\blueMSXv282full\blueMSX.exe " option,,,emulatorPid
	WinWait, ahk_class blueMSX,, 10
	IfWinExist
	{
		reset()
		WinWaitClose, ahk_class blueMSX
	}
	
} else {
	Run, % "d:\app\Emul\MSX\blueMSXv282full\blueMSX.exe",,,emulatorPid
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

;!F4:: ;Exit
^+F4:: ;Exit
	Send, {ShiftUp}
	Send, {CtrlUp}
	WinActivate, ahk_class blueMSX
	;Send {CtrlBreak} ;Pause is not {Pause} but {CtrlBreak}
	Send {LCtrl Down}{CtrlBreak} ;Pause is not {Pause} but {CtrlBreak}
	;Send {CtrlBreak} ;Pause is not {Pause} but {CtrlBreak}
	Sleep, 10
	Send {LCtrl Up}
	return

^+Insert:: ; Toggle Speed
	Send, {ShiftUp}
	Send, {CtrlUp}
	Tray.showMessage( "Toggle speed" )
	WinActivate, ahk_class blueMSX
	Send {LCtrl Down}{LShift Down}{M}
	Send {LCtrl Up}
	Send {LShift Up}
	return

reset() {
	Send, {ShiftUp}
	Send, {CtrlUp}
	WinActivate, ahk_class blueMSX
	Send, {F12}
}

insertDisk( slotNo, file ) {

	IfNotExist % file 
    return

  WinActivate, ahk_class blueMSX
	
	if ( slotNo == "1" ) {
		Send {LCtrl Down}{F9}  ;FDD1
		Send {LCtrl Up}
	} else if( slotNo == "2" ) {
		Send {LCtrl Down}{F10} ;FDD2
		Send {LCtrl Up}
	} else {
		return
	}
	
	WinWait, ahk_class #32770
	IfWinExist
	{
		WinActivate, ahk_class #32770
		Send !{N}
		Clipboard = %file%
		Send ^v
		Send {Enter}
	}
    
}

removeDisk( slotNo ) {

  WinActivate, ahk_class blueMSX

	if( slotNo == "1" ) {
		Send {RCtrl Down}{F9}  ;FDD1
		Send {RCtrl Up}
	} else if( slotNo == "2" ) {
		Send {RCtrl Down}{F10} ;FDD2
		Send {RCtrl Up}
	}
    
}

setConfig( imageFilePath ) {

	currDir := FileUtil.getDir( imageFilepath )
	confDir := currDir . "\_EL_CONFIG"
	
	if( currDir = "" ) {
		return false
	}
	
	option := ""

	; Add Casette
	files := FileUtil.getFiles( currDir, "i).*\.cas\.zip" )
	if ( files.MaxIndex() > 0 ) {
		option := % option " /cas """ files[ 1 ] """"
		return option
	}

	; Add Rom
	files := FileUtil.getFiles( currDir, "i).*\.rom\.zip" )
	if ( files.MaxIndex() > 0 ) {
		Loop, % files.MaxIndex()
		{
			if( a_index == 1 )
				option := % option " /rom1 """ files[a_index] """"

			if( a_index == 2 )
				option := % option " /rom2 """ files[a_index] """"

			if( a_index > 2 )			
			    break
		}
		return option
	}

	; Add Disk
	files := FileUtil.getFiles( currDir, "i).*\.dsk\.zip" )
	if ( files.MaxIndex() > 0 ) {
		Loop, % files.MaxIndex()
		{
			if( a_index == 1 )
				option := % option " /diskA """ files[a_index] """"

			if( a_index == 2 )
				option := % option " /diskB """ files[a_index] """"

			if( a_index > 2 )			
			    break
		}
		return option
	}

	return false

}