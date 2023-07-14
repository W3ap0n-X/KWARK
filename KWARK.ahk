#Include %A_LineFile%\..
#include Neutron.ahk
#include %A_ScriptDir%
class KWARK Extends NeutronWindow {
    static TEMPLATE := "
( ; html
<!DOCTYPE html><html>
<head>

<meta http-equiv='X-UA-Compatible' content='IE=edge'>
<style>
	html, body {
		width: 100%; height: 100%;
		margin: 0; padding: 0;
		font-family: sans-serif;
	}

	body {
		display: flex;
		flex-direction: column;
	}

	header {
		width: 100%;
		display: flex;
		background: silver;
		font-family: Segoe UI;
		font-size: 9pt;
	}

	.title-bar {
		padding: 0.35em 0.5em;
		flex-grow: 1;
	}

	.title-btn {
		padding: 0.35em 1.0em;
		cursor: pointer;
		vertical-align: bottom;
		font-family: Webdings;
		font-size: 11pt;
	}

	.title-btn:hover {
		background: rgba(0, 0, 0, .2);
	}

	.title-btn-close:hover {
		background: #dc3545;
	}

	.main {
		flex-grow: 1;
		padding: 0.5em;
		overflow: auto;
	}
</style>
<style>{}</style>

</head>
<body>

<header>
	<span class='title-bar' onmousedown='neutron.DragTitleBar()'>{}</span>
	<span class='title-btn' onclick='neutron.Minimize()'>0</span>
	<span class='title-btn' onclick='neutron.Maximize()'>1</span>
	<span class='title-btn title-btn-close' onclick='neutron.Close()'>r</span>
</header>

<div class='main' id='main' name='main'>{}</div>

<script>{}</script>

</body>
</html>
)"

	__New(html:="", css:="", js:="", title:="KWARK") {
		This.CreateWindow(html, css, js, title)
	}

    LoadView(fileName, toSection:="main", Vars := false)
	{

		fileName := A_WorkingDir "/" fileName . ".html"
		FileRead, section, %fileName%
        
        section := This.ParseTemplate(section , Vars)
		This.doc.getElementById(toSection).innerHtml := section
	}

    LoadHTML(html, toSection:="main")
	{
		This.doc.getElementById(toSection).innerHtml := html
	}

    ParseTemplate(template, Vars := false) {
        Loop
        {
            ; MsgBox % template
            if (RegExMatch(template, "{{[^\}]*}}")){
                ; MsgBox % "BEFORE`n`n" . template
                template := This.ParsePart(template, Vars)
                ; MsgBox % "AFTER`n`n" . template
            
            } Else {
                break
            }
        }
        return template
    }

    ParsePart(template, Vars := false){
        ; FoundPos := RegExMatch("Michiganroad 72", "O)(.*) (?<nr>\d+)", SubPat)  ; The starting "O)" turns SubPat into an object.
        ; Msgbox % SubPat.Count() ": " SubPat.Value(1) " " SubPat.Name(2) "=" SubPat["nr"]  ; Displays "2: Michiganroad nr=72"
        Match := RegExMatch(template, "Om)({{(.*?)}})", templateStrings)
        if(RegExMatch(templateStrings.Value(2), "Om)(\$(\w+))", templateVar)){
            varName := templateVar.Value(2)
            return RegExReplace(template, "\Q" . templateStrings.Value(1) . "\E", Vars[varName] ? Vars[varName] : %varName% )
            
        } else {
            return RegExReplace(template, templateStrings.Value(1) , templateStrings.Value(2))
        }
        
    }
}