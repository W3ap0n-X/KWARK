; ddd
#NoEnv
SetBatchLines, -1
#SingleInstance, Force
CoordMode, Mouse, Screen

#Include KWARK.ahk
Gosub, TestWindow2
Return
; IniRead, ValidatorRegex, regex.ini, patterns, templateString 
; MsgBox % ValidatorRegex

; IniRead, ValidatorRegex, regex.ini, patterns, view 
; MsgBox % ValidatorRegex

; IniRead, ValidatorRegex, regex.ini, patterns, function 
; MsgBox % ValidatorRegex

; IniRead, ValidatorRegex, regex.ini, patterns, variable 
; MsgBox % ValidatorRegex

; IniRead, ValidatorRegex, regex.ini, patterns, string 
; MsgBox % ValidatorRegex
TestWindow2:
dynavar1 := 0
dynavar2 := "text"
testArray := [ "One" , "Two" , "Three" ]
kwark2 := new KWARK()
kwark2.LoadTemplate("Views/base.html", "Autohotkey HTML Window")
kwark2.LoadView("Views/tabview")
kwark2.LoadView("Views/testView","v-pills-dynavar",{id:"testdynamic",Title:"TestWindow", Variable:"<button class='btn btn-primary' name='TestDVars' class='test test2' onclick=""ahk.Clicked(event)"">Click Me!</button>", Variable2:"<span class='badge badge-success' id='dynavar1'>" . dynavar1 . "</span>", Variable3:"<span id='dynavar2'>" . dynavar2 . "</span>"})
kwark2.Gui("+LabelNeutron")
kwark2.AddDynaVar("dynavar1", "dynavar2", "timeReader")
sectionhtml := ""
For index, content in testArray {
    sectionhtml .= "<tr><td>" . index . "</td><td>" . content . "</td></tr>"
}
kwark2.LoadHTML(sectionhtml, "section1")
kwark2.Show("w840 h680")
testbind2 := ObjBindMethod(kwark2, "UpdateDynaVars")
SetTimer, % testbind2, 100
Return


TestWindow1:
dynavar1 := 0
dynavar2 := "text"
testArray := [ "One" , "Two" , "Three" ]
kwark := new KWARK()
kwark.LoadTemplate("Views/base.html", "Autohotkey HTML Window")
kwark.LoadView("Views/testView",,{id:"testdynamic",Title:"TestWindow", Variable:"<button class='btn btn-primary' name='TestDVars' class='test test2' onclick=""ahk.Clicked(event)"">Click Me!</button>", Variable2:"<span class='badge badge-success' id='dynavar1'>" . dynavar1 . "</span>", Variable3:"<span id='dynavar2'>" . dynavar2 . "</span>"})
kwark.Gui("+LabelNeutron")
kwark.AddDynaVar("dynavar1", "dynavar2", "timeReader")
sectionhtml := ""
For index, content in testArray {
    sectionhtml .= "<tr><td>" . index . "</td><td>" . content . "</td></tr>"
}
kwark.LoadHTML(sectionhtml, "section1")

kwark.Show("w840 h680")
testbind := ObjBindMethod(kwark, "UpdateDynaVars")
SetTimer, % testbind, 100
Return

NeutronClose:
	ExitApp
return

ReloadScript:
	Reload
Return

TestDVars:
	dynavar1 += 1
	dynavar2 .= "!"
Return

timeReaderUpdate:
	timeReader := A_Hour . ":" . A_Min . ":" . A_Sec
Return

Clicked(neutron, event)
{
	If (Label := event.target.name){
		Gosub, % Label
	}
}

ClickedArrayThing(neutron, event, value) {
	global testArray
	testArray.Push(value)
	If (Label := event.target.name){
		Gosub, % Label
	}
	sectionhtml := ""
	For index, content in testArray {
		sectionhtml .= "<tr><td>" . index . "</td><td>" . content . "</td></tr>"
	}
	neutron.LoadHTML(sectionhtml, "section1")
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
