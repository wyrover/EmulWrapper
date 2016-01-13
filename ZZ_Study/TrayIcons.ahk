; Copy of http://www.autohotkey.com/board/topic/97474-get-song-info-from-pandora/?p=616530

; Make the script work even if the window is hidden
DetectHiddenWindows, on

; Only allow a single instance of the script
#SingleInstance

Tray_Icons := TrayIconsSearch()

for index, element in Tray_Icons {

	element.Tooltip := RegExReplace( element.Tooltip, "\n", "`n`t" )

	infoText .=    "idx: "       . element.idx
	infoText .= " | idn: "       . element.idn
	infoText .= " | Pid: "       . element.pid
	infoText .= " | uID: "       . element.uID
	infoText .= " | MessageID: " . element.MessageID
	infoText .= " | hWnd: "      . element.hWnd
	infoText .= " | Class: "     . element.Class
	infoText .= " | Process: "   . element.Process . "`n"
	infoText .= "Tooltip: `t"    . element.Tooltip . "`n`n"
}

MsgBox, %infoText%

ExitApp
	
TrayIconsSearch(sTerm="")
{
	Tray_Icons := {}
	Tray_Icons := TrayIcons(sTerm)

	if A_OSVersion in WIN_VISTA,WIN_7,WIN_8
	{
		arr := {}
		arr := TrayIconsOverflow(sTerm)
		for index, element in arr
			Tray_Icons.Insert(element)
		arr := ""
	}
return Tray_Icons
}


TrayIcons(sExeName = "") {
	arr := {}
	Setting_A_DetectHiddenWindows := A_DetectHiddenWindows
	DetectHiddenWindows, On
	WinGet,	pidTaskbar, PID, ahk_class Shell_TrayWnd
	hProc:=	DllCall("OpenProcess", "Uint", 0x38, "int", 0, "Uint", pidTaskbar)
	pProc:=	DllCall("VirtualAllocEx", "Uint", hProc, "Uint", 0, "Uint", 32, "Uint", 0x1000, "Uint", 0x4)
	idxTB:=	GetTrayBar()
	
	SendMessage, 0x418, 0, 0, ToolbarWindow32%idxTB%, ahk_class Shell_TrayWnd   ; TB_BUTTONCOUNT
	Loop,	%ErrorLevel%
	{
		SendMessage, 0x417, A_Index-1, pProc, ToolbarWindow32%idxTB%, ahk_class Shell_TrayWnd   ; TB_GETBUTTON
		VarSetCapacity(btn,32,0), VarSetCapacity(nfo,32,0)
		DllCall("ReadProcessMemory", "Uint", hProc, "Uint", pProc, "Uint", &btn, "Uint", 32, "Uint", 0)
			iBitmap	:= NumGet(btn, 0)
			idn	:= NumGet(btn, 4)
			Statyle := NumGet(btn, 8)
			If	dwData	:= NumGet(btn,12,"Uint")
				iString	:= NumGet(btn,16)
			Else	dwData	:= NumGet(btn,16,"int64"), iString:=NumGet(btn,24,"int64")
		DllCall("ReadProcessMemory", "Uint", hProc, "Uint", dwData, "Uint", &nfo, "Uint", 32, "Uint", 0)
		If	NumGet(btn,12,"Uint")
			hWnd	:= NumGet(nfo, 0)
		,	uID	:= NumGet(nfo, 4)
		,	nMsg	:= NumGet(nfo, 8)
		,	hIcon	:= NumGet(nfo,20)
		Else	hWnd	:= NumGet(nfo, 0,"int64"), uID:=NumGet(nfo, 8,"Uint"), nMsg:=NumGet(nfo,12,"Uint")
		WinGet, pid, PID,              ahk_id %hWnd%
		WinGet, sProcess, ProcessName, ahk_id %hWnd%
		WinGetClass, sClass,           ahk_id %hWnd%
		If !sExeName || (sExeName = sProcess) || (sExeName = pid)
			VarSetCapacity(sTooltip,128), VarSetCapacity(wTooltip,128*2)
		,	DllCall("ReadProcessMemory", "Uint", hProc, "Uint", iString, "Uint", &wTooltip, "Uint", 128*2, "Uint", 0)
		,	DllCall("WideCharToMultiByte", "Uint", 0, "Uint", 0, "str", wTooltip, "int", -1, "str", sTooltip, "int", 128, "Uint", 0, "Uint", 0)
		,	Index = arr.MaxIndex()>0 ? arr.MaxIndex()+1 : 1
		,	arr[Index,"idx"]       := A_Index-1
		,	arr[Index,"idn"]       := idn
		,	arr[Index,"Pid"]       := Pid
		,	arr[Index,"uID"]       := uID
		,	arr[Index,"MessageID"] := nMsg
		,	arr[Index,"hWnd"]      := hWnd
		,	arr[Index,"Class"]     := sClass
		,	arr[Index,"Process"]   := sProcess
		,	arr[Index,"Tooltip"]   := (A_IsUnicode ? wTooltip : sTooltip)
	}
	DllCall("VirtualFreeEx", "Uint", hProc, "Uint", pProc, "Uint", 0, "Uint", 0x8000)
	DllCall("CloseHandle", "Uint", hProc)
	DetectHiddenWindows, %Setting_A_DetectHiddenWindows%
	Return	arr
}

