#NoEnv
SetBatchLines, -1
#SingleInstance, Force
CoordMode, Mouse, Screen

#Include KWARK.ahk

ckval := 0

global A_SelfPID := DllCall("GetCurrentProcessId")
Gosub, TestWindow2
Return

TestWindow2:


demo := new KWARK()

dynavar1 := 0
dynavar2 := "text"
timeReader := Func("ClockVar")
script_ram := Func("ScriptRam")
cluePage := Func("Clue_Form")
dynaVar3 := [ "Revolver" , "Dagger" , "Lead Pipe" , "Candlestick" , "Wrench", "Kindness", "Ford F150", "Cheese Whiz" ]
Who_dunnit := [ "Mrs Peacock" , "Colonel Mustard" , "Reverend Green", "Professor Plum" , "Miss Scarlet", "Mrs White" , "Ms Frizzle", "Pilsbury Dough Boy"]
Where_at := ["Bathroom","Study","Dining Room","Game Room","Garage","Bedroom","Living Room","Kitchen","Courtyard","Cum Dungeon","Gamer Cave"]
Fields := ["Who" , "Where", "Weapon"]
dv3Viewr := Func("ArrayV").Bind(demo, "dv3Viewr", dynaVar3)


itWas_Who := ""
itWas_Where := ""
itWas_Weapon := ""
global itWas_Who, itWas_Where, itWas_Weapon



demo.AddDynaVar("dynavar1" , "dynavar2", "dynavar3" , "timeReader", "cluePage", "script_ram")
demo.AddBoundFunc("dv3Viewr")


demo.LoadTemplate("Views/base.html", "KWARK")

demo.LoadView("Views/tabview")

demo.LoadView("Views/testView","v-pills-dynavar",{id:"testdynamic",Title:"TestWindow", Variable:"<button class='btn btn-primary' data-label='TestDVars' class='test test2' onclick=""neutron.Button(event)"">Click Me!</button>", Variable2:"<span class='badge badge-secondary' id='dynavar1'>" . dynavar1 . "</span>", Variable3:"<span id='dynavar2'>" . dynavar2 . "</span>"})

demo.Show("w840 h680")


Return

TestBreak:
	ckval += 1
	tbreak_ms := 5000
	MsgBox % ckval . ":		Hit ok when ready"
	Sleep, % tbreak_ms
Return

TestWindow1:
	demo2 := new NeutronWindowX()
	demo2.Show("w840 h680")
	demo2.PollingStop()
Return

MemTT:
	TT(ScriptRam(), "ScriptRam")
Return

NeutronClose:
KWARK_Close:
	ExitApp
return

ReloadScript:
	Reload
Return

TestDVars:
	dynavar1 += 1
	dynavar2 .= "!"
Return

ScriptRam() {
	
	Return % GetProcessMemoryUsage(A_SelfPID) " MB"
}

Clue_Form(){
	global
	newFormHtml := "<form onsubmit='ahk.Submit(event)'>"
	For k , field in Fields {
		newFormHtml .= "`n<label class='my-1 mr-2' for='clue" . Field . "'>" . Field . "?</label><select class='custom-select my-1 mr-sm-2' id='clue" . Field . "'><option selected>Choose...</option>"
		if (k == 1) {
			For list_k ,list_v in Who_dunnit {
				newFormHtml .= "<option value='" . list_v . "'>" . list_v . "</option>"
			}
		} Else If (k == 2) {
			For list_k ,list_v in Where_at {
				newFormHtml .= "<option value='" . list_v . "'>" . list_v . "</option>"
			}
		} Else If (k == 3) {
			For list_k ,list_v in dynaVar3 {
				newFormHtml .= "<option value='" . list_v . "'>" . list_v . "</option>"
			}
		} 
		newFormHtml .= "</select>"
	}
	newFormHtml .= "<button type='submit' class='btn btn-primary my-1'>Submit</button></form>"
	; demo.LoadHTML(newFormHtml, "Clue_Form")
	Return % newFormHtml
}

ClockVar(prefix := "") {
	return % prefix . A_Hour . ":" . A_Min . ":" . A_Sec . ":" . A_MSec
}

ArrayV(neutron, table, array){
	sectionhtml := ""
	For index, content in array {
		sectionhtml .= "<tr><td>" . index . "</td><td>" . content . "</td></tr>"
	}
	return sectionhtml
}

ArrayViewer(neutron, array, value) {
	array := %array%
	array.Push(value)
}

Submitted(neutron, event)
{
	; Some events have a default action that needs to be prevented. A form will
	; redirect the page by default, but we want to handle the form data ourself.
	event.preventDefault()
	
	; Dismiss the GUI
	neutron.hide()
	
	; Use the GetFormData helper to get an associative array of the form data
	formData := neutron.GetFormData(event.target)
	MsgBox, % "Hello " formData.firstName " " formData.lastName "!"
	
	; Re-show the GUI
	neutron.Show()
}

Submit(neutron, event)
{
	event.preventDefault()
	formData := neutron.GetFormData(event.target)
	out := "User Data::`n"
	for name, value in formData
		out .= name ": " value "`n"
	out .= "`n"
	; MsgBox % out
	itWas_Who := formData.clueWho == "Choose..." ? "" : formData.clueWho
	itWas_Where := formData.clueWhere == "Choose..." ? "" :  formData.clueWhere
	itWas_Weapon := formData.clueWeapon == "Choose..." ? "" : formData.clueWeapon 
}

:*:..accuse::
	msg := ""
	If (!itWas_Who) {
		msg := "I don't think it was anybody..."
	} Else {
		msg := "I think it was " . itWas_Who . ", in the " . itWas_Where . " with the " . itWas_Weapon . "!"
	}
	Send, % msg
Return

GetProcessMemoryUsage(ProcessID)
{
	static PMC_EX, size := NumPut(VarSetCapacity(PMC_EX, 8 + A_PtrSize * 9, 0), PMC_EX, "uint")

	if (hProcess := DllCall("OpenProcess", "uint", 0x1000, "int", 0, "uint", ProcessID)) {
		if !(DllCall("GetProcessMemoryInfo", "ptr", hProcess, "ptr", &PMC_EX, "uint", size))
			if !(DllCall("psapi\GetProcessMemoryInfo", "ptr", hProcess, "ptr", &PMC_EX, "uint", size))
				return (ErrorLevel := 2) & 0, DllCall("CloseHandle", "ptr", hProcess)
		DllCall("CloseHandle", "ptr", hProcess)
		return Round(NumGet(PMC_EX, 8 + A_PtrSize * 8, "uptr") / 1024**2, 2)
	}
	return (ErrorLevel := 1) & 0
}

TT(Text := "" , Title := "" , Timeout := 5000){
	if (FancyAssToolTipZ) {
		FancyAssToolTipZ.A(Text , Title , Timeout)
	} Else {
		NK_TT( ( !Title ? : Title . ": " ) . Text , Timeout)
	}
}

NK_TT(msg:="", timeout:=3000){
	ToolTip 
	ToolTip % msg
	SetTimer, NK_TT-Kill, %timeout%
    return

    NK_TT-Kill:
		SetTimer, NK_TT-Kill, Off
		ToolTip
    return
}