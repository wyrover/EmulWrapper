#NoEnv

/*
; TestCode
#Include Common.ahk

if !(7zipHandler := new 7Zip())
{
  msgbox % "Failed loading 7Zip library"
  ExitApp  
}


fileName := "d:\download\zipTest.zip"

msgbox % "fileCount : " 7zipHandler.getFileCount( fileName )
msgbox % "version   : " 7zipHandler.getVersion()
msgbox % "list      : " 7zipHandler.list( fileName )

7zipHandler.close()

ExitApp
*/


class 7Zip {

  static gop   := Object()
  static _void := 7Zip._init()

  _init() {
    7Zip.gop.dllFile   := "7-zip32.dll"
    7Zip.gop.dllName   := "7-zip32"

    if( Detector.64 == true )
    {
      7Zip.gop.dllFile := "7-zip64.dll"
      7Zip.gop.dllName := "7-zip64"
    }

  }

  op := Object()

  __New() {
    
    this.op._hModule       := 0

    ;--- Default options
    this.op.hide           := 0       ;Callback is called (bool);a,d,e,x,u
    this.op.CompressLevel  := 5       ;0-9 (level);a,d,u
    this.op.CompressType   := "zip"   ;7z,gzip,zip,bzip2,tar,iso,udf (string);a
    this.op.Recurse        := 0       ;0 - Disable, 1 - Enable, 2 - Enable only for wildcard names;a,d,e,x,u
    this.op.IncludeFile    := ""      ;Specifies filenames and wildcards or list file that specify processed files (string);a,d,e,x,u
    this.op.ExcludeFile    := ""      ;Specifies what filenames or (and) wildcards must be excluded from operation (string);a,d,e,x,u
    this.op.Password       := ""      ;Password (string);a,d,e,x,u
    this.op.SFX            := ""      ;Self extracting archive module name (string);a,u
    this.op.VolumeSize     := 0       ;Create volumes of specified sizes (integer);a
    this.op.WorkingDir     := ""      ;Sets working directory for temporary base archive (string);a,d,e,x,u
    this.op.ExtractPaths   := 1       ;Extract full paths (default 1);e,x
    this.op.Output         := ""      ;Output directory (string);e,x
    this.op.Overwrite      := 0       ;0 - Overwrite All, 1 - Skip extracting of existing, 2 - Auto rename extracting file, 3 - auto rename existing file;e,x
    this.op.IncludeArchive := ""      ;Include archive filenames (string);e,x
    this.op.ExcludeArchive := ""      ;Exclude archive filenames (string);e,x
    this.op.Yes            := 0       ;assume Yes on all queries;e,x
    
    this.op.FNAME_MAX32    := 512   ;Filename string max
    ;--- File attributes constants ---
    this.op.FA_RDONLY    := 0x01 ;Readonly
    this.op.FA_HIDDEN    := 0x02 ;Hidden
    this.op.FA_SYSTEM    := 0x04 ;System file
    this.op.FA_LABEL     := 0x08 ;Volume label
    this.op.FA_DIREC     := 0x10 ;Directory
    this.op.FA_ARCH      := 0x20 ;Retention bit
    this.op.FA_ENCRYPTED := 0x40 ;password protected

    if !( r := DllCall("LoadLibrary", "Str", 7Zip.gop.dllFile) )
      return 0 , ErrorLevel := -1
    
    this.op._hModule := r

  }

  ;
  ; Function: 7Zip_List
  ; Description:
  ;      List files in an archive
  ; Syntax: 7Zip_Add(hWnd, sArcName)
  ; Parameters:
  ;      sArcName - Name of archive to list
  ;      hWnd - handle of window (calling application), can be 0
  ; Return Value:
  ;      Response buffer (string) on success, 0 on failure.
  ; Related: 
  ; Remarks:
  ;      Errorlevel is set to returned value of the function on success.
  ;
  list( sArcName ) {
    commandline  = l "%sArcName%"
    commandline .= this.op.Hide ? " -hide" : ""
    commandline .= this.op.Password ? " -p" . this.op.Password : ""
    
    return this._run( commandline )
  }

