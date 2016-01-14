#NoEnv

;log( "Merong" )
;ExitApp

/*

; Not Used

SetTimerF( Function, Period=0, ParmObject=0, Priority=0 ) { 

 Static current,tmrs:=[] ;current will hold timer that is currently running

 If IsFunc( Function ) {
    if IsObject(tmr:=tmrs[Function]) ;destroy timer before creating a new one
       ret := DllCall( "KillTimer", UInt,0, PTR, tmr.tmr)
       , DllCall("GlobalFree", PTR, tmr.CBA)
       , tmrs.Remove(Function) 
    if (Period = 0 || Period = "off")
       return ret ;Return as we want to turn off timer
	 ; create object that will hold information for timer, it will be passed trough A_EventInfo when Timer is launched
    tmr:=tmrs[Function]:={func:Function,Period:Period="on" ? 250 : Period,Priority:Priority
								,OneTime:Period<0,params:IsObject(ParmObject)?ParmObject:Object()
								,Tick:A_TickCount}
    tmr.CBA := RegisterCallback(A_ThisFunc,"F",4,&tmr)
    return !!(tmr.tmr  := DllCall("SetTimer", PTR,0, PTR,0, UInt
								, (Period && Period!="On") ? Abs(Period) : (Period := 250)
								, PTR,tmr.CBA,"PTR")) ;Create Timer and return true if a timer was created
				, tmr.Tick:=A_TickCount
 }

 tmr := Object(A_EventInfo) ;A_Event holds object which contains timer information

 if IsObject(tmr) {
	 DllCall("KillTimer", PTR,0, PTR,tmr.tmr) ;deactivate timer so it does not run again while we are processing the function
	 If (current && tmr.Priority<current.priority) ;Timer with higher priority is already current so return
		 Return (tmr.tmr:=DllCall("SetTimer", PTR,0, PTR,0, UInt, 100, PTR,tmr.CBA,"PTR")) ;call timer again asap
	 current:=tmr
	 ,tmr.tick:=ErrorLevel :=Priority ;update tick to launch function on time
	 ,tmr.func(tmr.params*) ;call function
    if (tmr.OneTime) ;One time timer, deactivate and delete it
       return DllCall("GlobalFree", PTR,tmr.CBA)
				 ,tmrs.Remove(tmr.func)
	 tmr.tmr:= DllCall("SetTimer", PTR,0, PTR,0, UInt ;reset timer
				,((A_TickCount-tmr.Tick) > tmr.Period) ? 0 : (tmr.Period-(A_TickCount-tmr.Tick)), PTR,tmr.CBA,"PTR")
	 current= ;reset timer
 }

}
*/


log( message ) {

  if( A_IsCompiled == 1 )
    return
    
  ex         := Exception("", -1)
  lineNumber := ex.Line
  filePath   := ex.File

  SplitPath, filePath, , , , fileName

  OutputDebug % "(" fileName ":" lineNumber "] " message
  
}

/*
sortArray( Array, Order="A" ) {
    ;Order A: Ascending, D: Descending, R: Reverse
    MaxIndex := ObjMaxIndex(Array)
    If (Order = "R") {
        count := 0
        Loop, % MaxIndex 
            ObjInsert(Array, ObjRemove(Array, MaxIndex - count++))
        Return
    }
    Partitions := "|" ObjMinIndex(Array) "," MaxIndex
    Loop {
        comma := InStr(this_partition := SubStr(Partitions, InStr(Partitions, "|", False, 0)+1), ",")
        spos := pivot := SubStr(this_partition, 1, comma-1) , epos := SubStr(this_partition, comma+1)    
        if (Order = "A") {    
            Loop, % epos - spos {
                if (Array[pivot] > Array[A_Index+spos])
                    ObjInsert(Array, pivot++, ObjRemove(Array, A_Index+spos))    
            }
        } else {
            Loop, % epos - spos {
                if (Array[pivot] < Array[A_Index+spos])
                    ObjInsert(Array, pivot++, ObjRemove(Array, A_Index+spos))    
            }
        }
        Partitions := SubStr(Partitions, 1, InStr(Partitions, "|", False, 0)-1)
        if (pivot - spos) > 1    ;if more than one elements
            Partitions .= "|" spos "," pivot-1        ;the left partition
        if (epos - pivot) > 1    ;if more than one elements
            Partitions .= "|" pivot+1 "," epos        ;the right partition
    } Until !Partitions
}
*/

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
    Array[A_Index]:=v
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