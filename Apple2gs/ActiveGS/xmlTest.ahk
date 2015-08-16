src =
(
<Catalog>
    <CUnit default="1" id="Alex">
        <Name value="Alex Lamb"/>
        <Description value="Person"/>
        <Radius value="3"/>
        <LifeStart value="40"/>
    </CUnit>
    <CUnit default="1" id="Chris">
        <Name value="Chris Brown"/>
        <Description value="Person"/>
        <Radius value="5"/>
        <LifeStart value="30"/>
	</CUnit>
    <CUnit default="1" id="Bender">
        <Name value="bender rodriguez"/>
        <Description value="Robot"/>
        <Radius value="7"/>
        <LifeStart value="60"/>
	</CUnit>
</Catalog>
)

msgbox % src

x := new XML(src)

units := []
Loop, % (CUnit:=x.selectNodes("//CUnit")).length {
		k := CUnit.item((i:=A_Index)-1)
		e := []
		Loop, % (elem:=k.selectNodes("*")).length {
			a := elem.item(A_Index-1)
			if ((nn:=a.nodeName) = "Radius")
				continue
			e[nn . " value"] := a.getAttribute("value")
		}
	units[i] := e
}

for k, v in units
	for a, b in v
		MsgBox, % a " = " b
return