  ;
  ; Function: 7Zip_Add
  ; Description:
  ;      Add files to archive
  ; Syntax: 7Zip_Add(hWnd, sArcName, sFileName)
  ; Parameters:
  ;      sArcName - Name of archive to be created
  ;      sFileName - Files to archive
  ;      hWnd - handle of window (calling application), can be 0
  ; Return Value:
  ;      Response buffer (string) on success, 0 on failure.
  ; Remarks:
  ;      Errorlevel is set to returned value of the function on success.
  ; Related: 7Zip_Update , 7Zip_Delete
  ;
  add( sArcName, sFileName ) {
    commandline  = a "%sArcName%" "%sFileName%"
    commandline .= this.op.Hide ? " -hide" : ""
    commandline .= " -mx" . this.op.CompressLevel
    commandline .= " -t" . this.op.CompressType
    commandline .= this._recursion()
    commandline .= this.op.Password ? " -p" . this.op.Password : ""
    commandline .= FileExist(this.op.SFX) ? " -sfx" . this.op.SFX : ""
    commandline .= this.op.VolumeSize ? " -v" . this.op.VolumeSize : ""
    commandline .= this.op.WorkingDir ? " -w" . this.op.WorkingDir : ""
    
    if this.op.IncludeFile
      commandline .= ( SubStr(this.op.IncludeFile,1,1) = "@" ) ? " -i""" . this.op.IncludeFile . """" : " -i!""" . this.op.IncludeFile . """"
    if this.op.ExcludeFile
      commandline .= ( SubStr(this.op.ExcludeFile,1,1) = "@" ) ? " -x""" . this.op.ExcludeFile . """" : " -x!""" . this.op.ExcludeFile . """"
    
    return this._run( commandline )
  }


  ;
  ; Function: 7Zip_Delete
  ; Description:
  ;      Add files to archive
  ; Syntax: 7Zip_Delete(hWnd, sArcName, sFileName)
  ; Parameters:
  ;      sArcName - Name of the archive
  ;      sFileName - Files to delete
  ;      hWnd - handle of window (calling application), can be 0
  ; Return Value:
  ;      Response buffer (string) on success, 0 on failure.
  ; Remarks:
  ;      Errorlevel is set to returned value of the function on success.
  ; Related: 7Zip_Update , 7Zip_Add
  ;
  delete( sArcName, sFileName ) {
    commandline  = d "%sArcName%" "%sFileName%"
    commandline .= this.op.Hide ? " -hide" : ""
    commandline .= " -mx" . this.op.CompressLevel
    commandline .= this._recursion()
    commandline .= this.op.Password ? " -p" . this.op.Password : ""
    commandline .= this.op.WorkingDir ? " -w" . this.op.WorkingDir : ""  
    
    if this.op.IncludeFile
      commandline .= ( SubStr(this.op.IncludeFile,1,1) = "@" ) ? " -i""" . this.op.IncludeFile . """" : " -i!""" . this.op.IncludeFile . """"
    if this.op.ExcludeFile
      commandline .= ( SubStr(this.op.ExcludeFile,1,1) = "@" ) ? " -x""" . this.op.ExcludeFile . """" : " -x!""" . this.op.ExcludeFile . """"

    return this._run( commandline )
  }

  ;
  ; Function: 7Zip_Extract
  ; Description:
  ;      Extract files from archive
  ; Syntax: 7Zip_Extract(hWnd, sArcName)
  ; Parameters:
  ;      sArcName - Name of archive to extract
  ;      hWnd - handle of window (calling application), can be 0
  ; Return Value:
  ;      Response buffer (string) on success, 0 on failure.
  ; Remarks:
  ;      Errorlevel is set to returned value of the function on success.
  ;      Note that output folder can be specified as a property
  ; Related: 7Zip_Update , 7Zip_Delete
  ;
  extract( sArcName ) {
    commandline := this.op.ExtractPaths ? "x """ . sArcName . """" : "e """ . sArcName . """"
    commandline .= this.op.Hide ? " -hide" : ""
    commandline .= this._recursion()
    commandline .= this.op.Output ? " -o""" . this.op.Output . """" : ""
    commandline .= this._overwrite()
    commandline .= this.op.Password ? " -p" . this.op.Password : ""
    commandline .= this.op.WorkingDir ? " -w" . this.op.WorkingDir : ""  
    commandline .= this.op.Yes ? " -y" : ""
    
    if this.op.IncludeArchive
      commandline .= ( SubStr(this.op.IncludeArchive,1,1) = "@" ) ? " -ai""" . this.op.IncludeArchive . """" : " -ai!""" . this.op.IncludeArchive . """"
    if this.op.ExcludeArchive
      commandline .= ( SubStr(this.op.ExcludeArchive,1,1) = "@" ) ? " -ax""" . this.op.ExcludeArchive . """" : " -ax!""" . this.op.ExcludeArchive . """"
    
    if this.op.IncludeFile
      commandline .= ( SubStr(this.op.IncludeFile,1,1) = "@" ) ? " -i""" . this.op.IncludeFile . """" : " -i!""" . this.op.IncludeFile . """"
    if this.op.ExcludeFile
      commandline .= ( SubStr(this.op.ExcludeFile,1,1) = "@" ) ? " -x""" . this.op.ExcludeFile . """" : " -x!""" . this.op.ExcludeFile . """"

    return this._run( commandline )
  }


  ;
  ; Function: 7Zip_Update
  ; Description:
  ;      Update files to an archive
  ; Syntax: 7Zip_Update(hWnd, sArcName, sFileName)
  ; Parameters:
  ;      sArcName - Name of archive to be updated
  ;      sFileName - Files to add
  ;      hWnd - handle of window (calling application), can be 0
  ; Return Value:
  ;      Response buffer (string) on success, 0 on failure.
  ; Remarks:
  ;      Errorlevel is set to returned value of the function on success.
  ; Related: 7Zip_Add , 7Zip_Delete
  ;
  update( sArcName, sFileName ) {
    commandline  = a "%sArcName%" "%sFileName%"
    commandline .= this.op.Hide ? " -hide" : ""
    commandline .= " -mx" . this.op.CompressLevel
    commandline .= this._recursion()
    commandline .= this.op.Password ? " -p" . this.op.Password : ""
    commandline .= FileExist(this.op.SFX) ? " -sfx" . this.op.SFX : ""
    commandline .= this.op.WorkingDir ? " -w" . this.op.WorkingDir : ""
    
    if this.op.IncludeFile
      commandline .= ( SubStr(this.op.IncludeFile,1,1) = "@" ) ? " -i""" . this.op.IncludeFile . """" : " -i!""" . this.op.IncludeFile . """"
    if this.op.ExcludeFile
      commandline .= ( SubStr(this.op.ExcludeFile,1,1) = "@" ) ? " -x""" . this.op.ExcludeFile . """" : " -x!""" . this.op.ExcludeFile . """"
    return this._run( commandline )
  }

  ;
  ; Function: 7Zip_SetOwnerWindowEx
  ; Description:
  ;      Appoints the call-back function in order to receive the information of the compressing/unpacking
  ; Syntax: 7Zip_SetOwnerWindowEx(hWnd, sProcFunc)
  ; Parameters:
  ;      sProcFunc - Callback function name
  ;      hWnd - handle of window (calling application), can be 0
  ; Return Value:
  ;      True on success, false otherwise
  ; Related: 7Zip_KillOwnerWindowEx
  ; Example:
  ;      file:example_callback.ahk
  ;
  setOwnerWindowEx( sProcFunc ) {
    Address := RegisterCallback(sProcFunc, "F", 4)
    Return DllCall( 7Zip.gop.dllName "\SevenZipSetOwnerWindowEx","Ptr", this.op._hModule , "ptr", Address )
  }

  ;
  ; Function: 7Zip_KillOwnerWindowEx
  ; Description:
  ;      Removes the callback
  ; Syntax: 7Zip_KillOwnerWindowEx(hWnd)
  ; Parameters:
  ;      hWnd - Handle to parent or owner window
  ; Return Value:
  ;      True on success, false otherwise
  ; Related: 7Zip_SetOwnerWindowEx
  ;
  killOwnerWindowEx() {
    Return DllCall( 7Zip.gop.dllName "\SevenZipKillOwnerWindowEx" , "Ptr", this.op._hModule )
  }

  ;
  ; Function: 7Zip_CheckArchive
  ; Description:
  ;      Check archive integrity 
  ; Syntax: 7Zip_CheckArchive(sArcName)
  ; Parameters:
  ;      sArcName - Name of archive to be created
  ; Return Value:
  ;      True on success, false otherwise
  ;
  checkArchive( sArcName ) {
    Return DllCall( 7Zip.gop.dllName "\SevenZipCheckArchive", "AStr", sArcName, "int", 0 )
  }


  ;
  ; Function: 7Zip_GetArchiveType
  ; Description:
  ;      Get the type of archive
  ; Syntax: 7Zip_GetArchiveType(sArcName)
  ; Parameters:
  ;      sArcName - Name of archive
  ; Return Value:
  ;      0 - Unknown type
  ;      1 - ZIP type
  ;      2 - 7Z type
  ;      -1 - Failure
  ;
  getArchiveType( sArcName ) {
    Return DllCall( 7Zip.gop.dllName "\SevenZipGetArchiveType", "AStr", sArcName )
  }

  ;
  ; Function: 7Zip_GetFileCount
  ; Description:
  ;      Get the number of files in archive
  ; Syntax: 7Zip_GetFileCount(sArcName)
  ; Parameters:
  ;      sArcName - Name of archive
  ; Return Value:
  ;      Count on success, -1 otherwise
  ;
  getFileCount( sArcName ) {
    Return DllCall( 7Zip.gop.dllName "\SevenZipGetFileCount", "AStr", sArcName )
  }

  ;
  ; Function: 7Zip_ConfigDialog
  ; Description:
  ;      Shows the about dialog for 7-zip32.dll
  ; Syntax: 7Zip_ConfigDialog(hWnd)
  ; Parameters:
  ;      hWnd - handle of owner window
  ;
  configDialog() {
    Return DllCall( 7Zip.gop.dllName "\SevenZipConfigDialog", "Ptr", this.op._hModule, "ptr",0, "int",0 )
  }

  queryFunctionList( iFunction = 0 ) {
    Return DllCall( 7Zip.gop.dllName "\SevenZipQueryFunctionList", "int", iFunction )
  }

  ;
  ; Function: 7Zip_GetVersion
  ; Description:
  ;      Version of 7-zip32.dll
  ; Syntax: 7Zip_GetVersion()
  ; Return Value:
  ;      Version string
  ;
  getVersion() {
    aRet := DllCall( 7Zip.gop.dllName "\SevenZipGetVersion", "Short" )
    Return SubStr(aRet,1,1) . "." . SubStr(aRet,2)
  }

  ;
  ; Function: 7Zip_GetSubVersion
  ; Description:
  ;      Subversion of 7-zip32.dll
  ; Syntax: 7Zip_GetSubVersion()
  ; Return Value:
  ;      Subversion string
  ;
  getSubVersion() {
    return DllCall( 7Zip.gop.dllName "\SevenZipGetSubVersion", "Short" )
  }

  ;
  ; Function: 7Zip_Close
  ; Description:
  ;      Free 7-zip32.dll library
  ; Syntax: 7Zip_Close()
  ;
  close() {
    DllCall("FreeLibrary", "Ptr", this.op._hModule)
    this.op._hModule := 0
  }

  ; FUNCTIONS BELOW - CREDIT TO LEXIKOS -------------------------------------------------------

  ;
  ; Function: 7Zip_OpenArchive
  ; Description:
  ;      Open archive and return handle for use with 7Zip_FindFirst
  ; Syntax: 7Zip_OpenArchive(sArcName, [hWnd])
  ; Parameters:
  ;      sArcName - Path of archive
  ;      hWnd - Handle of calling window
  ; Return Value:
  ;      Handle for use with 7Zip_FindFirst function, 0 on error.
  ; Remarks:
  ;      Nil
  ; Related: 7Zip_CloseArchive, 7Zip_FindFirst , File Info Functions
  ; Example:
  ;      hArc := 7Zip_OpenArchive("C:\Path\To\Archive.7z")
  ;
  openArchive( sArcName ) {
    Return DllCall( 7Zip.gop.dllName "\SevenZipOpenArchive", "Ptr", this.op._hModule, "AStr", sArcName, "int", 0 )
  }

  ;
  ; Function: 7Zip_CloseArchive
  ; Description:
  ;      Closes the archive handle
  ; Syntax: 7Zip_CloseArchive(hArc)
  ; Parameters:
  ;      hArc - Handle retrived from 7Zip_OpenArchive
  ; Return Value:
  ;      -1 on error
  ; Remarks:
  ;      Nil
  ; Related: 7Zip_OpenArchive
  ; Example:
  ;      7Zip_CloseArchive(hArc)
  ;
  closeArchive( hArc ) {
    Return DllCall( 7Zip.gop.dllName "\SevenZipCloseArchive", "Ptr", hArc )
  }

  ;
  ; Function: 7Zip_FindFirst
  ; Description:
  ;      Find first file for search criteria in archive
  ; Syntax: 7Zip_FindFirst(hArc, sSearch, [o7zip__info])
  ; Parameters:
  ;      hArc - handle of archive (returned from 7Zip_OpenArchive)
  ;      sSearch - Search string (wildcards allowed)
  ;      o7zip__info - (Optional) Name of object to recieve details of file.
  ; Return Value:
  ;      Object with file details on success. If 3rd param was 0, returns true on success. False on failure.
  ; Remarks:
  ;      If third param is omitted, details are returned in a new object.
  ;      If it is set to 0, details are not retrieved. (You can use the other functions to get details.)
  ; Related: 7Zip_FindNext , 7Zip_OpenArchive , File Info Functions
  ; Example:
  ;      file:example_archive_info.ahk
  ;
  findFirst( hArc, sSearch, o7zip__info="" ) {
    if (o7zip__info = 0)
    {
      r := DllCall(7Zip.gop.dllName "\SevenZipFindFirst", "Ptr", hArc, "AStr", sSearch, "ptr", 0)
      return ( r ? 0 : 1 ), ErrorLevel := (r ? r : ErrorLevel)
    }
    if !IsObject(o7zip__info)
      o7zip__info := Object()
    VarSetCapacity(tINDIVIDUALINFO , 558, 0)
    
    If DllCall(7Zip.gop.dllName "\SevenZipFindFirst", "Ptr", hArc, "AStr", sSearch, "ptr", &tINDIVIDUALINFO)
      Return 0
    o7zip__info.OriginalSize   := NumGet(tINDIVIDUALINFO , 0, "UInt")
    o7zip__info.CompressedSize := NumGet(tINDIVIDUALINFO , 4, "UInt")
    o7zip__info.CRC            := NumGet(tINDIVIDUALINFO , 8, "UInt")
  ; uFlag                      := NumGet(tINDIVIDUALINFO , 12, "UInt") ;always 0
  ; uOSType                    := NumGet(tINDIVIDUALINFO , 16, "UInt") ;always 0  
    o7zip__info.Ratio          := NumGet(tINDIVIDUALINFO , 20, "UShort")
    o7zip__info.Date           := this._dosDateTimeToStr(NumGet(tINDIVIDUALINFO , 22, "UShort"),NumGet(tINDIVIDUALINFO , 24, "UShort"))
    o7zip__info.FileName       := StrGet(&tINDIVIDUALINFO+26 ,513,"CP0")
    o7zip__info.Attribute      := StrGet(&tINDIVIDUALINFO+542,8  ,"CP0")
    o7zip__info.Mode           := StrGet(&tINDIVIDUALINFO+550,8  ,"CP0")
    
    return o7zip__info
  }

  ;
  ; Function: 7Zip_FindNext
  ; Description:
  ;      Find next file for search criteria in archive
  ; Syntax: 7Zip_FindNext(hArc, [o7zip__info])
  ; Parameters:
  ;      hArc - handle of archive (returned from 7Zip_OpenArchive)
  ;      o7zip__info - (Optional) Name of object to recieve details of file.
  ; Return Value:
  ;      Object with file details on success. If 2nd param was 0, returns true on success. False on failure.
  ; Remarks:
  ;      If second param is omitted, details are returned in a new object. 
  ;      If it is set to 0, details are not retrieved. (You can use the other functions to get details.)
  ; Related: 7Zip_FindFirst , 7Zip_OpenArchive, File Info Functions
  ; Example:
  ;      file:example_archive_info.ahk
  ;
  findNext( hArc, o7zip__info="" ) {
    if (o7zip__info = 0)
    {
      r := DllCall(7Zip.gop.dllName "\SevenZipFindFirst", "Ptr", hArc, "AStr", sSearch, "ptr", 0)
      return ( r ? 0 : 1 ), ErrorLevel := (r ? r : ErrorLevel)
    }
    if !IsObject(o7zip__info)
      o7zip__info := Object()
    VarSetCapacity(tINDIVIDUALINFO , 558, 0)
    if DllCall(7Zip.gop.dllName "\SevenZipFindNext","Ptr", hArc, "ptr", &tINDIVIDUALINFO)
      Return 0 

    o7zip__info.OriginalSize   := NumGet(tINDIVIDUALINFO , 0, "UInt")
    o7zip__info.CompressedSize := NumGet(tINDIVIDUALINFO , 4, "UInt")
    o7zip__info.CRC            := NumGet(tINDIVIDUALINFO , 8, "UInt")
    o7zip__info.Ratio          := NumGet(tINDIVIDUALINFO , 20, "UShort")
    o7zip__info.Date           := this._dosDateTimeToStr(NumGet(tINDIVIDUALINFO , 22, "UShort"),NumGet(tINDIVIDUALINFO , 24, "UShort"))  
    o7zip__info.FileName       := StrGet(&tINDIVIDUALINFO+26 ,513,"CP0")
    o7zip__info.Attribute      := StrGet(&tINDIVIDUALINFO+542,8  ,"CP0")
    o7zip__info.Mode           := StrGet(&tINDIVIDUALINFO+550,8  ,"CP0")
    
    return o7zip__info
  }

  ;
  ; Function: File Info Functions
  ; Description:
  ;      Using handle hArc, get info of file(s) in archive.
  ; Syntax: 7Zip_<InfoFunction>(hArc)
  ; Parameters:
  ;      7Zip_GetFileName - Get file name
  ;      7Zip_GetArcOriginalSize - Original size of file
  ;      7Zip_GetArcCompressedSize - Compressed size
  ;      7Zip_GetArcRatio - Compression ratio
  ;      7Zip_GetDate - Date
  ;      7Zip_GetTime - Time
  ;      7Zip_GetCRC - File CRC
  ;      7Zip_GetAttribute - File Attribute
  ;      7Zip_GetMethod - Compression method (LZMA or PPMD)
  ; Return Value:
  ;      -1 on error
  ; Remarks:
  ;      See included example for details
  ; Related: 7Zip_OpenArchive , 7Zip_FindFirst
  ; Example:
  ;      file:example_archive_info.ahk
  ;
  getFileName(hArc) {
    VarSetCapacity( tNameBuffer,513 )
    If !DllCall(7Zip.gop.dllName "\SevenZipGetFileName", "Ptr", hArc, "ptr", &tNameBuffer, "int", 513)
      Return StrGet(&tNameBuffer,513,"CP0")
  }

  getArcOriginalSize(hArc) {
    Return DllCall(7Zip.gop.dllName "\SevenZipGetArcOriginalSize", "Ptr", hArc)
  }

  getArcCompressedSize(hArc) {
    Return DllCall(7Zip.gop.dllName "\SevenZipGetArcCompressedSize", "Ptr", hArc)
  }

  getArcRatio(hArc) {
    Return DllCall(7Zip.gop.dllName "\SevenZipGetArcRatio", "Ptr", hArc, "short")
  }

  getDate(hArc) {
    Return this._dosDate(DllCall(7Zip.gop.dllName "\SevenZipGetDate", "Ptr", hArc, "Short"))
  }

  getTime(hArc) {
    Return this._dosTime(DllCall(7Zip.gop.dllName "\SevenZipGetTime", "Ptr", hArc, "Short"))
  }

  getCRC(hArc) {
    Return DllCall(7Zip.gop.dllName "\SevenZipGetCRC", "Ptr", hArc, "UInt")
  }

  getAttribute(hArc) {
    return DllCall(7Zip.gop.dllName "\SevenZipGetAttribute", "Ptr", hArc)
  }

  getMethod(hArc) {
    VarSetCapacity(sBUFFER,8)
    if !DllCall(7Zip.gop.dllName "\SevenZipGetMethod" , "Ptr", hArc , "ptr", &sBuffer,"int", 8)
      Return StrGet(&sBUFFER, 8, "CP0")
  }

  ; FUNCTIONS FOR INTERNAL USE --------------------------------------------------------------------------------------------------
  _run(sCommand) {
    nSize := 32768
    VarSetCapacity(tOutBuffer,nSize)
    aRet := DllCall(7Zip.gop.dllName "\SevenZip", "Ptr", this.op._hModule
            ,"AStr", sCommand
            ,"Ptr", &tOutBuffer
            ,"Int", nSize)
    If !ErrorLevel
      return StrGet(&tOutBuffer,nSize,"CP0"), ErrorLevel := aRet
    else
      return 0
  }

  _recursion() {
    if this.op.Recurse = 1
      Return " -r"
    if this.op.Recurse = 2
      Return " -r0"
    Else
      Return " -r-"
  }

  _overwrite() {
    if (this.op.Overwrite = 0)
      Return " -aoa"
    else if (this.op.Overwrite = 1)
      Return " -aos"
    else if (this.op.Overwrite = 2)
      Return " -aou"
    else if (this.op.Overwrite = 3)
      Return " -aot"
    Else
      Return " -aoa"
  }

  _dosDate( ByRef DosDate ) {
    day   := DosDate & 0x1F
    month := (DosDate<<4) & 0x0F
    year  := ((DosDate<<8) & 0x3F) + 1980
    return "" . year . "/" . month . "/" . day
  }

  _dosTime( ByRef DosTime ) {
    sec   := (DosTime & 0x1F) * 2
    min   := (DosTime<<4) & 0x3F
    hour  := (DosTime<<10) & 0x1F
    return "" . hour . ":" . min . ":" . sec
  }

  _dosDateTimeToStr( ByRef DosDate, ByRef DosTime ) {
    VarSetCapacity(FileTime,8)
    DllCall("DosDateTimeToFileTime", "UShort", DosDate, "UShort", DosTime, "UInt", &FileTime)
    VarSetCapacity(SystemTime, 16, 0)
    If (!NumGet(FileTime,"UInt") && !NumGet(FileTime,4,"UInt"))
     Return 0
    DllCall("FileTimeToSystemTime", "PTR", &FileTime, "PTR", &SystemTime)
    Return NumGet(SystemTime,6,"short") ;date
      . "/" . NumGet(SystemTime,2,"short") ;month
      . "/" . NumGet(SystemTime,0,"short") ;year
      . " " . NumGet(SystemTime,8,"short") ;hours
      . ":" . ((StrLen(tvar := NumGet(SystemTime,10,"short")) = 1) ? "0" . tvar : tvar) ;minutes
      . ":" . ((StrLen(tvar := NumGet(SystemTime,12,"short")) = 1) ? "0" . tvar : tvar) ;seconds
    ;      . "." . NumGet(SystemTime,14,"short") ;milliseconds
  }

}