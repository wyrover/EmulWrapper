#NoEnv

; debug( "merong" )
; debug( "Hwasu" )
; ExitApp


debug( message ) {

 if( A_IsCompiled == 1 )
   return

  message .= "`n" 
  FileAppend %message%, * ; send message to stdout
    
}

sendKey( key ) {
  SendInput {%key% down}
  Sleep, 50
  SendInput {%key% up}
  Sleep, 100
}

sortArray( Array ) {
  t := Object()
  for k, v in Array
    t[RegExReplace(v,"\s")]:=v
  for k, v in t
    Array[A_Index] := v
  return Array
}

/**
* Os Detector
*
* Detector.64 : true / false
*/
class Detector {

    static 64 := true
    static _void := Detector._init()

    _init() {
        ThisProcess := DllCall("GetCurrentProcess") 
        if ! DllCall("IsWow64Process", "uint", ThisProcess, "int*", IsWow64Process) 
            Detector.64 := false 
    }
    
    __New() {
		throw Exception( "Detector is static class, dont instante it!", -1 )
    }

}

/**
* MouseCursor Controller
*/
class MouseCursor {

    static void := FileUtil._init()

    _init() {
        this._setSystemCursor( "Init" )
    }

    _setSystemCursor( OnOff=1 ) {  ; INIT = "I","Init"; OFF = 0,"Off"; TOGGLE = -1,"T","Toggle"; ON = others

        static AndMask, XorMask, $, h_cursor
            ,c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13 ; system cursors
            ,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13    ; blank cursors
            ,h1,h2,h3,h4,h5,h6,h7,h8,h9,h10,h11,h12,h13    ; handles of default cursors
        if (OnOff = "Init" or OnOff = "I" or $ = "")       ; init when requested or at first call
        {
            $ = h                                          ; active default cursors
            VarSetCapacity( h_cursor,4444, 1 )
            VarSetCapacity( AndMask, 32*4, 0xFF )
            VarSetCapacity( XorMask, 32*4, 0 )
            system_cursors = 32512,32513,32514,32515,32516,32642,32643,32644,32645,32646,32648,32649,32650
            StringSplit c, system_cursors, `,
            Loop %c0%
            {
                h_cursor   := DllCall( "LoadCursor", "Ptr",0, "Ptr",c%A_Index% )
                h%A_Index% := DllCall( "CopyImage", "Ptr",h_cursor, "UInt",2, "Int",0, "Int",0, "UInt",0 )
                b%A_Index% := DllCall( "CreateCursor", "Ptr",0, "Int",0, "Int",0
                    , "Int",32, "Int",32, "Ptr",&AndMask, "Ptr",&XorMask )
            }
        }
        if (OnOff = 0 or OnOff = "Off" or $ = "h" and (OnOff < 0 or OnOff = "Toggle" or OnOff = "T"))
            $ = b  ; use blank cursors
        else
            $ = h  ; use the saved cursors

        Loop %c0%
        {
            h_cursor := DllCall( "CopyImage", "Ptr",%$%%A_Index%, "UInt",2, "Int",0, "Int",0, "UInt",0 )
            DllCall( "SetSystemCursor", "Ptr",h_cursor, "UInt",c%A_Index% )
        }
    }

    show() {
        SetTimer, MouseCursor.no_move_check, off
        MouseCursor._setSystemCursor( "On" )
    }

    hide( duration=500 ) {

        SetTimer, MouseCursor.no_move_check, %duration%
        MouseCursor._setSystemCursor( "Off" )
        return

        MouseCursor.no_move_check:

            MouseGetPos, prevX, prevY
            
            Sleep 100

            MouseGetPos, x, y

            if ( prevX != x or prevY != y ) {
                MouseCursor._setSystemCursor( "On" )
            } else {
                MouseCursor._setSystemCursor( "Off" )
            }

            return

    }

}