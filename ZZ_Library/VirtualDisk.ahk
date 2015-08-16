class VirtualDisk {

    static void := VirtualDisk._init()

    _init() {
    	this.daemonPath := "c:\Program Files (x86)\DAEMON Tools Lite\DTLite.exe"
    }

    __New() {
		throw Exception( "VirtualDisk is a static class, dont instante it!", -1 )
    }

    open( filePath, showError = true  ) {

		IfNotExist % this.daemonPath
		{
			
			if showError = true
				MsgBox % "VirtualDisk [" this.daemonPath "] is not exist."
			return false
	    }

		IfNotExist %filePath%
		{
			if showError = true
				MsgBox % "File [" filePath "] is not exist."
			return false
		}
		
		fileExt       := this.getFileExt( filePath )
		fileExtWanted := "mdx,iso,cue,bin,ccd"
		
		IfNotInString, fileExtWanted, %fileExt%
		{
			if showError = true
				MsgBox % "File [" filePath "] is not disk image. (" fileExtWanted ")"
			return false
		}
		
		RunWait % """" this.daemonPath """ -mount scsi, 0, """ filePath """"
		
		if ErrorLevel
		{    
			return false
		}
		
		return true
    }
	
	close() {
		RunWait % """" this.daemonPath """ -unmount scsi, 0"
	}

	getFileExt( filePath ) {

		IfNotExist %filePath%
			return ""
		
		SplitPath, filePath,,, fileExt
		StringLower, fileExt, fileExt

		return fileExt
	}

}