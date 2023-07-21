#NoEnv
SetBatchLines, -1
#SingleInstance, Force
CoordMode, Mouse, Screen

#Include KWARK.ahk
Gosub, TestWindow2
Return

TestWindow2:
dynavar1 := 0
dynavar2 := "text"

timeReader := Func("ClockVar")

dynaVar3 := [ "One" , "Two" , "Three" ]

kwark := new KWARK()

dv3Viewr := Func("ArrayV").Bind(kwark, "dv3Viewr", dynaVar3)

kwark.AddDynaVar("dynavar1" , "dynavar2", "dynavar3" , "timeReader")
kwark.AddBoundFunc("dv3Viewr")

kwark.LoadTemplate("Views/base.html", "Autohotkey HTML Window")
kwark.LoadView("Views/tabview")
kwark.LoadView("Views/testView","v-pills-dynavar",{id:"testdynamic",Title:"TestWindow", Variable:"<button class='btn btn-primary' data-label='TestDVars' class='test test2' onclick=""neutron.Button(event)"">Click Me!</button>", Variable2:"<span class='badge badge-secondary' id='dynavar1'>" . dynavar1 . "</span>", Variable3:"<span id='dynavar2'>" . dynavar2 . "</span>"})
kwark.Gui("+LabelKWARK_")

kwark.Show("w840 h680")


blankwindow := new KWARK()
blankwindow.Show("w840 h680")
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

ClockVar(prefix := "") {
	return % prefix . A_Hour . ":" . A_Min . ":" . A_Sec
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
