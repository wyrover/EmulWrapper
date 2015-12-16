#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

emulatorPid    := ""
imageFilePath  := %0%
imageFilepath  := "\\NAS\emul\image\PC9801\0_imagesPatched\µ¿¹æºÀ¸¶·Ï [Story of Eastern Wonderland (T-Kr)]"


fddContainer := new DiskContainer( imageFilePath, "i).*\.(fdi)" )
fddContainer.initSlot( 2 )

if( setConfig(imageFilePath) == true )
{
	
	Run, % "anex86.exe -cdefault",,,emulatorPid
	
	WinWait, ahk_exe anex86.exe,, 5
	IfWinExist
	{
		WinWaitActive, ahk_exe anex86.exe,, 5
		IfWinActive
		{
			Send !s

			if( isNotFullScreen() )
			{

				ResolutionChanger.change( 1280, 720 )
				;ResolutionChanger.change( 640, 480 )

				WinWaitActive, ahk_class zwxwnd,, 5

				WinSet, Style, -0xC40000, ahk_class zwxwnd   ; remove the titlebar and border(s) 
				WinMove, ahk_class zwxwnd,, 64, 0, 1152, 720  ; move the window to 64,0 and reize it to 1152x720 (640x400)
				;WinMove, ahk_class zwxwnd,, 64, 0, 640, 480  ; move the window to 64,0 and reize it to 1152x720 (640x400)
				
				WinWaitClose, ahk_class zwxwnd
				WinClose ahk_exe anex86.exe

				ResolutionChanger.restore()
				
			} else {
				WinWaitActive, ahk_class zwxwnd,, 5
				WinWaitClose, ahk_class zwxwnd
				WinClose ahk_exe anex86.exe
			}

		}
	}
	
} else {
	Run, % "anex86.exe -cdefault",,,emulatorPid
}

ExitApp

setConfig( imageFilePath ) {
	
	registryPath := "S-1-5-21-108037658-2208837996-2228346073-500\Software\A.N.\anex86\config\default"
	
	currDir := FileUtil.getDir( imageFilepath )
	confDir := currDir . "\_EL_CONFIG"
	
	if( currDir == "" )
		return false
	
	IfExist %confDir%\font
	{
		Loop, %confDir%\font\*.*
		{
			RegWrite, REG_SZ, HKU, %registryPath%, font, %A_LoopFileFullPath%
			break
		}
	} else {
		Loop, %A_ScriptDir%\font.*
		{
			RegWrite, REG_SZ, HKU, %registryPath%, font, %A_LoopFileFullPath%
			break
		}
	}
	
	RegWrite,  REG_SZ, HKU, %registryPath%, hdd1,
	RegWrite,  REG_SZ, HKU, %registryPath%, hdd2,
	RegWrite,  REG_SZ, HKU, %registryPath%, hddhist,
	RegWrite,  REG_SZ, HKU, %registryPath%, fdd1,
	RegWrite,  REG_SZ, HKU, %registryPath%, fdd2,
	RegWrite,  REG_SZ, HKU, %registryPath%, fddhist,
	

	; Set Hdd & Fdd
	files := FileUtil.getFiles( currDir, "i).*\.(hdi)" )
	Loop, % files.MaxIndex()
	{
		if( a_index > 2 )
			break

		RegWrite REG_SZ, HKU, %registryPath%, hdd%a_index%, % files[a_index]

		if( a_index == 1 )
		RegWrite REG_SZ, HKU, %registryPath%, hddhist, % files[a_index]
	}

	files := FileUtil.getFiles( currDir, "i).*\.(fdi)" )
	Loop, % files.MaxIndex()
	{
		if( a_index > 2 )
			break

		RegWrite REG_SZ, HKU, %registryPath%, fdd%a_index%, % files[a_index]

		if( a_index == 1 )
		RegWrite REG_SZ, HKU, %registryPath%, fddhist, % files[a_index]
	}
	
    return true

}

isNotFullScreen() {
	
	registryPath := "S-1-5-21-108037658-2208837996-2228346073-500\Software\A.N.\anex86\config\default"
	
	RegRead output, HKU, %registryPath%, wmode
	
	wmode := SubStr( output, 3, 2 )
	
	return ( wmode != "19" ) ; 18 : window, 19 : fullScreen
	
}