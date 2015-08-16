#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

emulatorPid := ""

imageFilePath := %0%
;imageFilePath := "d:\download\PS1 ROM\전국무쌍 (한글판)\Sengoku Mugen (J).ccd"

if ( imageFilePath = "" ) {

    Run, % "ePSXe.exe",,,emulatorPid
	ExitApp	

} else {

	setConfig( imageFilePath )

	if ( VirtualDisk.open( imageFilePath ) = true ) {
		;RunWait, % "ePSXe.exe -nogui -slowboot",,,emulatorPid
		RunWait, % "ePSXe.exe -nogui",,,emulatorPid
		VirtualDisk.close()
	} else {
;		MsgBox, % "ePSXe.exe -nogui -loadbin """ imageFilePath """"
    	RunWait, % "ePSXe.exe -nogui -loadbin """ imageFilePath """",,,emulatorPid
	}

	ExitApp

}

!F4:: ; ALT + F4

    ;SetWinDelay, 50
	;PostMessage, 0x111, 40007,,,ahk_class EPSX	; Exit ePSXe ; ControlSend,, {Esc down}{Esc up}, ePSXe ahk_class EPSX
	;RunWait, taskkill /im ePSXe.exe /f
	Process, Close, %emulatorPid%

    ResolutionChanger.restore()
    VirtualDisk.close()

    ExitApp
	
^F3::
    Tray.show( "Merong", "blablah" )
	return


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