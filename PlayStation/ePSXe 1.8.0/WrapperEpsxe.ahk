#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

emulatorPid := ""

imageFilePath := %0%
;imageFilePath := "\\NAS\emul\image\PlayStation\어드벤쳐\물망초 [Forget Me Not - Pallete (T-Kr)]"

cdContainer := new DiskContainer( imageFilePath, "i).*\.(iso|cue|mdx)?$" )
cdContainer.initSlot( 1 )

if ( cdContainer.size() >= 1 ) {

	config := getConfig( imageFilepath )

	if ( VirtualDisk.open( cdContainer.getFile(1) ) == true ) {

		Run, % "ePSXe.exe " config,,,emulatorPid

		WinWait, ahk_class EPSXGUI,, 10
		IfWinExist
		{
			WinActivate, ahk_class EPSXGUI
			Send !{F}{Enter}
			Process, WaitClose, %emulatorPid%
		}

		VirtualDisk.close()
		
	} else {
		config := config " -loadbin """ cdContainer.getFile(1) """"
   	RunWait, % "ePSXe.exe " config,,,emulatorPid
	}

} else {
	Run, % "ePSXe.exe",,,emulatorPid	
}

ExitApp	


!F4:: ; ALT + F4
  ;SetWinDelay, 50
	;PostMessage, 0x111, 40007,,,ahk_class EPSX	; Exit ePSXe ; ControlSend,, {Esc down}{Esc up}, ePSXe ahk_class EPSX
	;RunWait, taskkill /im ePSXe.exe /f
	;Process, Close, %emulatorPid%
  ;ResolutionChanger.restore()
  openMainGui()
	Send !{F}{E}
  return
	
^+PGUP:: ; Change CD rom
	cdContainer.insertDisk( "1", "changeCdRom" )
	return


^+End:: ; Cancel Disk Change	
	cdContainer.cancel()
	return

^+Del:: ; Reset
	openMainGui()
	Send !{R}{R}
	waitEmulator()
	return

^+F4:: ;Exit
	Process, Close, %emulatorPid%
  ResolutionChanger.restore()
  VirtualDisk.close()
	return

^+Insert:: ; Toggle Speed
	Tray.show( "Toggle speed" )
	WinActivate, ahk_class EPSX

	SendInput {F4 down}
	Sleep, 50
	SendInput {F4 up}
	Sleep, 100

	return

openMainGui() {

	IfWinExist ahk_class EPSX
	{
		SendInput {Esc down}
		Sleep, 50
		SendInput {Esc up}
		Sleep, 100
	}

	WinWait, ahk_class EPSXGUI,, 10
	IfWinExist
	{
		WinActivate, ahk_class EPSXGUI
	}

}

waitEmulator() {
	WinWait, ahk_class EPSX,, 10
	IfWinExist
	{
		WinActivate, ahk_class EPSX
	}	
}

changeCdRom( slotNo, file ) {
	openMainGui()
	Send !{F}{C}{C}
	if ( VirtualDisk.open( file ) == true ) {
		WinActivate, ahk_exe ePSXe.exe ahk_class #32770
		Send {Enter}
	} else {
		WinActivate, ahk_exe ePSXe.exe ahk_class #32770
		Send {Escape}
	}
	waitEmulator()
	return
}

getConfig( imageFilePath ) {

	dirConf   := FileUtil.getDir( imageFilepath ) . "\_EL_CONFIG"
	dirBios   := dirConf "\bios"
	dirMemory := dirConf "\memcards"

	FileUtil.makeDir( dirConf )
	FileUtil.makeDir( dirMemory )	

	customBiosPath := ""

	IfExist %dirBios%
	{
		Loop, %dirBios%\*.bin
		{
			customBiosPath := A_LoopFileFullPath
			break
		}
	}

	IfNotExist %dirMemory%\epsxe001.mcr
		FileAppend,,%dirMemory%\epsxe001.mcr
	IfNotExist %dirMemory%\epsxe002.mcr
		FileAppend,,%dirMemory%\epsxe002.mcr

	option := ""

	if( customBiosPath != "" ) {
		option := option " -bios """ customBiosPath """"
	}

	option := option " -loadmemc0 """ dirMemory "\epsxe001.mcr" """"
	option := option " -loadmemc1 """ dirMemory "\epsxe002.mcr" """"

	option := option " -slowboot"
	;option := option " -nogui"

	return option
	
}

/*
setConfig( imageFilePath ) {
	
	registryPath := "S-1-5-21-108037658-2208837996-2228346073-500\Software\epsxe\config"
	
	confDir := FileUtil.getDir( imageFilepath ) . "\_EL_CONFIG"


	
	IfExist %confDir%\bios
	{
		Loop, %confDir%\bios\*.bin
		{
			;MsgBox %A_LoopFileFullPath%
			RegWrite, REG_SZ, HKU, %registryPath%, BiosName, %A_LoopFileFullPath%
			break
		}
	} else {
		Loop, %A_ScriptDir%\bios\*.bin
		{
			;MsgBox %A_LoopFileName%
			RegWrite, REG_SZ, HKU, %registryPath%, BiosName, bios\%A_LoopFileName%
			break
		}
	}
	
	IfExist %confDir%\memcards
	{
		IfNotExist %confDir%\memcards\epsxe001.mcr
			FileAppend,,%confDir%\memcards\epsxe001.mcr

		RegWrite, REG_SZ, HKU, %registryPath%, Memcard1, %confDir%\memcards\epsxe001.mcr

	} else {
		RegWrite, REG_SZ, HKU, %registryPath%, Memcard1, \memcards\epsxe001.mcr
		RegWrite, REG_SZ, HKU, %registryPath%, Memcard2, \memcards\epsxe002.mcr
	}

}
*/