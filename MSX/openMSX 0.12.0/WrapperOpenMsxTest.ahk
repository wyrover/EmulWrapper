#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

emulatorPid    := ""
imageFilePath  := %0%
;imageFilePath  := "d:\app\dev\MSXROM\YS2 [Test]"

imageFilePath := "\\NAS\emul\image\MSX\MSX2 Various\XZR II (1988)(Telenet Japan)"

imageFilePath := "\\NAS\emul\image\MSX\MSX2 Various\¿ÃΩ∫ 2 [Ancient Ys Vanished II - The Final Chapter (1988)(Falcom)(T-Kr)]"

fddContainer := new DiskContainer( imageFilePath, "i).*\.dsk\.zip" )
fddContainer.initSlot( 2 )

executor := new Executor()
option   := setConfig( imageFilePath )

if( option != false ) {

  	commandLine := "openmsx.exe -machine BOOSTED_MSX2+_JP -control stdio" option

  	executor := new Executor()

  	executor.run( commandLine, false )

  	if ( "" == executor.readPipe() ) {
		executor.close()
		ExitApp
  	}

  	sendCommand( "<openmsx-control>" )
	sendCommand( "unset renderer" )
	sendCommand( "set power on" )

	sendCommand( "diska" )

	Sleep, 300
	Msgbox % executor.readPipe()

	;executor.waitForClose()
  
	executor.close()	
	
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

		if ! RegExMatch( command, "^<.+?>$") {
			command := "<command>" command "</command>"
		}

		executor.writePipe( command )

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

	;sendCommand( command )
	;StrPutVar( command, commandNew, "utf-16" )
	;sendCommand( commandNew )

	; Sleep, 300
	; MsgBox % executor.readPipe()
	sendCommand( "diska" )

	Sleep, 500

	MsgBox, % executor.readPipe()

	MsgBox, ReadPipe End


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


/**
 * Executor with in/out pipe
 */
class Executor {

	hStdInputReadPipe   := 0
	hStdInputWritePipe  := 0
	hStdOutputReadPipe  := 0
	hStdOutputWritePipe := 0
	inputPipe           := 0
	outputPipe          := 0
	processId           := 0

    __New() {
    }

    run( commandLine, showConsole=true ) {

		DllCall( "CreatePipe", "Ptr*", hStdInputReadPipe,  "Ptr*", hStdInputWritePipe,  "UInt", 0, "UInt", 0 )
		DllCall( "CreatePipe", "Ptr*", hStdOutputReadPipe, "Ptr*", hStdOutputWritePipe, "UInt", 0, "UInt", 0 )

		DllCall( "SetHandleInformation", "Ptr", hStdInputReadPipe,   "UInt", 1, "UInt", 1 )
		DllCall( "SetHandleInformation", "Ptr", hStdOutputWritePipe, "UInt", 1, "UInt", 1 )

		VarSetCapacity( processInfo, 24, 0 )
		sizeofStartupInfo := VarSetCapacity( pStartupInfo, 96, 0 )

		NumPut( sizeofStartupInfo,   pStartupInfo,  0, "UInt" )
		NumPut( 0x00000100,          pStartupInfo, 60, "UInt" )
		NumPut( hStdInputReadPipe,   pStartupInfo, 80, "Ptr"  )
		NumPut( hStdOutputWritePipe, pStartupInfo, 88, "Ptr"  )
		NumPut( hStdOutputWritePipe, pStartupInfo, 96, "Ptr"  )

				showFlag := 0
        if( showConsole == false ) {
        		showFlag := 0x08000000 ; Create_NO_WINDOW
        }

		DllCall( "CreateProcessW"
		  	, "UInt", 0
		  	, "Ptr",  &commandLine
		  	, "UInt", 0
		  	, "UInt", 0
		  	, "Int",  1
		  	, "UInt", showFlag
		  	, "UInt", 0
		  	, "Ptr",  &A_ScriptDir
		  	, "Ptr",  &pStartupInfo
		  	, "Ptr",  &processInfo )

		this.processId := NumGet( processInfo, 16, "UInt" )

		Process, Wait, % this.processId

		DllCall( "CloseHandle", "Ptr", NumGet(processInfo, 0) )
		DllCall( "CloseHandle", "Ptr", NumGet(processInfo, 8) )

		this.inputPipe  := FileOpen( hStdInputWritePipe, "h" )
		this.outputPipe := FileOpen( hStdOutputReadPipe, "h" )

		this.hStdInputReadPipe   := hStdInputReadPipe
		this.hStdInputWritePipe  := hStdInputWritePipe
		this.hStdOutputReadPipe  := hStdOutputReadPipe
		this.hStdOutputWritePipe := hStdOutputWritePipe


    }

    waitForClose() {

		Loop {
		    Process, Exist, % this.processId
		    if (ErrorLevel == 0) {
		      break
		    }
		    Sleep, 100
		}

    }

    close() {

		this.inputPipe.Close()
		this.outputPipe.Close()

		hStdInputReadPipe   := this.hStdInputReadPipe
		hStdInputWritePipe  := this.hStdInputWritePipe
		hStdOutputReadPipe  := this.hStdOutputReadPipe
		hStdOutputWritePipe := this.hStdOutputWritePipe

		DllCall( "CloseHandle", "Ptr", hStdInputReadPipe   )
		DllCall( "CloseHandle", "Ptr", hStdInputWritePipe  )
		DllCall( "CloseHandle", "Ptr", hStdOutputReadPipe  )
		DllCall( "CloseHandle", "Ptr", hStdOutputWritePipe )

		Process, Close, % this.processId

    }

    readPipe() {

		while "" == ( line := this.outputPipe.Read() )
		{
	  		Sleep, 200
	  	  	if ( a_index > 25 ) {
	  	  		return ""
	  	  	}		
		}

		result := line

    	while "" != ( line := this.outputPipe.Read() )
    	{
    		result .= line
    	}

    	return result

    }

    writePipe( command ) {
		this.inputPipe.WriteLine( command )
		this.inputPipe.Read( 0 )
    }

    getProcessId() {
    	return this.processId
    }

}
