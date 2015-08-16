SetWorkingDir %A_ScriptDir%
SplitPath, A_AhkPath,, A_AhkDir

MiniZIP_Init( "minizip_x64.dll" )

zipfile:="\\NAS\emul\emulator\ZZ_Library\minizip\picture.zip"
unpackfile:="earth.bmp"
zipFileNumber := MZ_ZipGetFileNumber(zipfile , unpackfile )
MZ_UnzipFileToDisk( zipfile, zipFileNumber, A_ScriptDir "\" )


ZIP_CentralDir( "picture.zip" )

ExitApp


/*________________________________________________________________________________________
       __  __ _____ _   _ _____ ___________ _____       _____  _      _
      |  \/  |_   _| \ | |_   _|___  /_   _|  __ \     |  __ \| |    | |
      | \  / | | | |  \| | | |    / /  | | | |__) |    | |  | | |    | |
      | |\/| | | | | . ` | | |   / /   | | |  ___/     | |  | | |    | |
      | |  | |_| |_| |\  |_| |_ / /__ _| |_| |     _   | |__| | |____| |____
      |_|  |_|_____|_| \_|_____/_____|_____|_|    (_)  |_____/|______|______|
      http://edel.realsource.de/downloads/doc_download/27-minizip-dll

 Script       :  MiniZIP.ahk - AutoHotkey Wrapper for minizip.dll
 Created On   :  27-Jun-2012  /  Last Modified:  27-Jun-2012  /  v1.0
 Author       :  SKAN ( A.N.Suresh Kumar, arian.suresh@gmail.com )
 Forum Topic  :  www.autohotkey.com/community/viewtopic.php?t=88218
 My License   :  Unrestricted! www.autohotkey.com/community/viewtopic.php?p=505843#p505843
 _________________________________________________________________________________________


 The DLL exported functions names are confusing, atleast for me!.
 Here follows the list of wrapper functions, categorically named
 and arranged in order of importance:
 _______________________________________________________________
 
 Initialization Functions:
 
       01)  MiniZIP_Init()                 <--             Kernel32\LoadLibrary()
       02)  MZ_SetPassword()               <--             ZIP_SetPassword()

 Creating/Updating ZIP files:
 
       03)  MZ_ZipCreate()                 <--             ZIP_FileCreate()
       04)  MZ_ZipOpen()                   <--             ZIP_FileOpen()
       05)  MZ_ZipAddFolder()              <--             ZIP_DirAdd()
       06)  MZ_ZipAddFile()                <--             ZIP_FileAdd()
       07)  MZ_ZipAddMem()                 <--             ZIP_MemAdd()
       08)  MZ_ZipClose()                  <--             ZIP_FileClose()

 Unzipping ZIP files:
 
       09)  MZ_ZipIsValid()                <--             ZIP_IsZipArchive()
       10)  MZ_ZipGetFileCount()           <--             ZIP_GetFilesCount()
       11)  MZ_ZipGetFileNumber()          <--             ZIP_GetFileNumber()
       12)  MZ_ZipIsPasswordRequired()     <--             ZIP_IsPasswordRequired()
       13)  MZ_ZipGetFilename()            <--             ZIP_GetFileInfo()
       14)  MZ_ZipGetComment()             <--             ZIP_GetFileComment()

       15)  MZ_UnzipAll()                  <--             ZIP_ExtractArchiv()
       16)  MZ_UnzipFileToDisk()           <--             ZIP_ExtractFile()
       17)  MZ_UnzipFileToMem()            <--             ZIP_CatchFile()

 Zip/Unzip for MEMORY VARIABLE
 
       18)  MZ_MemPack()                   <--             ZIP_PackMemory()
       19)  MZ_MemUnpack()                 <--             ZIP_UnpackMemory()



 Compression Parameter
 _____________________
 MiniZIP handles 4 levels of Compression.  When function expects Compression as parameter,
 pass one of the following Constant value:
 
 NO_COMPRESSION = 0 /  BEST_SPEED = 1 /  BEST_COMPRESSION = 9 /  DEFAULT_COMPRESSION = -1



 Callback Parameter
 _____________________

 Zip/Unzip functions offer callback facility to AHK functions for which you may pass the
 address returned by

 RegisterCallback( "ZIP_ArchivCallback" )
 OR
 RegisterCallback( "ZIP_PackerCallback" )
 

 Callback procedure for MZ_UnzipAll()
                        MZ_ZipAddFolder()
 
 
          ZIP_ArchivCallback( Progress, Files ) {
            Return 0 ;  ZIP_OK = 0  or  ZIP_CANCEL = 1
          }



 Callback procedure for MZ_ZipAddFile()
                        MZ_ZipAddMem()
                        MZ_UnzipFileToMem()
                        MZ_UnzipFileToDisk()
                        

          ZIP_PackerCallback( Progress ) {
            Return 0 ;  ZIP_OK = 0  or  ZIP_CANCEL = 1
          }


__________________________________________________________________________________________
*/

MiniZIP_Init( DllFile ) {                                     ;             MiniZIP_Init()
 Return DllCall( "LoadLibrary", Str,DllFile, UInt )
}


MZ_SetPassword( Password="" ) {                               ;           MZ_SetPassword()
 Return DllCall( "MiniZIP\ZIP_SetPassword"
             , ( A_IsUnicode ? "AStr" : "Str" ), Password
                                               , UInt )
}


MZ_ZipCreate( zipFilename ) {                                 ;             MZ_ZipCreate()
 Return DllCall( "MiniZIP\ZIP_FileCreate"
             , ( A_IsUnicode ? "AStr" : "Str" ), zipFileName, UInt )
}


MZ_ZipOpen( zipFilename ) {                                   ;               MZ_ZipOpen()
 IfNotExist, %zipfileName%, Return
 Return DllCall( "MiniZIP\ZIP_FileOpen"
             , ( A_IsUnicode ? "AStr" : "Str" ), zipFilename
                                               , UInt )
}


MZ_ZipAddFolder( zipHandle, SourceDir, Compression=-1         ;          MZ_ZipAddFolder()
                                     , Callback=0 ) {
 Return DllCall( "MiniZIP\ZIP_DirAdd"
                                               , UInt, zipHandle
             , ( A_IsUnicode ? "AStr" : "Str" ), SourceDir
                                         , Int , Compression
                                         , UInt, Callback
                                               , UInt )
}


MZ_ZipAddFile( zipHandle, SourceFilename, ArchiveFilename     ;            MZ_ZipAddFile()
                        , Compression=-1, Callback=0 ) {
 Return DllCall( "MiniZIP\ZIP_FileAdd"
                                         , UInt, zipHandle
             , ( A_IsUnicode ? "AStr" : "Str" ), SourceFilename
             , ( A_IsUnicode ? "AStr" : "Str" ), ArchiveFilename
                                         , Int , Compression
                                         , UInt, Callback
                                               , UInt )
}


MZ_ZipAddMem( zipHandle, memPointer, memSize, ArchiveFilename ;             MZ_ZipAddMem()
                                   , Compression=-1, Callback=0 ) {
 Return DllCall( "MiniZIP\ZIP_MemAdd"
                                    , UInt, zipHandle
                                    , UInt, memPointer
                                    , UInt, memSize
  , ( A_IsUnicode ? "AStr" : "Str" ), ArchiveFilename
                              , Int , Compression
                              , UInt, Callback
                                    , UInt  )
}


MZ_ZipClose( zipHandle, Comment="Created with MiniZIP.dll" ) { ;             MZ_ZipClose()
 Return DllCall( "MiniZIP\ZIP_FileClose"
                                         , UInt, ZipHandle
             , ( A_IsUnicode ? "AStr" : "Str" ), Comment
                                               , UInt )
}


MZ_ZipIsValid( zipFilename ) {                                ;           MZ_ZipIsValid(()
 IfNotExist, %zipfileName%, Return 3
 Return DllCall( "MiniZIP\ZIP_IsZipArchive"
             , ( A_IsUnicode ? "AStr" : "Str" ), ZipFilename, UInt )
} ;  Return Values:   0 = OK,  1 = NOT_ARCHIVE,  2 = ERROR_IN_ARCHIVE,  3 = FILE_NOT_FOUND


MZ_ZipGetFileCount( zipFilename ) {                           ;       MZ_ZipGetFileCount()
 IfNotExist, %zipfileName%, Return
 Return DllCall( "MiniZIP\ZIP_GetFilesCount"
             , ( A_IsUnicode ? "AStr" : "Str" ), zipFilename
                                               , UInt )
}


MZ_ZipGetFileNumber( zipFileName, ArchiveFilename ) {         ;      MZ_ZipGetFileNumber()
 IfNotExist, %zipfileName%, Return
 Return DllCall( "MiniZIP\ZIP_GetFileNumber"
             , ( A_IsUnicode ? "AStr" : "Str" ), zipFilename
             , ( A_IsUnicode ? "AStr" : "Str" ), ArchiveFilename
                                               , UInt )
}


MZ_ZipIsPasswordRequired( zipFilename, zipFileNumber ) {      ; MZ_ZipIsPasswordRequired()
 IfNotExist, %zipfileName%, Return
 Return DllCall( "MiniZIP\ZIP_IsPasswordRequired"
             , ( A_IsUnicode ? "AStr" : "Str" ), zipFilename
                                         , UInt, zipFileNumber, UInt )
}


MZ_ZipGetFilename( zipFilename, zipFileNumber=1               ;        MZ_ZipGetFilename()
                              , ByRef FILEINFO="" ) {
 IfNotExist, %zipfileName%, Return
 VarSetCapacity( FILEINFO, 310, 0 )
 Return DllCall( "MiniZIP\ZIP_GetFileInfo"
             , ( A_IsUnicode ? "AStr" : "Str" ), zipFilename
                                         , UInt, zipFileNumber
                                         , UInt, &FILEINFO
                                               , ( A_IsUnicode ? "AStr" : "Str" ) )
}


MZ_ZipGetComment( zipFilename ) {                             ;         MZ_ZipGetComment()
 IfNotExist, %zipfileName%, Return
 Return DllCall( "MiniZIP\ZIP_GetFileComment"
             , ( A_IsUnicode ? "AStr" : "Str" ), zipFilename
                                               , ( A_IsUnicode ? "AStr" : "Str" ) )
}


MZ_UnzipAll( zipFilename, TargetPath, CreateTargetPath=1      ;              MZ_UnzipAll()
                                    , Callback=0 ) {
 IfNotExist, %zipfileName%, Return
 Return DllCall("MiniZIP\ZIP_ExtractArchiv"
             , ( A_IsUnicode ? "AStr" : "Str" ), zipFilename
             , ( A_IsUnicode ? "AStr" : "Str" ), TargetPath
                                         , UInt, CreateTargetPath
                                         , UInt, Callback
                                               , UInt )
}


MZ_UnzipFileToDisk( zipFilename, zipFileNumber, TargetPath    ;       MZ_UnzipFileToDisk()
                               , CreateTargetPath=1, Callback=0 ) {
 IfNotExist, %zipfileName%, Return
 Return DllCall("MiniZIP\ZIP_ExtractFile"
             , ( A_IsUnicode ? "AStr" : "Str" ), zipFilename
                                         , UInt, zipFileNumber
             , ( A_IsUnicode ? "AStr" : "Str" ), TargetPath
                                         , UInt, CreateTargetPath
                                         , UInt, Callback
                                               , UInt )
}


MZ_UnzipFileToMem( zipFilename, zipFileNumber=1               ;        MZ_UnzipFileToMem()
                              , Callback=0 ) {
 IfNotExist, %zipfileName%, Return ErrorLevel := 0
 Return hGlobal := DllCall( "MiniZIP\ZIP_CatchFile"
                        , ( A_IsUnicode ? "AStr" : "Str" ), zipFilename
                                                          , UInt, zipFileNumber
                                                          , UInt )
      , ErrorLevel := DllCall( "GlobalSize", UInt,hGlobal, UInt )
}


MZ_MemPack( memPointer, memSize, Compression=9 ) {            ;               MZ_MemPack()
 Return hGlobal := DllCall( "MiniZIP\ZIP_PackMemory"
                                                , UInt, memPointer
                                                , UInt, memSize
                                                , Int , Compression
                                                      , UInt )
   , ErrorLevel := DllCall( "GlobalSize", UInt,hGlobal, UInt )
}


MZ_MemUnpack( memPointerSource, memPointerTarget ) {          ;             MZ_MemUnpack()
 Return DllCall( "MiniZIP\ZIP_UnpackMemory"
                                          , UInt, memPointerSource
                                          , UInt, memPointerTarget
                                          , UInt )
}


;____________________________________________________________   //   End of MiniZIP.ahk //


/*            ____ _  ___      ___             _             _  ___  _
             |_  /| || . \    |  _> ___ ._ _ _| |_ _ _  ___ | || . \<_> _ _
              / / | ||  _/___ | <__/ ._>| ' | | | | '_><_> || || | || || '_>
             /___||_||_| |___|`___/\___.|_|_| |_| |_|  <___||_||___/|_||_|
             ZIP_CentralDir()  - Central Directory Listing for PK-ZIP Files
               http://www.autohotkey.com/community/viewtopic.php?t=88182
               Author: SKAN  ( A.N.Suresh Kumar, arian.suresh@gmail.com )
                      Created: 28-Jun-2012 / LastMod: 28-Jun-2012
*/

ZIP_CentralDir( Zip ) {    ;   by SKAN, www.autohotkey.com/community/viewtopic.php?t=88182
                           ;   CD: 28-Jun-2012 / LM: 28-Jun-2012 / Rev.01

 Static StrGet = "StrGet",  InBufRev
 Static GENERIC_READ = 0x80000000, GENERIC_WRITE = 0x40000000
 Static FILE_SHARE_READ = 0x00000001, FILE_SHARE_WRITE = 0x00000002
 Static OPEN_EXISTING = 3, CREATE_NEW = 1
 Static FILE_BEGIN = 0, FILE_CURRENT = 1, FILE_END = 2

 ;  [color=#BF0000]InBufRev()  -  Machine code binary buffer searching regardless of NULL - By wOxxOm[/color]
 ;  See Topic   :  www.autohotkey.com/community/viewtopic.php?t=25925
 ;                 Machine code was adapted below with the kind permission from author

 If ! VarSetCapacity( InBufRev ) {
   FiH := "530CEC83E58955|5D8B9C57565251|DE8E0F00FB8314|4810458B000000|0FFFF983184D8B|C84"
   . "C0FC839C844|8E0F41CF89D929|087D03000000C1|FC00E0830C758B|2A744B22744BAC|4B43744B357"
   . "44B|F2FD93AD934E75|0000009B850FAE|81E9F375025F39|0FAEF2FD000000|76EB0000008885|7F75"
   . "AEF2268AFD|68EBF775026738|AEF2FD93AD6693|75025F39666F75|F2FDAD4E57EBF6|750147396075"
   . "AE|89AD434E49EBF7|02EBC1DA89FC75|8903E283F45D89|FDD187DF87F855|75AEF2CA87FB87|FCF77"
   . "501473938|05C783CA89FB89|85F44D8BFC758B|DC75A7F30474C9|0474C985F84D8B|47DF89D175A6F"
   . "3|5F9D08452BF889|14C2C95B595A5E|F0EBD0F7C03100|", VarSetCapacity( InBufRev, 252, 0 )
   Loop, Parse, FiH, |
     NumPut( "0x" A_LoopField,  InBufRev, ( 7 * ( A_Index-1 ) ),  "Int64" )
   VarSetCapacity( FiH, 0 )
 }

 IfNotExist, %Zip%, Return "", ErrorLevel := 1


 hFil := DllCall( "CreateFile", Str, Zip, UInt,GENERIC_READ, UInt,FILE_SHARE_READ, Int,0
                              , UInt,OPEN_EXISTING, Int, 0, Int,0 )

 IfLess, hFil, 0, Return "",   ErrorLevel := 2

 ; Read into Buffer '65557 tail bytes' or 'the complete file', whichever is lesser
 
 FilSz := DllCall( "SetFilePointer", UInt,hFil, Int,0, Int,0, UInt,FILE_END, UInt )
 VarSetCapacity( Buf, BufSz := ( FilSz <= 65557 ? FilSz : 65557 ), 0 )
 
 fPtr := DllCall( "SetFilePointer", UInt,hFil, Int,0-BufSz, Int,0, UInt,FILE_END, UInt )
 DllCall( "ReadFile", UInt,hFil, UInt,&Buf, UInt,BufSz, UIntP,BR, UInt,0, UInt )

 ; Scan the Buffer for Signature /x50/x4B/x05/x06 ( End of central directory record )
 
 VarSetCapacity( N,4,0 ), NumPut( 0x06054B50,N )
 FoundPos := DllCall( &InBufRev, UInt,&Buf, UInt,&N, UInt,BufSz, UInt,4, Int,-1, Int )

 If ( FoundPos < 0 )
   Return "", DllCall( "CloseHandle", UInt,hFil ), ErrorLevel := 3

 TotalFiles := NumGet( Buf, FoundPos+8, "UShort" )
 SizeOfCD   := NumGet( Buf, FoundPos+12,  "UInt" )
 OffsetToCD := NumGet( Buf, FoundPos+16,  "UInt" )

 ; Central Directory has been located, yet check the validity of signature location.
 ; There is a remote possibility that Signature could be a part of zip comment
 
 If ( FoundPos + fPtr <> OffsetToCD + SizeOfCD )
   Return "", DllCall( "CloseHandle", UInt,hFil ), ErrorLevel := 3

 ; Move File pointer to 'Central Directory' and parse 'File Headers' one at a time
 
 DllCall( "SetFilePointer", UInt,hFil, UInt,OffsetToCD, Int,0, UInt,FILE_BEGIN )
 Sps10 := A_Space A_Space A_Space A_Space A_Space A_Space A_Space A_Space A_Space A_Space
 
 Loop % ( TotalFiles ) {

   ; File Header should be 46 + ExtraBytes. ExtraBytes is unknown, so Read 46 bytes first
   
   DllCall( "ReadFile", UInt,hFil, UInt,&Buf, UInt,46, UIntP,BR, UInt,0, UInt )

   FileNameLen    := NumGet( Buf, 28, "UShort" )
   ExtraFieldLen  := NumGet( Buf, 30, "UShort" )
   FileCommentLen := NumGet( Buf, 32, "UShort" )

   ExtraBytes := FileNameLen + ExtraFieldLen + FileCommentLen
   
   ; Extra Bytes has been determined, so lets append it to Buffer.
   
   DllCall( "ReadFile", UInt,hFil, UInt,&Buf+46, UInt,ExtraBytes, UIntP,BR, UInt,0 )
   
   ; The complete header is available. Gathering Information...

   ; Extract DOS Date & Time
   
   DosTime := NumGet( Buf,12, "UShort" )
   DosDate := NumGet( Buf,14, "UShort" )

   VarSetCapacity( T$,24,0 )
   DllCall( "DosDateTimeToFileTime", UShort,DosDate, UShort,DosTime, Uint,&T$+16 )
   DllCall( "FileTimeToSystemTime" , UInt,&T$+16, UInt,&T$ )

   DT_LastMod := NumGet( T$, 0,"Short" )       . SubStr( "0" NumGet( T$, 2,"Short" ), -1 )
   . SubStr( "0" NumGet( T$, 6,"Short" ), -1 ) . SubStr( "0" NumGet( T$, 8,"Short" ), -1 )
   . SubStr( "0" NumGet( T$,10,"Short" ), -1 ) . SubStr( "0" NumGet( T$,12,"Short" ), -1 )

   ; Extract File Attibutes

   nAttr := NumGet( Buf, 38, "UInt" )

   FileAttr := ( nAttr & 0x01  ? "R" : "" )    ;   FILE_ATTRIBUTE_READONLY
            .  ( nAttr & 0x20  ? "A" : "" )    ;   FILE_ATTRIBUTE_ARCHIVE
            .  ( nAttr & 0x04  ? "S" : "" )    ;   FILE_ATTRIBUTE_SYSTEM
            .  ( nAttr & 0x02  ? "H" : "" )    ;   FILE_ATTRIBUTE_HIDDEN
            .  ( nAttr & 0x10  ? "D" : "" )    ;   FILE_ATTRIBUTE_DIRECTORY

   ; Determine compression method
   
   nComp := NumGet( Buf, 10, "UShort" )

   FileComp := ( nComp =  0 ) ? "Store     "   ;   No Compression
            :  ( nComp =  1 ) ? "Shrunk    "
            :  ( nComp =  2 ) ? "Reduce CF1"   ;   Reduced with compression factor 1
            :  ( nComp =  3 ) ? "Reduce CF2"   ;   Reduced with compression factor 2
            :  ( nComp =  4 ) ? "Reduce CF3"   ;   Reduced with compression factor 3
            :  ( nComp =  5 ) ? "Reduce CF4"   ;   Reduced with compression factor 4
            :  ( nComp =  6 ) ? "Implode   "
            :  ( nComp =  8 ) ? "Deflate   "   ;   The common method
            :  ( nComp =  9 ) ? "E.Deflate "   ;   Enhanced Deflate
            :  ( nComp = 10 ) ? "PKW DCL Im"   ;   PKWare DCL imploded
            :  ( nComp = 12 ) ? "BZIP2     "
            :  ( nComp = 14 ) ? "LZMA      "
            :  ( nComp = 18 ) ? "IBM Terse "
            :  ( nComp = 19 ) ? "IBM LZ777z"   ;   IBM LZ77 z
            :  ( nComp = 19 ) ? "PPMd vI.1 "   ;   PPMd version I, Rev 1
            :                   "Unknown   "   ;   Reserved/Newer
            
   ; Extract Filename

   If A_IsUnicode
      FileName := %StrGet%( &Buf+46, FileNameLen, ""  )
   Else
      VarSetCapacity( FileName, FileNameLen, 0 )
    , DllCall( "lstrcpynA", Str,FileName, UInt,&Buf+46, UInt,FileNameLen + 1 )


   ; Append the gathered information to List
   
   List .= SubStr( A_Index Sps10 , 1, 5 )        .  A_Tab ; File Index
        .  SubStr( NumGet(Buf,42) Sps10, 1, 10 ) .  A_Tab ; Data Offset
        .  SubStr( NumGet(Buf,20) Sps10, 1, 10 ) .  A_Tab ; Data Size
        .  SubStr( NumGet(Buf,24) Sps10, 1, 10 ) .  A_Tab ; Data Size Original
        .  DT_LastMod                            .  A_Tab ; File Date (Last Modified)
        .  SubStr( FileAttr Sps10, 1, 5 )        .  A_Tab ; File Attributes
        .  FileComp                              .  A_Tab ; Compression Method
        .  FileName                              .  "`n"  ; Filepath/Name
   
  Continue ; Repeat the Loop
  
 }

 StringTrimRight, List, List, 1
 DllCall( "CloseHandle", UInt,hFil )
Return List, ErrorLevel := TotalFiles
}