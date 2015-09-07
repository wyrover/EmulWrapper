#NoEnv

fileIni := A_ScriptDir "\Run.ini"
fileReg := A_ScriptDir "\Run.reg"

prop := readProperties( fileIni )

; set default
prop[ "cd" ] := A_ScriptDir

setRegistry( fileReg, prop )

runProgram( fileIni, prop )


ExitApp


runProgram( fileIni, properties ) {

	IniRead, resolution,  %fileIni%, init, resolution
	if ( resolution != "ERROR" && resolution != "" ) {
    	width  := Trim( RegExReplace( resolution, "i)^(.*?)x.*?$", "$1" ) )
    	height := Trim( RegExReplace( resolution, "i)^.*?x(.*?)$", "$1" ) )
		ResolutionChanger.change( width, height )
	}


	IniRead, execPath,  %fileIni%, init, executor
	IniRead, isRunWait, %fileIni%, init, runWait
	
	if ( execPath != "ERROR" && execPath != "" ) {
		
		execPath := bindValue( execPath, properties )
		SplitPath, execPath, , execDir
		
		if ( isRunWait == "true" || (resolution != "ERROR" && resolution != "") )
		{
			RunWait %execPath%, %execDir%
			;MsgBox % "RunWait : " isRunWait "," resolution
			;Run %execPath%, %execDir%
			ResolutionChanger.restore()
		} else {
			Run %execPath%, %execDir%
			;msgbox Run
		}

		;msgbox % "isRunWait:" isRunWait  ", resolution:" resolution ", result:"  ( isRunWait != true )

	}



}


isFile( path ) {

	IfNotExist %path%, return false

	FileGetAttrib, attr, %path%
	
	Return ! InStr( attr, "D" )

}

readProperties( file ) {

	prop     := []
	readMode := false

	Loop, Read, %file%
	{

		if RegExMatch(A_LoopReadLine, "^#.*" )
			continue

		if ( readMode == false ) {
			if RegExMatch(A_LoopReadLine, "i)^\[properties\]" )
				readMode = true
			continue
		} else {
			If RegExMatch(A_LoopReadLine, "^\[.*\]" ) {
				readMode = false
				continue
			}
		}

    key := RegExReplace( A_LoopReadLine, "^(.*?)=.*?$", "$1" )
    val := RegExReplace( A_LoopReadLine, "^.*?=(.*?)$", "$1" )

		prop[ Trim(key) ] := Trim(val)

	}

	return prop

}

