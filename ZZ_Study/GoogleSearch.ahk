; Google Search
; Fanatic Guru
; 2014 05 01
; Version: 1.0
;
; Google Search of Highlighted Text
;
;{-----------------------------------------------
; If Internet Explorer is already running it will add search as new tab
;}

; INITIALIZATION - ENVIROMENT
;{-----------------------------------------------
;
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force  ; Ensures that only the last executed instance of script is running
;}

; AUTO-EXECUTE
;{-----------------------------------------------
;
RegRead, ProgID, HKEY_CURRENT_USER, Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice, Progid
Browser := "iexplore.exe"
if (ProgID = "ChromeHTML")
   Browser := "chrome.exe"
if (ProgID = "FirefoxURL")
   Browser := "firefox.exe"
;
;}-----------------------------------------------
; END OF AUTO-EXECUTE

; HOTKEYS
;{-----------------------------------------------
;

#g::    ; <-- Google Search Using Highlighted Text (window + g)
    Save_Clipboard := ClipboardAll
    Clipboard := ""
    Send ^c
    ClipWait, 1
    if !ErrorLevel
   {
      Query := Clipboard
   }
   else { ; no text selected - bring up popup
      InputBox, Query, Google Search, , , 200, 100
   }
   Gosub Search
   Clipboard := Save_Clipboard
   Save_Clipboard := ""
return
;}

; SUBROUTINES
;{-----------------------------------------------
;
Search:
   StringReplace, Query, Query, `r`n, %A_Space%, All 
   StringReplace, Query, Query, %A_Space%, `%20, All
   StringReplace, Query, Query, #, `%23, All
   Query := Trim(Query)
   if (Browser = "iexplore.exe")
   {
      Found_IE := false
      For wb in ComObjCreate("Shell.Application").Windows 
         If InStr(wb.FullName, "iexplore.exe")
         {
            Found_IE := true
          break
         }
      if Found_IE
         wb.Navigate("http://google.com/search?hl=en&q=" Query, 2048) 
      else
      {
         wb := ComObjCreate("InternetExplorer.Application")
         wb.Visible := true
         wb.Navigate("http://google.com/search?hl=en&q=" Query) 
      }
   }
   else
      Run, %browser% http://www.google.com/search?hl=en&q=%Query% 
return
;}


debug( message ) {

 if( A_IsCompiled == 1 )
   return

  message .= "`n" 
  FileAppend %message%, * ; send message to stdout
    
}