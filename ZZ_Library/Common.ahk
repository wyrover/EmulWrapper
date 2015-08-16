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

sortArray( Array ) {
    t:=Object()
    for k, v in Array
        t[RegExReplace(v,"\s")]:=v
    for k, v in t
        Array[A_Index]:=v
    return Array
}

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
