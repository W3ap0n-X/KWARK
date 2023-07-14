; ddd
#NoEnv
SetBatchLines, -1
#SingleInstance, Force
CoordMode, Mouse, Screen

#Include KWARK.ahk

; global dynavar
dynavar1 := 0

; global dynavar2
dynavar2 := "text"




testArray := [ 1 , 2 , 3 ]
neutron := new KWARK()
neutron.LoadTemplate("Views/bsBase.html")
neutron.LoadView("Views/base",,{Title:"TestWindow", Variable:"<button class='btn btn-primary' name='TestDVars' class='test test2' onclick=""ahk.Clicked(event)"">Click Me!</button>", Variable2:"<span class='badge' id='dynavar1'>" . dynavar1 . "</span><span id='dynavar2'>" . dynavar2 . "</span>"})
neutron.Gui("+LabelNeutron")
neutron.AddDynaVar("dynavar1", "dynavar2", "timeReader")
sectionhtml := ""
For content in testArray {
    sectionhtml .= "<p>" . content . "</p>"
}
neutron.LoadHTML(sectionhtml, "section1")
neutron.AppendHTML(sectionhtml, "section1")

neutron.AppendView("Views/base" ,, {Title:"TestAppend"})
; CreateSection( neutron, sectionhtml)

neutron.Show("w640 h480")
testbind := ObjBindMethod(neutron, "UpdateDynaVars")
; testbind := Func("DynamicContent").Bind("dynavar1")
SetTimer, % testbind, 100
; SetTimer, % testbind2, 300

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
	Gosub, % event.target.name
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
