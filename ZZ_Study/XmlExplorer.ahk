SetBatchLines, -1
#SingleInstance ignore
#NoTrayIcon
#NoEnv
#Include XMLWrite.ahk
#Include XMLRead.ahk
#Include XMLQuery.ahk
#Include Anchor.ahk
SetControlDelay, -1
SetWinDelay, -1

title = XML Explorer
EnvGet, settings, AppData
settings = %settings%\%title%.ini

Gui, +Resize
Gui, Font, , Tahoma
Gui, Add, Text, vFileT Section ym+10, XML Document:
Gui, Add, Edit, vFileP Section ys-1 w515 h18 ReadOnly 0x400
Gui, Add, Button, vFileO Section ys-2 w50 gFileOpen, &Open
Gui, Add, TreeView, vTree Section xm ys+40 w300 h355 AltSubmit gTreeUpdate
Gui, Font, s1
Gui, Add, Text, vSBMask h1
Gui, Font
Gui, Add, StatusBar
Gui, Add, Tab, vProp Section xs+315 ys h25 w350 +Theme, Properties||Loading

Gui, Tab, Properties
Gui, Add, Text, vPathT Section xs ys+37, Path:
Gui, Font, bold
Gui, Add, Edit, vPath ys-2 h18 w285
Gui, Font
Gui, Add, Button, vPathCh ys-2 w18 h18 gPathCh, ...
Gui, Add, Button, Section vTrAdd xs+215 w65 h20 gTrAdd, &Add +
Gui, Add, Button, vTrDel xs+70 ys w65 h20 gTrDel, &Delete -

Gui, Add, Text, vConT Section xs-215 ys+25, Contents:
Gui, Add, Edit, vCon Section xs w350 h90 gCon
Gui, Add, Button, vImport Section xs+215 w65 h20 gImport, I&mport...
Gui, Add, Button, vAutoTxt xp+70 yp w65 h20 gAutoText, Auto&Text

Gui, Add, Text, vAttT Section xs-215 ys+25, Attributes:
Gui, Add, ListView, vAtt Section xs w350 h80 -Multi NoSort AltSubmit gLV, Name|Value
Gui, Add, Button, vVal Section w65 h20 gValUD, &Change
Gui, Add, Button, vAttA xs+215 ys w65 h20 gValAdd, &Insert +
Gui, Add, Button, vAttD xp+70 ys w65 h20 gValDel, &Remove -

Gui, Tab, Loading
Gui, Add, Text, vHTrMsg Section y+50 w330 Center, Loading...
Gui, Add, Progress, vHTrPro w330 -Smooth

Gui, Tab

ctrlpos = FileP,FileO,HTrMsg,HTrPro,Tree,SBMask,TrAdd,TrDel,Prop
  ,Path,PathCh,Con,Import,PlainTxt,AutoTxt,AttT,Att,AttA,AttD,Val
