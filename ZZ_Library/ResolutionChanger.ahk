class ResolutionChanger {

    static void := ResolutionChanger._init()

    _init() {
        this.srcWidth  := A_ScreenWidth
        this.srcHeight := A_ScreenHeight
    }
  
    __New() {
        throw Exception( "ResolutionChanger is a static class, dont instante it!", -1 )
    }


    change( width, height ) {
        If ( RegExMatch(width, "^\d+$") == false || RegExMatch(height, "^\d+$") == false ) {
            MsgBox Resolution must be consisted with digit values ( input values : [%width%]x[%height%])
            return
        }        
        Run, % A_ScriptDir "\..\..\ZZ_Library\dc64.exe -width=" width " -height=" height
    }
  
    /*
    change( width, height, colorDepth:=32, Hz:=60 ) {
        VarSetCapacity( dM,156,0 ), NumPut( 156,2,&dM,36 )
        DllCall( "EnumDisplaySettings", UInt,0, UInt,-1, UInt,&dM ), NumPut(0x5c0000,dM,40)
        NumPut(cD,dM,104),  NumPut(sW,dM,108),  NumPut(sH,dM,112),  NumPut(rR,dM,120)
        Return DllCall( "ChangeDisplaySettings", UInt,&dM, UInt,0 )
    }
    */
  
    restore() {
        if ( A_ScreenWidth != this.srcWidth || A_ScreenHeight != this.srcHeight ) {
            this.change( this.srcWidth, this.srcHeight )
        }
    }

}