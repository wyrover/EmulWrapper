; alternative method via registry:

RegRead, ProductName, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows NT\CurrentVersion, ProductName
RegRead, CSDVersion, HKLM, SOFTWARE\Microsoft\Windows NT\CurrentVersion, CSDVersion
RegRead, CurrentVersion, HKLM, SOFTWARE\Microsoft\Windows NT\CurrentVersion, CurrentVersion
RegRead, BuildLab, HKLM, SOFTWARE\Microsoft\Windows NT\CurrentVersion, BuildLab

; the below 2 aren't in my WinXP but are in my Win Server 2008 Enterprise
RegRead, BuildLabEx, HKLM, SOFTWARE\Microsoft\Windows NT\CurrentVersion, BuildLabEx
RegRead, EditionID, HKLM, SOFTWARE\Microsoft\Windows NT\CurrentVersion, EditionID

MsgBox, ProductName: "%ProductName%"`n
and CSDVersion: "%CSDVersion%"`n
and CurrentVersion: "%CurrentVersion%"`n
and BuildLab: "%BuildLab%"`n
and BuildLabEx: "%BuildLabEx%"`n
and EditionID: "%EditionID%"


ThisProcess := DllCall("GetCurrentProcess") 
; If IsWow64Process() fails or can not be found, 
; assume this process is not running under wow64. 
; Otherwise, use the value returned in IsWow64Process. 
if ! DllCall("IsWow64Process", "uint", ThisProcess, "int*", IsWow64Process) 
    IsWow64Process := false 
MsgBox % IsWow64Process ? "win64" : "win32"