/**
* Write Registry from file 
*
* @param file       {String} filePath contains data formatted Windows Registry
* @param properties {Array}  properties to bind
*/
setRegistry( file, properties ) {

	regKey       := ""
	readNextLine := false
	isHex        := true

	Loop, Read, %file%
	{

		if RegExMatch(A_LoopReadLine, "^Windows Registry Editor" ) {
			continue
		} else if ( StrLen(A_LoopReadLine) == 0 ) {
			Continue
		} else if RegExMatch(A_LoopReadLine, "^\[.*\]" ) {
			regKey := RegExReplace( A_LoopReadLine, "^\[(.*)\]", "$1" )
			continue
		} else if ( regKey == "" ) {
			continue
		}

		if ( readNextLine == true ) {
			regVal := regVal A_LoopReadLine
		} else {
	
			regName := RegExReplace( RegExReplace( A_LoopReadLine, "^""(.*?)""=.*$", "$1" ), "\\""", """" )
			;regName := RegExReplace( A_LoopReadLine, "^""(.*?)""=.*$", "$1" )
			regVal  := RegExReplace( A_LoopReadLine, "^"".*?""=(.*)$", "$1" )
			regType := "REG_SZ"
			
			if RegExMatch( regVal, "^"".*""$" ) {
				regType := "REG_SZ"
				regVal  := bindValue( RegExReplace( regVal, "^""(.*)""$", "$1" ), properties )
				isHex   := false
			} else if RegExMatch( regVal, "^dword:" ) {
				regType := "REG_DWORD"
				regVal  := RegExReplace( regVal, "^dword:(.*)$", "$1" )
				isHex   := false
			} else if RegExMatch( regVal, "^hex\(b\):" ) {
				regType := "REG_QWORD"
				regVal  := RegExReplace( regVal, "^hex\(b\):(.*)$", "$1" )
				isHex   := true
			} else if RegExMatch( regVal, "^hex\(7\):" ) {
				regType := "REG_MULTI_SZ"
				regVal  := RegExReplace( regVal, "^hex\(7\):(.*)$", "$1" )
				isHex   := true
			} else if RegExMatch( regVal, "^hex\(2\):" ) {
				regType := "REG_EXPAND_SZ"
				regVal  := RegExReplace( regVal, "^hex\(2\):(.*)$", "$1" )
				isHex   := true
			} else if RegExMatch( regVal, "^hex:" ) {
				regType := "REG_BINARY"
				regVal  := RegExReplace( regVal, "^hex:(.*)$", "$1" )
				isHex   := true
			}
			
		}

		if ( RegExMatch(regVal, "^.*\\$") ) {
      		readNextLine := true
      		continue
		} else {
			readNextLine := false
		}

		if ( isHex == true ) {
			regVal := RegExReplace( regVal, "[\\\t ]", "" )

			if ( regType == "REG_QWORD" ) {
				;; Not Working !!
				regVal := toNumberFromHex( regVal )
			} else {
				regVal := toStringFromHex( regVal )
			}

		}

		RegWrite, % regType, % regKey, % regName, % regVal

	}

}

bindValue( value, properties ) {

	For key, val in properties
		value := StrReplace( value, "#{" key "}", val )

	return value

}

toStringFromHex( hexValue ) {

  if ! hexValue
    return 0

  array := StrSplit( hexValue, "," )

  if ( mod( array.MaxIndex(), 2 ) != 0 ) {
  	array.Insert( "00" )
  }

  result := ""

  for i, element in array
  {
  	if ( mod(i,2) == 0 )
  		Continue

  	result := result chr( "0x" array[i + 1] array[i] )
  }

  return result

}

toNumberFromHex( hexValue ) {

  if ! hexValue
    return 0

  array := StrSplit( hexValue, "," )

  if ( mod( array.MaxIndex(), 2 ) != 0 ) {
  	array.Insert( "00" )
  }

  result := ""

  for i, element in array
  {
  	if ( mod(i,2) == 0 )
  		Continue

  	result := array[i + 1] array[i] result

  }

  ;return "0x" result
  return "0x0000000c"

}

convertBase( fromBase, toBase, number )
{
    static u := A_IsUnicode ? "_wcstoui64" : "_strtoui64"
    static v := A_IsUnicode ? "_i64tow"    : "_i64toa"
    VarSetCapacity(s, 65, 0)
    value := DllCall("msvcrt.dll\" u, "Str", number, "UInt", 0, "UInt", fromBase, "CDECL Int64")
    DllCall("msvcrt.dll\" v, "Int64", value, "Str", s, "UInt", toBase, "CDECL")
    return s
}


class ResolutionChanger {

    static void := ResolutionChanger._init()

    _init() {
        this.srcWidth  := A_ScreenWidth
        this.srcHeight := A_ScreenHeight
    }
  
    __New() {
        throw Exception( "ResolutionChanger is a static class, dont instante it!", -1 )
    }


    change( width, height ) {

    	If ( RegExMatch(width, "^\d+$") == false || RegExMatch(height, "^\d+$") == false ) {
    		MsgBox Resolution must be consisted with digit values ( input values : [%width%]x[%height%])
    	    return
    	}

        VarSetCapacity( dM, 156, 0 )
        NumPut( 156, dM, 36 )
        NumPut( 0x5c0000, dM, 40 )
        NumPut( width, dM, 108 )
        NumPut( height, dM, 112 )
        DllCall( "ChangeDisplaySettingsA", UInt,&dM, UInt,0 )
    }
  
    /*
    change( width, height, colorDepth:=32, Hz:=60 ) {
        VarSetCapacity( dM,156,0 ), NumPut( 156,2,&dM,36 )
        DllCall( "EnumDisplaySettings", UInt,0, UInt,-1, UInt,&dM ), NumPut(0x5c0000,dM,40)
        NumPut(cD,dM,104),  NumPut(sW,dM,108),  NumPut(sH,dM,112),  NumPut(rR,dM,120)
        Return DllCall( "ChangeDisplaySettings", UInt,&dM, UInt,0 )
    }
    */
  
    restore() {
        if ( A_ScreenWidth != this.srcWidth || A_ScreenHeight != this.srcHeight ) {
            this.change( this.srcWidth, this.srcHeight )
        }
    }

}


; Sends text to a console's input stream. WinTitle may specify any window in
; the target process. Since each process may be attached to only one console,
; ConsoleSend fails if the script is already attached to a console.

; ConsoleSend( text, WinTitle="", WinText="", ExcludeTitle="", ExcludeText="" ) {

;     WinGet, pid, PID, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
;     if !pid
;         return false, ErrorLevel:="window"
;     ; Attach to the console belonging to %WinTitle%'s process.
;     if !DllCall("AttachConsole", "uint", pid)
;         return false, ErrorLevel:="AttachConsole"
;     hConIn := DllCall("CreateFile", "str", "CONIN$", "uint", 0xC0000000
;                 , "uint", 0x3, "uint", 0, "uint", 0x3, "uint", 0, "uint", 0)
;     if hConIn = -1
;         return false, ErrorLevel:="CreateFile"
    
;     VarSetCapacity(ir, 24, 0)       ; ir := new INPUT_RECORD
;     NumPut(1, ir, 0, "UShort")      ; ir.EventType := KEY_EVENT
;     NumPut(1, ir, 8, "UShort")      ; ir.KeyEvent.wRepeatCount := 1
;     ; wVirtualKeyCode, wVirtualScanCode and dwControlKeyState are not needed,
;     ; so are left at the default value of zero.
    
;     Loop, Parse, text ; for each character in text
;     {
;         NumPut(Asc(A_LoopField), ir, 14, "UShort")
        
;         NumPut(true, ir, 4, "Int")  ; ir.KeyEvent.bKeyDown := true
;         gosub ConsoleSendWrite
        
;         NumPut(false, ir, 4, "Int") ; ir.KeyEvent.bKeyDown := false
;         gosub ConsoleSendWrite
;     }
;     gosub ConsoleSendCleanup
;     return true
    
;     ConsoleSendWrite:
;         if ! DllCall("WriteConsoleInput", "uint", hconin, "uint", &ir, "uint", 1, "uint*", 0)
;         {
;             gosub ConsoleSendCleanup
;             return false, ErrorLevel:="WriteConsoleInput"
;         }
;     return
    
;     ConsoleSendCleanup:
;         if (hConIn!="" && hConIn!=-1)
;             DllCall("CloseHandle", "uint", hConIn)
;         ; Detach from %WinTitle%'s console.
;         DllCall("FreeConsole")
;     return

; }