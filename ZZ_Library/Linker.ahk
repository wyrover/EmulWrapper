#NoEnv

; TestCode
/*
file:="c:\Users\Administrator\Documents\ActiveGSLocalData"
if Linker.isSymlink( file, target, type )
	MsgBox % file " is a symlink.`nTarget: " target "`nType: " type
else
	MsgBox %file% is not a symlink

*/

;Linker.linkDir( "c:\Users\Administrator\Documents\ActiveGSLocalData", "z:\apple2gs\" )
;ExitApp

/**
* Sympolic Link Maker
*/
class Linker {

    __New() {
        throw Exception( "Linker is a static class, dont instante it!", -1 )
    }

    linkDir( source, target ) {

    	if Linker.isSymlink(source)
    		return

    	FileCreateDir, target

    	cmd := "/c mklink /d """ source """ """ target """"

		Linker._runCommand( cmd )

    }

    linkFile( source, target ) {

    	if Linker.isSymlink( source )
    		return

		cmd := "/c mklink /f """ source """ """ target """"

		Linker._runCommand( cmd )

    }

    /**
    * Get Symbolic Link Information
    *
    * @param  filePath   path to check if it is symbolic link
    * @param  targetPath path to linked by filePath
    * @param  linkType   link type ( file or directory )
    * @return true if filepath is symbolic link
    */
	isSymlink( filePath, ByRef targetPath="", ByRef linkType="" ) {

		if RegExMatch(filePath,"^\w:\\?$") ; false if it is a root directory
			return false

		SplitPath, filePath, fn, parentDir

		cmdResult := Linker._runCommand( "/c dir /al """ (InStr(FileExist(filePath),"D") ? parentDir "\" : filePath) """" )

		if RegExMatch(cmdResult,"<(.+?)>.*?\b" fn "\b.*?\[(.+?)\]",m) {
			linkType:= m1, targetPath:= m2
			if ( linkType == "SYMLINK" )
  				linkType := "file"
			else if ( linkType == "SYMLINKD" )
  				linkType := "directory"
			return true
		} else {
			return false
		}
	}

	_runCommand( command ) {

		dhw := A_DetectHiddenWindows

		DetectHiddenWindows On
		Run "%ComSpec%" /k,, Hide, pid
		while !( hConsole := WinExist("ahk_pid" pid) )
    		Sleep 10

		DllCall("AttachConsole", "UInt", pid)
		DetectHiddenWindows %dhw%

		objShell := ComObjCreate( "WScript.Shell" )
		objExec  := objShell.Exec( comspec " " command )
		While ! objExec.Status
			Sleep 100
		
		result :=  objExec.StdOut.ReadAll()

		DllCall("FreeConsole")
		Process Exist, %pid%
		if ( ErrorLevel == pid )
			Process Close, %pid%		

		return result
	}

}

