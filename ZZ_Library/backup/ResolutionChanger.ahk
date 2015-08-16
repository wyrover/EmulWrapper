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
        VarSetCapacity( dM, 156, 0 )
        NumPut( 156, dM, 36 )
        NumPut( 0x5c0000, dM, 40 )
        NumPut( width, dM, 108 )
        NumPut( height, dM, 112 )
        DllCall( "ChangeDisplaySettingsA", UInt,&dM, UInt,0 )
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
      this.change( this.srcWidth, this.srcHeight )
    }

}