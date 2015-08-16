#NoEnv

OutputDebug, %A_Now%: Because the window "%TargetWindowTitle%" did not exist, the process was aborted

;dllPath := % A_ScriptDir "\minizip_x64.dll"

;msgbox % "dllPath : " dllPath

;TestCode

;WhichButton := DllCall("MessageBox", "int", "0", "str", "Press Yes or No", "str", "Title of box", "int", 4)
;MsgBox You pressed button #%WhichButton%.

zipFile := new Zip()

rtn := zipFile.open( "\\NAS\emul\emulator\ZZ_Library\zipTest.zip" )
MsgBox % "rtn : " rtn ", fileCount : " zipFile.getFileCount()

;zip.create( "ahk.zip" )
;zip.addFolder( A_AhkDir )

zipFile.close()

ExitApp


class Zip {

	static loaded := false

	zipHandle     := null

    __New() {
		
		if( Zip.loaded == true )
			return
		
		
		
		rtn := DllCall( "LoadLibrary", "Str", "\\NAS\emul\emulator\ZZ_Library\minizip.dll", "Int64" )
		
		msgbox % rtn
		
		Zip.loaded := true
    }

	setPassword( Password="" ) {
	  Return DllCall( "MiniZIP\ZIP_SetPassword"
	      , ( A_IsUnicode ? "AStr" : "Str" ), Password
	      , "UInt" )
	}


	create( zipFilename ) {
	  Return DllCall( "MiniZIP\ZIP_FileCreate"
	      , ( A_IsUnicode ? "AStr" : "Str" ), zipFileName, "UInt" )
	}


	open( zipFilename ) {
	  IfNotExist, %zipfileName%, Return
	  Return DllCall( "MiniZIP\ZIP_FileOpen"
	      , ( A_IsUnicode ? "AStr" : "Str" ), zipFilename
	      , "UInt" )
	}


	addFolder( SourceDir, Compression=-1, Callback=0 ) {
	  Return DllCall( "MiniZIP\ZIP_DirAdd"
	      , "UInt", this.zipHandle
	      , ( A_IsUnicode ? "AStr" : "Str" ), SourceDir
	      , "Int" , Compression
	      , "UInt", Callback
	      , "UInt" )
	}


	addFile( SourceFilename, ArchiveFilename, Compression=-1, Callback=0 ) {
	 Return DllCall( "MiniZIP\ZIP_FileAdd"
	      , "UInt", this.zipHandle
	      , ( A_IsUnicode ? "AStr" : "Str" ), SourceFilename
	      , ( A_IsUnicode ? "AStr" : "Str" ), ArchiveFilename
	      , "Int" , Compression
	      , "UInt", Callback
	      , "UInt" )
	}


	addMemory( memPointer, memSize, ArchiveFilename, Compression=-1, Callback=0 ) {
	  Return DllCall( "MiniZIP\ZIP_MemAdd"
	      , "UInt", this.zipHandle
	      , "UInt", memPointer
	      , "UInt", memSize
	      , ( A_IsUnicode ? "AStr" : "Str" ), ArchiveFilename
	      , "Int" , Compression
	      , "UInt", Callback
	      , "UInt"  )
	}


	close( Comment="Created with MiniZIP.dll" ) {
	  DllCall( "MiniZIP\ZIP_FileClose"
	      , "UInt", this.zipHandle
	      , ( A_IsUnicode ? "AStr" : "Str" ), Comment
	      , "UInt" )
		  
	    DllCall( "FreeLibrary", "UInt", this.zipHandle ) 
		  
	}


	isValid( zipFilename ) {
	  IfNotExist, %zipfileName%, Return 3
	  Return DllCall( "MiniZIP\ZIP_IsZipArchive"
	      , ( A_IsUnicode ? "AStr" : "Str" ), ZipFilename, "UInt" )
	} ;  Return Values:   0 = OK,  1 = NOT_ARCHIVE,  2 = ERROR_IN_ARCHIVE,  3 = FILE_NOT_FOUND


