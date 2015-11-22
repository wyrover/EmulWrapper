#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

imageFilePath  := %0%
;imageFilePath  := "\\NAS\emul\image\Apple2gs\adventure\Police Quest (1987)(Sierra)"
;imageFilePath   := "\\NAS\emul\image\Apple2gs\adventure\King's Quest (1987)(Sierra)"
;imageFilePath   := "\\NAS\emul\image\Apple2gs\rpg\Dragon Wars (1990)(Interplay)"
;imageFilePath   := "\\NAS\emul\image\Apple2gs\rpg\Dragon Wars (1990)(Interplay)\Dragon Wars (1990)(Interplay)(DIsk1).hdd.zip"
;imageFilePath   := "\\NAS\emul\image\Apple2gs\temp\Downhill Challenge (1989)(Broderbund)"

fddContainer := new DiskContainer( imageFilePath, "i)^(?!.*?(hdd|dsk)).*\.(zip|2mg)$" )
fddContainer.initSlot( 2 )

global bootSlot := 5

setCacheDir()

if( setConfig( imageFilePath ) == true )
{

	Run, % "ActiveGS.exe """ FileUtil.getDir( imageFilepath ) "\run.activegsxml""",,,emulatorPid
	WinWait, ahk_class AfxFrameOrView90s,, 5
	IfWinExist
	{

		ResolutionChanger.change( 800, 600 )
		;Sleep, 600
		WinSet, Style, -0xC40000, ahk_class AfxFrameOrView90s   ; remove the titlebar and border(s) 
		;WinMove, ahk_class AfxFrameOrView90s,, -42, -50, 884, 697  ; remove border
		WinMove, ahk_class AfxFrameOrView90s,, 0, 0, 800, 600  ; move the window to 0,0 and reize it to 800x600 (show original)
		Send {F8} ; Lock Mouse

		WinWaitClose, ahk_class AfxFrameOrView90s
	}
	
	ResolutionChanger.restore()
	
} else {
	Run, % "ActiveGS.exe",,,emulatorPid
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

^+Insert:: ; Toggle Speed
	WinActivate, ahk_class AfxFrameOrView90s
	Click 50, 50, right

	WinWait, ahk_class #32770
	IfWinExist
	{

		WinActivate, ahk_class #32770
		Click 110, 47, left
		Click 140, 80, left
		Send {home}

		if ( speedNormal != false ) {
			Send {end}
			speedNormal := false
			Tray.show( "Toggle speed to unlimited" )
		} else {
			speedNormal := true
			Tray.show( "Toggle speed to normal" )
		}

		WinClose, ahk_class #32770
		Send {F8} ; Lock Mouse
	}
    return

^+F4:: ; Control + Shift + F4
	WinClose, ahk_class AfxFrameOrView90s
	return

reset() {

	WinActivate, ahk_class AfxFrameOrView90s
	Click 50, 50, right

	WinWait, ahk_class #32770
	IfWinExist
	{

		WinActivate, ahk_class #32770
		Click 47, 47, left

		if ( bootSlot = 5 ) {
			Click 270, 195, left
		} else if( bootSlot = 7 ) {
			Click 325, 195, left
		}

		WinClose, ahk_class #32770
		Send {F8} ; Lock Mouse
	}
}

insertDisk( slotNo, file ) {

	WinActivate, ahk_class AfxFrameOrView90s
	Click 50, 50, right

	WinWait, ahk_class #32770
	IfWinExist
	{

		WinActivate, ahk_class #32770
		Click 47, 47, left
		Click 47, 195, left
		Send {home}{enter}

		if( slotNo != "1" )
			Send {down}

		Send {tab}{tab}{tab}{tab}
		Clipboard = %file%
		Send ^v
		Send +{tab}{Enter}
		WinClose, ahk_class #32770
		Send {F8} ; Lock Mouse
	}
    
}

removeDisk( slotNo ) {
	WinActivate, ahk_class AfxFrameOrView90s
	Click 50, 50, right

	WinWait, ahk_class #32770
	IfWinExist
	{

		WinActivate, ahk_class #32770
		Click 47, 47, left
		Click 47, 195, left
		Send {home}{enter}

		if( slotNo != "1" )
			Send {down}

		Send {tab}{tab}{tab}{tab}{tab}
		Send {Enter}
		WinClose, ahk_class #32770
	}

}

setCacheDir() {
	cacheDir := "z:\emuLoader\apple2gs"
	FileCreateDir, %cacheDir%
	IfExist, %cacheDir%
	{
		Linker.linkDir( "c:/users/" a_username "/My Documents/ActiveGSLocalData", cacheDir )	
	}
}

setConfig( imageFilePath ) {

	currDir := FileUtil.getDir( imageFilepath )
	confDir := currDir . "\_EL_CONFIG"

	if( currDir = "" )
		return false

	activegsxml =
	(
		<?xml version="1.0" encoding="ISO-8859-1"?>
		<config version="2">
		  <name>default</name>
		  <desc>default</desc>
		  <notes/>
		  <format >2GS</format>
		  <year>1989</year>
		  <publisher url="http://www.freetoolsassociation.com">Free Tools Association</publisher>
		  <image slot="5" disk="1" icon=""></image>
		  <image slot="5" disk="2" icon=""></image>
		  <image slot="6" disk="1" icon=""></image>
		  <image slot="6" disk="2" icon=""></image>
		  <image slot="7" disk="1" icon=""></image>
		  <image slot="7" disk="2" icon=""></image>
		  <image slot="7" disk="3" icon=""></image>
		  <image slot="7" disk="4" icon=""></image>
		  <speed>2</speed> <!-- 0:unlimited, 2:normal, 3:zip-->
		  <bootslot>5</bootslot>
		  <emulatorParam>background:dark-blue;border:dark-blue;videoFX:lcd;</emulatorParam>
		  <systemParam></systemParam>
		</config>
	)

	;<emulatorParam>background:black;border:dark-blue</emulatorParam>
	;<emulatorParam>background:dark-blue;border:dark-blue;PNGBoarder:0</emulatorParam>
	;<systemParam></systemParam>

	diskIndex := []
	diskIndex.Insert( "//config/image[@slot='5'][@disk='1']" )
	diskIndex.Insert( "//config/image[@slot='5'][@disk='2']" )
	
	hddIndex  := []
	hddIndex.Insert( "//config/image[@slot='7'][@disk='1']" )
	hddIndex.Insert( "//config/image[@slot='7'][@disk='2']" )
	hddIndex.Insert( "//config/image[@slot='7'][@disk='3']" )
	hddIndex.Insert( "//config/image[@slot='7'][@disk='4']" )

	x := new XML( activegsxml )

    files := FileUtil.getFiles( imageFilePath, "i)^(?!.*?(hdd|notInsert)).*\.(zip|2mg|po)$" )
	Loop, % files.MaxIndex()
	{
		if( a_index > 2 )
			break

		x.setText( diskIndex[A_Index], files[A_Index] )
	}

    files := FileUtil.getFiles( imageFilePath, "i)^.*\.hdd\.(zip|2mg|po)$" )
	Loop, % files.MaxIndex()
	{
		if( a_index > 4 )
			break

		x.setText( hddIndex[A_Index], files[A_Index] )
		x.setText( "//config/bootslot", "7" )

		bootSlot := 7
	}

	;x.viewXML()
	x.save( currDir . "\run.activegsxml" )

	return true

}