;#NoEnv
/*

;TestCode

#Include Common.ahk
#Include FileUtil.ahk
#Include Tray.ahk

imageFilePath := "\\NAS\emul\image\PC9801\0_imagesFdi\Ys 2 (1988)(Nihon Falcom)(T-Kr)\Ys 2 - Ancient Ys Vanished - The Final Chapter disk 1 (19xx)(Falcom).D88"

fddContainer  := new DiskContainer( imageFilePath, "i).*\.(d88|fdi)" )

msgbox % fddContainer.size()

msgbox % fddContainer.toString()

msgbox % fddContainer.toOption()

return

^+PGUP:: ; Drive#1 Disk Change
    fddContainer.insertDisk( "1", "setDisk" )
    ;Tray.show( "Disk 1", fddContainer.toString(), 10000 )
	return

^+PGDN:: ; Drive#2 Disk Change
	fddContainer.insertDisk( "2", "setDisk" )
    ;Tray.show( "Disk 2", fddContainer.toString(), 10000 )
	return

^F3::
    msgbox Close !!
    ExitApp

^+Del:: ; Cancel Disk Change	
	fddContainer.cancel()
	return

setDisk( slotNo, file ) {
    IfNotExist % file 
        return
    msgbox % "disk[" file "] is inserted in [" slotNo "]"
    
}
*/


class DiskContainer {

    static slot := []

    container   := []
   
    __New( path, pattern=".*" ) {
        this.container := FileUtil.getFiles( path, pattern )
    }

    size() {
        return this.container.MaxIndex()
    }
    
    toString() {
        
        returnVal := ""

        returnVal := % returnVal ">> In Slot`n"
        For slotNo, slot in DiskContainer.slot
            returnVal := % returnVal "  - slot:" slotNo ", file: """ slot.fileInserted "`n"


		returnVal := % returnVal ">> In Container`n"
        Loop % this.container.MaxIndex()
        {
            returnVal := % returnVal "  - index:" A_Index ", file : """ this.container[A_Index] "`n"
        }
        
        return returnVal
        
    }
    
    toOption( limitCount=999, prefix="", postfix="" ) {
        
        returnVal := ""
        
        Loop % this.size()
        {
            if( A_Index > limitCount )
                break

            returnVal := % returnVal prefix " """ this.container[A_Index] """" postfix
        }
        
        return returnVal
        
    }

    insertDisk( slotNo, functionName, duration=1000 ) {

        file := ""
        
        ; Select file
        Loop % this.size()
        {
            
            file := this.container[ 1 ]

            swapDisk := this.container[ 1 ]
            this.container.Remove( 1 )
            this.container.Insert( swapDisk )

            if( file != DiskContainer.slot[ slotNo ].fileInserted )
                break
                
        }

        If ( file == "" )
            return false

        SetTimer, Timer_DiskContainer_insertDisk_RunFunction, off

        ;Tray.show( "Compare", file "`n == " DiskContainer.slot[ slotNo ].fileInserted "`n ==" this.toString(), 10000 )

        ; Set Slot
        if( DiskContainer.slot[ slotNo ] == null )
            DiskContainer.slot[ slotNo ] := {}

        DiskContainer.slot[ slotNo ].file         := file
        DiskContainer.slot[ slotNo ].functionName := functionName


        ; Show Status
        Tray.show( "Insert Disk in Drive " slotNo, FileUtil.getFileName(file) )

		SetTimer, Timer_DiskContainer_insertDisk_RunFunction, -%duration%
		return

		Timer_DiskContainer_insertDisk_RunFunction:

            For slotNo, slot in DiskContainer.slot
            {
                if( slot.file == "" )
                    continue

                Func( slot.functionName ).( slotNo, slot.file )

                slot.fileInserted := slot.file
                slot.file         := ""
                slot.functionName := ""

            }
            
			return


    }
    
    removeDisk( slotNo, functionName ) {

        Tray.show( "Remove disk in Drive " slotNo, "" )
        slot := DiskContainer.slot[ slotNo ]
        Func( functionName ).( slotNo, slot.file )
        slot.fileInserted := ""
        slot.file         := ""
        slot.functionName := ""        
        
    }
    
    cancel() {
        Tray.show( "Cancel to change disk" )
        For slotNo, slot in DiskContainer.slot
        {
            if( slot.file == "" )
                continue
            
            slot.file         := ""
            slot.functionName := ""

        }
        SetTimer, Timer_DiskContainer_insertDisk_RunFunction, off
    }
    
    setSlot( slotNo, file ) {
        if( DiskContainer.slot[ slotNo ] == null )
            DiskContainer.slot[ slotNo ] := {}
        DiskContainer.slot[ slotNo ].fileInserted := file
    }

    getFileInSlot( slotNo ) {
        return DiskContainer.slot[ slotNo ].fileInserted
    }
    
    getFile( index ) {
        return this.container[ index ]
    }

    initSlot( size ) {

        Loop % this.size()
        {
            if( A_index > size )
                break
            
            this.setSlot( A_Index, this.getFile(A_Index) )
            
        }

    }

}