	getFileCount( zipFilename ) {
	  IfNotExist, %zipfileName%, Return
	  Return DllCall( "MiniZIP\ZIP_GetFilesCount"
	      , ( A_IsUnicode ? "AStr" : "Str" ), zipFilename
	                                               , "UInt" )
	}


	getFileNumber( zipFileName, ArchiveFilename ) {
	    IfNotExist, %zipfileName%, Return
	    Return DllCall( "MiniZIP\ZIP_GetFileNumber"
	        , ( A_IsUnicode ? "AStr" : "Str" ), zipFilename
	        , ( A_IsUnicode ? "AStr" : "Str" ), ArchiveFilename
	        , "UInt" )
	}


	isPasswordRequired( zipFilename, zipFileNumber ) {
	    IfNotExist, %zipfileName%, Return
	    Return DllCall( "MiniZIP\ZIP_IsPasswordRequired"
	        , ( A_IsUnicode ? "AStr" : "Str" ), zipFilename
	        , "UInt", zipFileNumber
			, "UInt" )
	}


	getFilename( zipFilename, zipFileNumber=1, ByRef FILEINFO="" ) {
	    IfNotExist, %zipfileName%, Return
	    VarSetCapacity( FILEINFO, 310, 0 )
	    Return DllCall( "MiniZIP\ZIP_GetFileInfo"
	        , ( A_IsUnicode ? "AStr" : "Str" ), zipFilename
	        , "UInt", zipFileNumber
	        , "UInt", &FILEINFO
	        , ( A_IsUnicode ? "AStr" : "Str" ) )
	}


	getComment( zipFilename ) {
	  IfNotExist, %zipfileName%, Return
	  Return DllCall( "MiniZIP\ZIP_GetFileComment"
	        , ( A_IsUnicode ? "AStr" : "Str" ), zipFilename
	        , ( A_IsUnicode ? "AStr" : "Str" ) )
	}


	unzip( zipFilename, TargetPath, CreateTargetPath=1, Callback=0 ) {
	  IfNotExist, %zipfileName%, Return
	  Return DllCall("MiniZIP\ZIP_ExtractArchiv"
	        , ( A_IsUnicode ? "AStr" : "Str" ), zipFilename
	        , ( A_IsUnicode ? "AStr" : "Str" ), TargetPath
	        , "UInt", CreateTargetPath
	        , "UInt", Callback
	        , "UInt" )
	}


	unzipToDisk( zipFilename, zipFileNumber, TargetPath, CreateTargetPath=1, Callback=0 ) {
	  IfNotExist, %zipfileName%, Return
	  Return DllCall("MiniZIP\ZIP_ExtractFile"
	       , ( A_IsUnicode ? "AStr" : "Str" ), zipFilename
	       , "UInt", zipFileNumber
	       , ( A_IsUnicode ? "AStr" : "Str" ), TargetPath
	       , "UInt", CreateTargetPath
	       , "UInt", Callback
	       , "UInt" )
	}


	unzipToMemory( zipFilename, zipFileNumber=1, Callback=0 ) {
	  IfNotExist, %zipfileName%, Return ErrorLevel := 0
	  Return hGlobal := DllCall( "MiniZIP\ZIP_CatchFile"
          , ( A_IsUnicode ? "AStr" : "Str" )
          , zipFilename
          , "UInt", zipFileNumber
          , "UInt" )
	      , ErrorLevel := DllCall( "GlobalSize", "UInt",hGlobal, "UInt" )
	}


	packMemory( memPointer, memSize, Compression=9 ) {
	  Return hGlobal := DllCall( "MiniZIP\ZIP_PackMemory"
          , "UInt", memPointer
          , "UInt", memSize
          , "Int" , Compression
          , "UInt" )
	   , ErrorLevel := DllCall( "GlobalSize", "UInt",hGlobal, "UInt" )
	}


	upackMemory( memPointerSource, memPointerTarget ) {
	  Return DllCall( "MiniZIP\ZIP_UnpackMemory"
          , "UInt", memPointerSource
          , "UInt", memPointerTarget
          , "UInt" )
	}

}