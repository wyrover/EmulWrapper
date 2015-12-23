#NoEnv

/**
 * Command line Interface with in / out pipe
 */
class Cli {

 	hStdInputWritePipe  := 0
 	hStdOutputReadPipe  := 0
 	processId           := 0

 	__New( commandLine, showConsole=true ) {

 		DllCall( "CreatePipe", "Ptr*", hStdInputReadPipe,  "Ptr*", hStdInputWritePipe,  "UInt", 0, "UInt", 0 )
 		DllCall( "CreatePipe", "Ptr*", hStdOutputReadPipe, "Ptr*", hStdOutputWritePipe, "UInt", 0, "UInt", 0 )

 		DllCall( "SetHandleInformation", "Ptr", hStdInputReadPipe,   "UInt", 1, "UInt", 1 )
 		DllCall( "SetHandleInformation", "Ptr", hStdOutputWritePipe, "UInt", 1, "UInt", 1 )

		if ( a_ptrSize == 4 ) {

	 		VarSetCapacity( processInfo, 16, 0 )
	 		startupInfoSize := VarSetCapacity( startupInfo, 68, 0 )

	 		NumPut( startupInfoSize,     startupInfo,  0, "UInt" )
	 		NumPut( 0x00000100,          startupInfo, 44, "UInt" )
	 		NumPut( hStdInputReadPipe,   startupInfo, 56, "Ptr"  )
	 		NumPut( hStdOutputWritePipe, startupInfo, 60, "Ptr"  )
	 		NumPut( hStdOutputWritePipe, startupInfo, 64, "Ptr"  )

		} else {

	 		VarSetCapacity( processInfo, 24, 0 )
	 		startupInfoSize := VarSetCapacity( startupInfo, 96, 0 )

	 		NumPut( startupInfoSize,     startupInfo,  0, "UInt" )
	 		NumPut( 0x00000100,          startupInfo, 60, "UInt" )
	 		NumPut( hStdInputReadPipe,   startupInfo, 80, "Ptr"  )
	 		NumPut( hStdOutputWritePipe, startupInfo, 88, "Ptr"  )
	 		NumPut( hStdOutputWritePipe, startupInfo, 96, "Ptr"  )

		}

 		DllCall( "CreateProcessW"
 			, "UInt", 0
 			, "Ptr",  &commandLine
 			, "UInt", 0
 			, "UInt", 0
 			, "Int",  1
 			, "UInt", showConsole == true ? 0 : 0x08000000 ; Create_NO_WINDOW
 			, "UInt", 0
 			, "Ptr",  &A_ScriptDir
 			, "Ptr",  &startupInfo
 			, "Ptr",  &processInfo )

 		this.processId := NumGet( processInfo, 16, "UInt" )

 		;MsgBox, % "processId : " this.processId "`nhStdOutputWritePipe : " hStdOutputWritePipe "`nhStdInputReadPipe : " hStdInputReadPipe

 		Process, Wait, % this.processId

 		DllCall( "CloseHandle", "Ptr", NumGet(processInfo, 0)         )
 		DllCall( "CloseHandle", "Ptr", NumGet(processInfo, a_ptrSize) )
 		DllCall( "CloseHandle", "Ptr", hStdOutputWritePipe            )
 		DllCall( "CloseHandle", "Ptr", hStdInputReadPipe              )

 		this.hStdInputWritePipe  := hStdInputWritePipe
 		this.hStdOutputReadPipe  := hStdOutputReadPipe

 	}

  __Delete() {
    this.close()
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

 		hStdInputWritePipe  := this.hStdInputWritePipe
 		hStdOutputReadPipe  := this.hStdOutputReadPipe

 		DllCall( "CloseHandle", "Ptr", hStdInputWritePipe  )
 		DllCall( "CloseHandle", "Ptr", hStdOutputReadPipe  )

 		Process, Close, % this.processId

 	}

 	readPipe( codepage="" ) {

    hStdOutputReadPipe:=this.hStdOutputReadPipe
    
    if ( codepage == "" )
      codepage := A_FileEncoding
    
    file   := FileOpen( hStdOutputReadPipe, "h", codepage )
    result := ""

    if ( IsObject(file) && file.AtEOF == 0 ) {
    	result := file.Read()
    }

    file.Close()

    return result

 	}

 	writePipe( command, codepage="" ) {

		hStdInputWritePipe  := this.hStdInputWritePipe

		if ( command == "" )
			return

		file := FileOpen( hStdInputWritePipe, "h", codepage )
		file.Write( command )
		file.Read(0) ; flush buffer
		file.Close()

 	}

 	getProcessId() {
 		return this.processId
 	}

}
