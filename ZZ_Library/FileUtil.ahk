class FileUtil {

    static void := FileUtil._init()

    _init() {
    }

    __New() {
		throw Exception( "FileUtil is a static class, dont instante it!", -1 )
    }

	getDir( path ) {

		IfNotExist %path%, return ""

		if( this.isDir(path) )
			return path

		;SplitPath, filePath, fileName, fileDir, fileExtention, fileNameWithoutExtension, DriveName
		SplitPath, path, fileName, fileDir, fileExtention, fileNameWithoutExtension, DriveName
		return fileDir
		
	}

	getExt( filePath ) {

		IfNotExist %filePath%
			return ""
		
		SplitPath, filePath, fileName, fileDir, fileExtention, fileNameWithoutExtension, DriveName
		StringLower, fileExt, fileExt

		return fileExt

	}
	
	getFileName( filePath ) {

		IfNotExist %filePath%
			return ""
		
		SplitPath, filePath, fileName, fileDir, fileExtention, fileNameWithoutExtension, DriveName
		return fileName

	}
	
	getFiles( path, pattern=".*" ) {
		
		files := []

		if ( this.isFile(path) ) {
			if RegExMatch( path, pattern )
				files.Insert( path )

		} else {
			currDir := this.getDir( path )
			Loop, %currDir%\*
			{
				if not RegExMatch( A_LoopFileFullPath, pattern )
					continue
				
				files.Insert( A_LoopFileFullPath )
			}
			sortArray( files )
		}
		
		return files
		
	}

	getFile( pathDirOrFile, pattern=".*" ) {

		if ( pathDirOrFile == "" or this.isFile(pathDirOrFile) )  {
			return pathDirOrFile
		}

        files := this.getFiles( pathDirOrFile, pattern )

        if ( files.MaxIndex() > 0 ) {
        	return files[ 1 ]
        }

        return ""

	}
	
	isDir( path ) {

		IfNotExist %path%, return false

		FileGetAttrib, attr, %path%
		
		Return InStr( attr, "D" )
	}
	
	isFile( path ) {

		IfNotExist %path%, return false

		FileGetAttrib, attr, %path%
		
		Return ! InStr( attr, "D" )

	}

	readProperties( path ) {

		prop := []

		Loop, Read, %path%
		{

			If RegExMatch(A_LoopReadLine, "^#.*" )
				continue

			splitPosition := InStr(A_LoopReadLine, "=" )

			If ( splitPosition = 0 ) {
				key := A_LoopReadLine
				val := ""
			} else {
				key := SubStr( A_LoopReadLine, 1, splitPosition - 1 )
				val := SubStr( A_LoopReadLine, splitPosition + 1 )
			}
			
			prop[ Trim(key) ] := Trim(val)

		}

		return prop

	}

}