Loop, Parse, ctrlpos, `,
  GuiControlGet, %A_LoopField%_, Pos, %A_LoopField%

GuiControl, , Prop, |Properties||
GuiControl, Disable, Val

file = %1%
If FileExist(file) and 0
  Goto, FileSet
FilePrompt:
msg("Open/Create document...", 25)
IniRead, x, %settings%, Window, X, Center
IniRead, y, %settings%, Window, Y, Center
IfLess, x, 0, SetEnv, x, Center
IfLess, y, 0, SetEnv, y, Center
Gui, Show, x%x% y%y%, %title%
msgt = XML Explorer - Start
SetTimer, _msgchange, 10
Gui, +OwnDialogs
MsgBox, 35, %msgt%, Do you wish to open an existing XML document or create one?
IfMsgBox, Yes
  Goto, FileOpen
IfMsgBox, No
  Goto, FileNew
IfMsgBox, Cancel
  ExitApp
_msgchange:
If WinExist(msgt)
  SetTimer, _msgchange, Off
Gui, +LastFound
ControlSetText, Button1, &Open..., %msgt%
ControlSetText, Button2, &New, %msgt%
Return

GuiSize:
If !GuiS {
  Gui, +LastFound
  WinGetPos, , , GuiSW, GuiSH
  OnMessage(0x24, "WM_GETMINMAXINFO")
  GuiS := true
}
Anchor("FileP", "", "", FileP_W)
Anchor("FileO", FileO_X, "", "", "", 1)
Anchor("HTrMsg", "", "", HTrMsg_W)
Anchor("HTrPro", "", "", HTrPro_W)
Anchor("Tree", "", "", "", Tree_H)
Anchor("SBMask", "", SBMask_Y)
Anchor("TrAdd", TrAdd_X, "", "", "", 1)
Anchor("TrDel", TrDel_X, "", "", "", 1)
Anchor("Prop", "", "", Prop_W)
Anchor("Path", "", "", Path_W)
Anchor("PathCh", PathCh_X)
Anchor("Con", "", "", Con_W, Con_H)
Anchor("Import", Import_X, Import_Y, "", "", 1)
Anchor("AutoTxt", AutoTxt_X, AutoTxt_Y, "", "", 1)
Anchor("AttT", "", AttT_Y, "", "", 1)
Anchor("Att", "", Att_Y, Att_W)
Anchor("AttA", AttA_X, AttA_Y, "", "", 1)
Anchor("AttD", AttD_X, AttD_Y, "", "", 1)
Anchor("Val", "", Val_Y, "", "", 1)
LV_ModifyCol(1, "AutoHdr")
LV_ModifyCol(2, "AutoHdr")
Return

PathCh:
If TreeGoto(Get("Path"))
  msg("Specified path selected", 177)
Else msg("Specified path not found", 110)
Return

TreeUpdate:
TreeList()
If (A_GuiEvent = "DoubleClick")
  GuiControl, Focus, Con
Return
Import:
IniRead, t, %settings%, Misc, Path, %A_MyDocuments%
Gui, +OwnDialogs
FileSelectFile, t, 3, %t%, Select file to import..., Text Documents (*txt)
IfEqual, ErrorLevel, 1, Return
FileRead, t, %t%
GuiControl, , Con, % Get("Con") . t
msg("Imported text", 39)
Return
AutoText:
If !AutoT {
  Menu, AutoT, Add, &RSS Date, AutoT_RSSDate
  Menu, AutoT, Add, &ISO Date, AutoT_ISODate
  Menu, AutoT, Add, &Webpage, AutoT_Webpage
  Menu, AutoT, Add, &File..., AutoT_File
  Menu, AutoT, Add, &Author, AutoT_Author
  AutoT := true
} Else Menu, AutoT, Show
Return
AutoT_RSSDate:
GuiControl, , Con, % Get("Con") . A_DDD . ", " . A_DD . " " . A_MMM . " " . A_YYYY
  . " " . A_Hour . ":" . A_Min . ":" . A_Sec . " GMT"
msg("Added AutoText: RSS Date", 75)
Goto, Con
AutoT_ISODate:
GuiControl, , Con, % Get("Con") . A_YYYY . "-" . A_MM . "-" . A_DD
msg("Added AutoText: ISO Date", 75)
Goto, Con
AutoT_Webpage:
InputBox, t, Webpage, Webpage URL:, , , 125, , , , , http://www.
GuiControl, , Con, % Get("Con") . t
msg("Added AutoText: Webpage URL", 75)
Goto, Con
AutoT_File:
IniRead, t, %settings%, Misc, Path, %A_MyDocuments%
IniRead, t1, %settings%, Misc, File, %A_Space%
Gui, +OwnDialogs
FileSelectFile, t, , %t%\%t1%, Select file...
GuiControl, , Con, % Get("Con") . t
msg("Added AutoText: File path", 75)
Goto, Con
AutoT_Author:
GuiControl, , Con, % Get("Con") . A_UserName
msg("Added AutoText: Author", 75)
Goto, Con
Return

ValUD:
LV_GetText(t1, LV_GetNext(), 2)
Gui, +OwnDialogs
InputBox, t, Change value, New value of attribute:, , , 125, , , , , %t1%
If ErrorLevel
  Return
Lock(0)
LV_GetText(t1, LV_GetNext())
XMLWrite(Get("FileP"), Get("Path"), t, "attribute('" . t1 . "')")
Lock()
LV_Modify(LV_GetNext(), "Col2", t)
msg("Changed attribute value", 22)
Return
ValAdd:
Gui, +OwnDialogs
InputBox, t, New attribute name, Enter the name of the new attribute:, , , 125
If ErrorLevel
  Return
Lock(0)
XMLWrite(Get("FileP"), Get("Path"), "value", "attribute('" . t . "')")
Lock()
LV_Add("Focus Select", t, "value")
msg("Added attribute", 177)
Goto, ValUD
Return
ValDel:
LV_GetText(t, LV_GetNext())
Lock(0)
XMLWrite(Get("FileP"), Get("Path"), "", "attribute('" . t . "')")
Lock()
LV_Delete(LV_GetNext())
msg("Deleted attribute", 132)
Return
LV:
If !LV_GetNext()
  GuiControl, Disable, Val
Else GuiControl, Enable, Val
If (A_GuiEvent = "DoubleClick")
  Goto, ValUD
Return

Con:
Lock(0)
If Get("Path")
  XMLWrite(Get("FileP"), Get("Path"), Get("Con"))
Lock()
msg("Updated contents", 148)
Return

TrAdd:
If TV_GetCount() {
  Gui, +OwnDialogs
  MsgBox, 35, New branch, Do you want to create a child node (select No for a sibling)?
  IfMsgBox, Cancel, Return
  IfMsgBox, Yes, SetEnv, t1, 1
  Else t1 = 0
} Else t1 = 0
Gui, +OwnDialogs
InputBox, t, New branch, Enter the name of the new node:, , , 125
If ErrorLevel
  Return
t2 := TV_GetSelection()
IfEqual, t1, 0, SetEnv, t2, % TV_GetParent(t2)
t1 := TV_Add(t, t2, "Focus Select")
Lock(0)
If Get("Path")
  XMLWrite(Get("FileP"), Get("Path") . "." . t, " ")
Lock()
msg("Added item", 177)
Return
TrDel:
Gui, +OwnDialogs
MsgBox, 276, Delete branch, Do you want to delete the selected branch including all of its child nodes?
IfMsgBox, No, Return
TV_Delete(TV_GetSelection())
Lock(0)
If Get("Path")
  XMLWrite(Get("FileP"), Get("Path"), "")
Lock()
msg("Deleted item", 132)
Return

FileNew:
IniRead, t, %settings%, Misc, Path, %A_MyDocuments%
Gui, +OwnDialogs
FileSelectFile, file, S18, %t%, Create XML Document..., XML Documents (*.xml; *.html)
If !file
  Goto, FilePrompt
FileDelete, %file%
SplitPath, file, , , t
If !t
  file = %file%.xml
FileDelete, %file%
Goto, FileSet
Return

FileOpen:
GuiControlGet, v, , FileO
If v = Cl&ose
  Goto, FileClose
IniRead, t, %settings%, Misc, Path, %A_MyDocuments%
IniRead, t1, %settings%, Misc, File, %A_Space%
Gui, +OwnDialogs
FileSelectFile, file, 3, %t%\%t1%, Open XML Document..., XML Documents (*.xml; *.html)
If !file
  Goto, FilePrompt

FileSet:
StringRight, filename, file, StrLen(file) - InStr(file, "\", 0, 0)
OnExit, Unlock
GuiControl, , FileP, %file%
Lock()
GuiControl, , FileO, Cl&ose
If !TreeUpdate() {
  Reload
  Sleep, 500 ; reload bug hack
}
Gui, Show, , %filename% - %title%
Return

FileClose:
Gosub, Close
Reload
GuiClose:
Unlock:
Gosub, Close
ExitApp
Return

Close:
msg("Closing...", 28)
Lock(0)
Gui, +LastFound
WinGetPos, t, t1
IniWrite, %t%, %settings%, Window, X
IniWrite, %t1%, %settings%, Window, Y
t := Get("FileP")
SplitPath, t, t, t1, t2
StringReplace, t, t, .%t2%, , 1
If t {
  IniWrite, %t1%, %settings%, Misc, Path
  IniWrite, %t%.%t2%, %settings%, Misc, File
}
Return

TreeGoto(path) {
  StringReplace, path, path, (, [, 1
  StringReplace, path, path, ), ], 1
  StringReplace, path, path, ., ., 1
  o := ErrorLevel + 1
  t := TV_GetNext()
  Loop, Parse, path, .
  {
    f = 0
    e = %A_LoopField%
    If InStr(e, "[") and InStr(e, "]")
      StringMid, i, e, InStr(e, "[") + 1, InStr(e, "]") - InStr(e, "[") - 1
    Else i = 0
    StringReplace, e, e, [%i%]
    Loop {
      TV_GetText(tx, t)
      If (tx == e) {
        f++
        If (f - 1 = i) {
          If TV_GetChild(t) {
            t := TV_GetChild(t)
            ch = 1
          } Else ch = 0
          Break
        } Else t := TV_GetNext(t)
      } Else {
        t := TV_GetNext(t)
        IfEqual, t, 0, Return, false
      }
    }
  }
  If ch
    t := TV_GetParent(t)
  TV_Modify(t, "Vis Select Expand")
  Return, true
}

TreeList() {
  global TreeUpdate
  SB_SetText("Parsing data...")
  SB_SetIcon("Shell32.dll", 134)
  s := TV_GetSelection()
  TV_GetText(t, s)
  ; ok this is not the most efficient coding but I cba to do anything better
  p = %s%
  i = 0
  Loop {
    p := TV_GetPrev(p)
    IfEqual, p, 0, Break
    TV_GetText(pn, p)
    If (t == pn)
      i++
  }
  If i
    t = %t%(%i%)
  Loop {
    s := TV_GetParent(s)
    If !s
      Break
    TV_GetText(tn, s)
    p = %s%
    i = 0
    Loop {
      p := TV_GetPrev(p)
      IfEqual, p, 0, Break
      TV_GetText(pn, p)
      If (tn == pn)
        i++
    }
    IfEqual, i, 0, SetEnv, t, %tn%.%t%
    Else t = %tn%(%i%).%t%
  }
  ctrls = Con,Import,AutoTxt
  GuiControl, , Path, %t%
  typehtml := XMLRead(Get("FileP"), Get("Path"), "attribute('type')") = "application/xhtml+xml"
    or XMLRead(Get("FileP"), Get("Path"), "attribute('type')") = "text/html"
  If !TV_GetChild(TV_GetSelection()) or typehtml {
    Loop, Parse, ctrls, `,
      GuiControl, Enable, %A_LoopField%
    GuiControl, , Con, % XMlRead(Get("FileP"), t)
  } Else {
    GuiControl, , Path, % Get("Path")
    Loop, Parse, ctrls, `,
      GuiControl, Disable, %A_LoopField%
    GuiControl, , Con
  }
  Lock(0)
  LV_Delete()
  a := XMLQuery(Get("FileP"), "Attributes", Get("Path"))
  If InStr(a, "='")
    StringReplace, a, a, ', ", 1
  ; use '? as delimiter because that should not exist in XML 1.0 files (should be '￠') -- from manual
  StringReplace, a, a, "%A_Space%, ? 1
  Loop, Parse, a, ?
    If A_LoopField {
      Loop, Parse, A_LoopField, =
        IfEqual, A_Index, 1, StringReplace, f1, A_LoopField, ", , 1
        Else StringReplace, f2, A_LoopField, ", , 1
      If f1 is space
        Continue
      Loop {
        StringLeft, t, f1, 1
        If t is space
          StringTrimLeft, f1, f1, 1
        Else Break
      }
      f1 = %f1%
      LV_Add("", f1, f2)
      LV_ModifyCol(1, "AutoHdr")
      LV_ModifyCol(2, "AutoHdr")
      x = 0
    }
  Lock()
  If !TreeUpdate
    msg("Data parsed", 29)
  Else TreeUpdate = 0
}

TreeUpdate() {
  global title
  time = %A_TickCount%
  TV_Delete()
  msg("Parsing document...", 23)
  Lock(0)
  v := XMLQuery(Get("FileP"), "List")
  FileRead, t, % Get("FileP")
  Lock()
  StringLeft, t, t, InStr(t, ">")
  If InStr(t, "HTML") and !InStr(t, "XHTML") or !InStr(t, "<?xml") {
    Gui, +OwnDialogs
    If InStr(t, "HTML")
      MsgBox, 52, HTML Document, % "The current file is an HTML document which can not be presented in an XML type structure."
        . "`nWould you like to open it anyway?"
    Else If !InStr(t, "<?xml")
      MsgBox, 16, Invalid XML Document, The current file is not a valid XML document. Would you like to open it anyway?
    IfMsgbox, No
    {
      Reload
      Sleep, 500 ; reload bug hack
    }
  }
  GuiControl, -Redraw, Tree
  GuiControl, , Prop, |Properties|Loading||
  GuiControl, Show, HTrMsg
  GuiControl, Show, HTrPro
  ; warning: very bad coding ahead...
  StringReplace, v, v, `n, `n, All UseErrorlevel
  t = %ErrorLevel%
  Loop, Parse, v, `n
  {
    StringReplace, n, A_LoopField, ., ., All UseErrorlevel
    n = %ErrorLevel%
    If (n = nx)
      tp = %A_Index%
    Else {
      If !tp
        tp = #1
      Else If (n + 1 = nx)
        tpa := lvl%n%
      Else If (n < nx)
        tpa := lvl%n%
      Else tpa := %tp%
      lvl%n% := tpa
    }
    IfInString, A_LoopField, ., StringRight, name, A_LoopField, StrLen(A_LoopField) - InStr(A_LoopField, ".", 1, 0)
    Else name = %A_LoopField%
    IfLess, A_Index, 3, SetEnv, opt, Expand
    Else SetEnv, opt
    %tp% := TV_Add(name, tpa, opt)
    nx = %n%
    TreeProgress(A_Index/t*100)
    IfEqual, A_Index, %t%, Break
  }
  TreeUpdate = 1
  GuiControl, , Prop, |Properties||
  GuiControl, Hide, HTrMsg
  GuiControl, Hide, HTrPro
  GuiControl, Focus, Tree
  GuiControl, +Redraw, Tree
  time := Round((A_TickCount - time) / 1000, 2)
  IfGreater, time, 0.25, SetEnv, time, - loaded in %time% seconds
  Else time := ""
  msg("Document parsing complete " . time, 159)
  Return, true
}

TreeProgress(i = 0) {
  i := Round(i)
  GuiControl, , HTrMsg, Loading... %i%`%
  GuiControl, , HTrPro, %i%
}

