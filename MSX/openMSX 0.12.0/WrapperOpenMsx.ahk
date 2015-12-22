#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

ptr := A_PtrSize ? "Ptr" : "UInt"
char_size := A_IsUnicode ? 2 : 1

emulatorPid    := ""
imageFilePath  := %0%
;imageFilePath  := "\\NAS\emul\image\MSX\YS2"
imageFilePath   := "\\NAS\emul\image\MSX\MSX2 Various\ÀÌ½º 2 [Ancient Ys Vanished II - The Final Chapter (1988)(Falcom)(T-En)]"

fddContainer := new DiskContainer( imageFilePath, "i).*\.dsk\.zip" )
fddContainer.initSlot( 2 )

option := setConfig( imageFilePath )

if( option != false ) {

	pipeName := "openMsxPipe"
	pipe     := a_scriptDir "\" pipeName

	; pipe      := CreateNamedPipe( pipeName, 2 )

	;DllCall("ConnectNamedPipe","uint",pipe,"uint",0)

	;MsgBox % "openmsx.exe -machine BOOSTED_MSX2+_JP -control pipe " option " > " pipeName
;	msgbox powershell.exe -noexit -command ".\openmsx.exe -machine BOOSTED_MSX2+_JP %option% -control pipe > %pipeName%"
	;MsgBox, % "openmsx.exe -machine BOOSTED_MSX2+_JP " option

	;Run, % "openmsx.exe -machine BOOSTED_MSX2+_JP -control stdio" option,,, emulatorPid
	Run, % "openmsx.exe -machine BOOSTED_MSX2+_JP" option,,, emulatorPid
	
	;run, powershell.exe -noexit -command ".\openmsx.exe -machine BOOSTED_MSX2+_JP -diska ""\\NAS\emul\image\MSX\YS2\Ancient Ys Vanished II - The Final Chapter (1988)(Falcom)(Disk 1 of 2)(Game Disk).dsk.zip"""" -diskb ""\\NAS\emul\image\MSX\YS2\Ancient Ys Vanished II - The Final Chapter (1988)(Falcom)(Disk 2 of 2)(Data Disk).dsk.zip"""" -control stdio",,, emulationPid
	
	;Run, openmsx.exe -machine BOOSTED_MSX2+_JP %option%,,, emulatorPid
	;Run, % "openmsx.exe -machine BOOSTED_MSX2+_JP -control pipe " option,,HIDE,emulatorPid

	;shell.run( "openmsx.exe -machine BOOSTED_MSX2+_JP -control pipe " option " > """ pipeName """" )

;	Sleep, 100

; MsgBox, Start

;Sleep, 1000

;WinUAE( "<command>set renderer SDL</command>" )

; While ! DllCall( "WaitNamedPipe", "Str", pipeName, "Ptr", 0xffffffff)
;     Sleep, 500

WinWait, ahk_exe openmsx.exe,,5
IfWinExist
{

	;sendCommand( "<openmsx-control>" )
	;sendCommand( "unset renderer" )
	;sendCommand( "set power on" )

;c:\Users\Administrator\AppData\Local\Temp\openmsx-default\
	WinWaitClose, ahk_exe openmsx.exe

}
	

	; Sleep, 2000

	; message := ""

 ;    while "" != (data := pipe.Read(4096))
	; 	message .= data
       
 ;    msgbox % message



; while ConnectNamedPipe(pipeName)
; {
;     ; Read the message incrementally (if it is long).
;     message := ""
;     while "" != (data := pipe.Read(4096))
; 		message .= data
       
;     ; Process the message.
;     ;MsgBox % message
;     ;Run, %message%
;     params .= message
;     ;params .= " """ message """"
;     msgbox % params
		  		
;     ; Disconnect so that we can accept another connection.
;     DllCall("DisconnectNamedPipe", "ptr", hpipe)	
; }

; DllCall("ConnectNamedPipe", ptr, pipe, ptr, 0)

; MsgBox, Connected

; PipeMsg := (A_IsUnicode ? chr(0xfeff) : chr(239) chr(187) chr(191)) . PipeMsg
; If !DllCall("WriteFile", ptr, pipe, "str", PipeMsg, "uint", (StrLen(PipeMsg)+1)*char_size, "uint*", 0, ptr, 0)
;     MsgBox WriteFile failed: %ErrorLevel%/%A_LastError%

; ;MsgBox, Click OK to close handle

; DllCall("CloseHandle", ptr, pipe)


; Loop, read, %pipe_name%
;  MSgBox, %A_LoopReadLine%



	; WinWait, ahk_exe openmsx.exe,,5
	; IfWinExist
	; {

	; 	WinWaitClose, ahk_exe openmsx.exe

	; 	; MsgBox, End


	; }
	
} else {
	Run, % ".\Catapult\bin\Catapult.exe",,,emulatorPid
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

^+F4:: ;Exit
	WinActivate, ahk_class SDL_app ahk_exe openmsx.exe
	Send !{F4}
	return

^+Insert:: ; Toggle Speed
	Tray.show( "Toggle speed" )
	WinActivate, ahk_class SDL_app ahk_exe openmsx.exe
	Send {F9}
	return

sendCommand( command ) {
	IfWinExist, ahk_exe openmsx.exe
	{
		if ! RegExMatch( command, "^<.+?>$") {
			command := "<command>" command "</command>"
		}

		WinActivate, ahk_class ConsoleWindowClass ahk_exe openmsx.exe
		SendInput, %command%`n
		WinActivate, ahk_class SDL_app ahk_exe openmsx.exe
	}
}

StrPutVar( string, ByRef var, encoding ) {
    ; Ensure capacity.
    VarSetCapacity( var, StrPut(string, encoding)
        ; StrPut returns char count, but VarSetCapacity needs bytes.
        * ((encoding="utf-16"||encoding="cp1200") ? 2 : 1) )
    ; Copy or convert the string.
    return StrPut( string, &var, encoding )
}

reset() {
	WinActivate, ahk_class SDL_app ahk_exe openmsx.exe
	Send, {F10}
	Send, reset
	Send, {Enter}
	Send, {F10}
	return
}

insertDisk( slotNo, file ) {

	IfNotExist % file 
        return

    command := file
	command := RegExReplace( command, "\\", "/" )
	command := RegExReplace( command, "( |\[|\])", "\$1" )

	if ( slotNo == "1" ) {
		command := "diska " command
	} else if( slotNo == "2" ) {
		command := "diskb " command
	} else {
		return
	}

	StrPutVar( command, commandNew, "utf-16" )
	MsgBox, %commandNew%
	sendCommand( commandNew )
	;sendCommand( command )

}

removeDisk( slotNo ) {

    WinActivate, ahk_class blueMSX

	if ( slotNo == "1" ) {
		sendCommand( "diska eject" )
	} else if( slotNo == "2" ) {
		sendCommand( "diskb eject" )
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
		option := % option " -cassetteplayer """ files[ 1 ] """"
		return option
	}

	; Add Rom
	files := FileUtil.getFiles( currDir, "i).*\.rom\.zip" )
	if ( files.MaxIndex() > 0 ) {
		Loop, % files.MaxIndex()
		{
			if( a_index == 1 )
				option := % option " -carta """ files[a_index] """"

			if( a_index == 2 )
				option := % option " -cartb """ files[a_index] """"

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
				option := % option " -diska """ files[a_index] """"

			if( a_index == 2 )
				option := % option " -diskb """ files[a_index] """"

			if( a_index > 2 )			
			    break
		}
		return option
	}

	return false

}