TrayIconsOverflow(sExeName = "") {
	arr := {}
	Setting_A_DetectHiddenWindows := A_DetectHiddenWindows
	DetectHiddenWindows, On
	WinGet,	pidTaskbar, PID, ahk_class NotifyIconOverflowWindow
	hProc:=	DllCall("OpenProcess", "Uint", 0x38, "int", 0, "Uint", pidTaskbar)
	pProc:=	DllCall("VirtualAllocEx", "Uint", hProc, "Uint", 0, "Uint", 32, "Uint", 0x1000, "Uint", 0x4)
	idxTB:=	1
		SendMessage, 0x418, 0, 0, ToolbarWindow32%idxTB%, ahk_class NotifyIconOverflowWindow   ; TB_BUTTONCOUNT
	Loop,	%ErrorLevel%
	{
		SendMessage, 0x417, A_Index-1, pProc, ToolbarWindow32%idxTB%, ahk_class NotifyIconOverflowWindow   ; TB_GETBUTTON
		VarSetCapacity(btn,32,0), VarSetCapacity(nfo,32,0)
		DllCall("ReadProcessMemory", "Uint", hProc, "Uint", pProc, "Uint", &btn, "Uint", 32, "Uint", 0)
			iBitmap	:= NumGet(btn, 0)
			idn	:= NumGet(btn, 4)
			Statyle := NumGet(btn, 8)
		If	dwData	:= NumGet(btn,12,"Uint")
			iString	:= NumGet(btn,16)
		Else	dwData	:= NumGet(btn,16,"int64"), iString:=NumGet(btn,24,"int64")
		DllCall("ReadProcessMemory", "Uint", hProc, "Uint", dwData, "Uint", &nfo, "Uint", 32, "Uint", 0)
		If	NumGet(btn,12,"Uint")
			hWnd	:= NumGet(nfo, 0)
		,	uID	  := NumGet(nfo, 4)
		,	nMsg	:= NumGet(nfo, 8)
		,	hIcon	:= NumGet(nfo,20)
		Else	hWnd	:= NumGet(nfo, 0,"int64"), uID:=NumGet(nfo, 8,"Uint"), nMsg:=NumGet(nfo,12,"Uint")
		WinGet, pid, PID,              ahk_id %hWnd%
		WinGet, sProcess, ProcessName, ahk_id %hWnd%
		WinGetClass, sClass,           ahk_id %hWnd%
		If !sExeName || (sExeName = sProcess) || (sExeName = pid)
			VarSetCapacity(sTooltip,128), VarSetCapacity(wTooltip,128*2)
		,	DllCall("ReadProcessMemory",   "Uint", hProc, "Uint", iString, "Uint", &wTooltip, "Uint", 128*2, "Uint", 0)
		,	DllCall("WideCharToMultiByte", "Uint", 0,     "Uint", 0,       "str",  wTooltip,  "int", -1,     "str", sTooltip, "int", 128, "Uint", 0, "Uint", 0)
		,	Index = arr.MaxIndex()>0 ? arr.MaxIndex()+1 : 1
		,	arr[Index,"idx"]       := A_Index-1
		,	arr[Index,"idn"]       := idn
		,	arr[Index,"Pid"]       := Pid
		,	arr[Index,"uID"]       := uID
		,	arr[Index,"MessageID"] := nMsg
		,	arr[Index,"hWnd"]      := hWnd
		,	arr[Index,"Class"]     := sClass
		,	arr[Index,"Process"]   := sProcess
		,	arr[Index,"Tooltip"]   := (A_IsUnicode ? wTooltip : sTooltip)
	}
	DllCall("VirtualFreeEx", "Uint", hProc, "Uint", pProc, "Uint", 0, "Uint", 0x8000)
	DllCall("CloseHandle", "Uint", hProc)
	DetectHiddenWindows, %Setting_A_DetectHiddenWindows%
	Return	arr
}

GetTrayBar() {
	ControlGet, hParent, hWnd,, TrayNotifyWnd1  , ahk_class Shell_TrayWnd
	ControlGet, hChild , hWnd,, ToolbarWindow321, ahk_id %hParent%
	Loop
	{
		ControlGet, hWnd, hWnd,, ToolbarWindow32%A_Index%, ahk_class Shell_TrayWnd
		If Not hWnd
			Break
		Else If	hWnd = %hChild%
		{
			idxTB := A_Index
			Break
		}
	}
	Return	idxTB
}