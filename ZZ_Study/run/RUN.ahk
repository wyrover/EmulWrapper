#NoEnv

SplitPath, A_ScriptName, , , , NoextScriptFileName

fileIni := A_ScriptDir "\" NoextScriptFileName ".ini"
fileReg := A_ScriptDir "\" NoextScriptFileName ".reg"

prop := readProperties( fileIni )

; set default
prop[ "cd" ] := A_ScriptDir

setRegistry( fileReg, prop )

runSub( "pre", fileIni, prop )
runProgram( fileIni, prop )
runSub( "post", fileIni, prop )

ExitApp

runMidThread:
  SetTimer, runMidThread, off
  runSub( "mid", fileIni, prop )
  return

runSub( section, fileIni, properties ) {
  indices = ,0,1,2,3,4,5,6,7,8,9
  loop, parse, indices, `,
  {
	IniRead, executor,    %fileIni%, %section%, executor%a_loopfield%,    _
	IniRead, executorDir, %fileIni%, %section%, executor%a_loopfield%Dir, _
	_runSub( executor, executorDir, properties )    
  }
}

_runSub( executor, executorDir, properties ) {

	if ( executor != "_" ) {
		executor := bindValue( executor, properties )
		if ( executorDir == "_" ) {
			SplitPath, executor, , executorDir
		}
		executorDir := bindValue( executorDir, properties )
		RunWait, %executor%, %executorDir%
	}

}

runProgram( fileIni, properties ) {

	IniRead, executor,                 %fileIni%, init, executor,                  _
	IniRead, executorDir,              %fileIni%, init, executorDir,               _
	IniRead, resolution,               %fileIni%, init, resolution,                _
	IniRead, fullscreenWindow,         %fileIni%, init, fullscreenWindow,          _
	IniRead, fullscreenWindowDelay,    %fileIni%, init, fullscreenWindowDelay,     0
	IniRead, fullscreenWindowSize,     %fileIni%, init, fullscreenWindowSize,      _
	IniRead, isRunWait,                %fileIni%, init, runWait,                   false

	if ( resolution != "_" ) {
    	width  := Trim( RegExReplace( resolution, "i)^(.*?)x.*?$", "$1" ) )
    	height := Trim( RegExReplace( resolution, "i)^.*?x(.*?)$", "$1" ) )
		ResolutionChanger.change( width, height )
		isRunWait := true
		if ( fullscreenWindowSize == "_" ) {
		    fullscreenWindowSize := resolution
		}
	}

	if ( fullscreenWindowSize == "_" ) {
	    fullscreenWindowSize := A_ScreenWidth x A_ScreenHeight
	}

	;MsgBox fullscreenWindowSize : %fullscreenWindowSize%

	if ( executor != "_" ) {
		
		executor    := bindValue( executor,     properties )
		if ( executorDir == "_" ) {
			SplitPath, executor, , executorDir
		}
		executorDir := bindValue( executorDir,  properties )

		if ( fullscreenWindow != "_" ) {
			SetTimer, runMidThread, 500
			Run, %executor%, %executorDir%,,applicationPid
			Sleep, %fullscreenWindowDelay%
			WinWait, %fullscreenWindow%,, 10

			If ErrorLevel {
				MsgBox % "There is no window to wait.(" fullscreenWindow ")"
				Process, Close, %applicationPid%
			} else {
		    	width  := Trim( RegExReplace( fullscreenWindowSize, "i)^(.*?)x.*?$", "$1" ) )
		    	height := Trim( RegExReplace( fullscreenWindowSize, "i)^.*?x(.*?)$", "$1" ) )
				WinSet, Style, -0xC40000, %fullscreenWindow% ; remove the titlebar and border(s) 
				WinMove, %fullscreenWindow%,, 0, 0, %width%, %height%  ; move the window to 0,0 and reize to width x height 
				MouseMove, %width%, %height%
				WinWaitClose, %fullscreenWindow%
			}

			ResolutionChanger.restore()

		} else if ( isRunWait == true ) {
			SetTimer, runMidThread, 500
			RunWait, %executor%, %executorDir%
			ResolutionChanger.restore()
		} else {
			SetTimer, runMidThread, 500
			Run, %executor%, %executorDir%
		}

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
			regName := bindValue( regName, properties )
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

		if ( RegExMatch(A_LoopReadLine, "^.*\\$") ) {
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

    	; Run, % A_ScriptDir "\script\dc32.exe -width=" width " -height=" height

        VarSetCapacity( dM, 156, 0 )
        NumPut( 156, dM, 36 )
        NumPut( 0x5c0000, dM, 40 )
        NumPut( width, dM, 108 )
        NumPut( height, dM, 112 )
        DllCall( "ChangeDisplaySettingsA", UInt, &dM, UInt,0 )
    }
  
    restore() {
        if ( A_ScreenWidth != this.srcWidth || A_ScreenHeight != this.srcHeight ) {
            this.change( this.srcWidth, this.srcHeight )
        }
    }

}