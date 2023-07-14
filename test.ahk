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
; global neutron
; neutron := new NeutronWindow()
neutron := new KWARK()
neutron.LoadView("base",,{Title:"TestWindow", Variable:"<button name='TestDVars' class='test test2' onclick=""ahk.Clicked(event)"">Click Me!</button>", Variable2:"<span id='dynavar1'>" . dynavar1 . "</span><span id='dynavar2'>" . dynavar2 . "</span>"})
neutron.Gui("+LabelNeutron")
neutron.AddDynaVar("dynavar1", "dynavar2")
sectionhtml := ""
For content in testArray {
    sectionhtml .= "<p>" . content . "</p>"
}
neutron.LoadHTML(sectionhtml, "section1")
; CreateSection( neutron, sectionhtml)

neutron.Show("w640 h480")
testbind := ObjBindMethod(neutron, "UpdateDynaVars")
; testbind := Func("DynamicContent").Bind("dynavar1")
testbind2 := "TestDVars"
SetTimer, % testbind, 100
; SetTimer, % testbind2, 300

Return
NeutronClose:
ExitApp
return

^!d::
dynavar1 += 1
MsgBox, % "dynavar1: " dynavar1
Return

TestDVars:

	dynavar1 += 1
	dynavar2 .= "!"
Return

Clicked(neutron, event)
{
	
	; MsgBox, % "dynavar1: " dynavar1
	; event.target will contain the HTML Element that fired the event.
	; Show a message box with its inner text.
	; MsgBox, % "You clicked: " event.target.className
	; MsgBox, % "You clicked: " event.target.name
	; dynavar1 += 1
	; dynavar2 += 2
	Gosub, % event.target.name
	; MsgBox, % "dynavar1: " dynavar1
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

DynamicContent( id)
{
	; static prevVal
	; This function isn't called by Neutron, so we'll have to grab the global
	; Neutron window variable instead of using one from a Neutron event.
	global neutron
	; MsgBox % id . ": " . %id%
	dynaVar := %id%
	; Get the mouse position
	; MouseGetPos, x, y
	; MsgBox % dynaVar
	; Update the page with the new position
	; if(dynaVar != prevVal) {
		; prevVal := dynaVar
		; MsgBox % id . ": " . dynaVar
		neutron.doc.getElementById(id).innerText := dynavar
	; }
	
	; neutron.doc.getElementById("ahk_y").innerText := y
}



CreateSection(neutron, html){
    
    neutron.doc.getElementById("main").append(html)
}