Lock(l = true) {
  static hfile
  If l
    hfile := DllCall("CreateFile", Str, file, UInt, 0x80000000, UInt, 0, UInt, 0, UInt, 3, UInt, 0, UInt, 0)
  Else DllCall("CloseHandle", UInt, hfile)
  Return, hfile
}

Get(ctrl) {
  GuiControlGet, e, , %ctrl%
  Return, e
}

key() {
  Gui, +LastFound
  Return, !WinActive()
}

msg(text, icon) {
  SB_SetText(text)
  FileGetVersion, v, Shell32.dll
  StringLeft, v, v, 1
  If v = 6
    SB_SetIcon("Shell32.dll", icon)
}

WM_GETMINMAXINFO(wParam, lParam) {
  global GuiSW, GuiSH, GuiS
  If !A_Gui or !GuiS
    Return
  InsertIntegerAtAddress(GuiSW, lParam, 24, 4)
  InsertIntegerAtAddress(GuiSH, lParam, 28, 4)
  Return, 0
}

InsertIntegerAtAddress(pInteger, pAddress, pOffset = 0, pSize = 4) {
  mask := 0xFF
  Loop %pSize% {
    DllCall("RtlFillMemory", UInt, pAddress + pOffset + A_Index - 1, UInt, 1, UChar, (pInteger & mask) >> 8 * (A_Index - 1))
    mask := mask << 8
  }
}

~!NumpadAdd::
~!+=::
If key()
  Return
GuiControlGet, t, FocusV
If (t = "Tree") {
  id = 0
  GuiControl, -Redraw, Tree
  Loop {
    id := TV_GetNext(id, "Full")
    If !id
      Break
    TV_Modify(id, "Expand")
  }
  GuiControl, +Redraw, Tree
  msg("All items collapsed", 138)
}
Return

~!NumpadSub::
~!-::
If key()
  Return
GuiControlGet, t, FocusV
If (t = "Tree") {
  id = 0
  GuiControl, -Redraw, Tree
    Loop {
      id := TV_GetNext(id, "Full")
      If !id
        Break
      TV_Modify(id, "-Expand")
    }
  GuiControl, +Redraw, Tree
  msg("All items uncollapsed", 147)
}
Return

~NumpadAdd::
~+=::
~Insert::
If key()
  Return
GuiControlGet, t, FocusV
If t = Tree
  Goto, TrAdd
Else If t = Att
  Goto, ValAdd
Return

~NumpadSub::
~-::
~Delete::
If key()
  Return
GuiControlGet, t, FocusV
If t = Tree
  Goto, TrDel
Else If t = Att
  Goto, ValDel
Return