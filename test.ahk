; ddd
#NoEnv
SetBatchLines, -1
#SingleInstance, Force
CoordMode, Mouse, Screen

#Include KWARK.ahk


testArray := [ 1 , 2 , 3 ]
; global neutron
; neutron := new NeutronWindow()
neutron := new KWARK()
neutron.LoadView("base",,{Title:"TestWindow", Variable:"<button onclick=""ahk.Clicked(event)"">Click Me!</button>", Variable2:"<button onclick=""ahk.Clicked(event)"">Click Me2!</button>"})
neutron.Gui("+LabelNeutron")

sectionhtml := ""
For content in testArray {
    sectionhtml .= "<p>" . content . "</p>"
}
neutron.LoadHTML(sectionhtml, "section1")
; CreateSection( neutron, sectionhtml)

neutron.Show("w640 h480")


Return
NeutronClose:
ExitApp
return

Clicked(neutron, event)
{
	; event.target will contain the HTML Element that fired the event.
	; Show a message box with its inner text.
	MsgBox, % "You clicked: " event.target.innerText
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

DynamicContent()
{
	; This function isn't called by Neutron, so we'll have to grab the global
	; Neutron window variable instead of using one from a Neutron event.
	global neutron
	
	; Get the mouse position
	MouseGetPos, x, y
	
	; Update the page with the new position
	neutron.doc.getElementById("ahk_x").innerText := x
	neutron.doc.getElementById("ahk_y").innerText := y
}

CreateSection(neutron, html){
    
    neutron.doc.getElementById("main").append(html)
}
