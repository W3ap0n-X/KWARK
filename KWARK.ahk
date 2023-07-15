#Include %A_LineFile%\..\Neutron.ahk
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

	dynaVars := []
	ViewDir := StrReplace(A_LineFile, "KWARK.ahk" , "") . "Views\"

	__New(html:="", css:="", js:="", title:="KWARK") {
		This.CreateWindow(html, css, js, title)
	}

	LoadTemplate(filename, title:= "" ){
		if(!title){
			title := fileName
		}
		This.Load(filename)
		bodyHtml:= This.doc.body.innerhtml
		bodyHtml := This.ParseTemplate(bodyHtml)
		This.doc.body.innerhtml := bodyHtml
		customcsstest := "<link href='css/custom.css' rel='stylesheet'>"
		headerHtml := This.doc.head.innerhtml
		headerHtml := This.ParseTemplate(headerHtml, {customcsstest: customcsstest})
		This.doc.head.innerhtml := headerHtml
		This.doc.getElementById("title").innerText := title
	}

	AppendView(fileName, toSection:="main", Vars := false){
		fileName := A_WorkingDir "/" fileName . ".html"
		FileRead, section, %fileName%
		section := This.ParseTemplate(section , Vars)
		MsgBox % "Before:" . This.doc.getElementById(toSection).innerHtml
		newcontent := This.doc.getElementById(toSection).innerHtml . section
		This.doc.getElementById(toSection).innerHtml := newcontent
		MsgBox % "After:" . This.doc.getElementById(toSection).innerHtml
	}

    LoadView(fileName, toSection:="main", Vars := false)
	{
		fileName := A_WorkingDir "/" fileName . ".html"
		FileRead, section, %fileName%
        section := This.ParseTemplate(section , Vars)
		This.doc.getElementById(toSection).innerHtml := section
	}

	GetView(fileName, Vars := false)
	{	
		filePath := This.ViewDir . "/" fileName . ".html"
		if (FileExist(filePath)){
			FileRead, view, %filePath%
        	view := This.ParseTemplate(view , Vars)
		} Else {
			view := "{Error: View " . fileName . " 404} "
		}
		return view
	}

	AppendHTML(html, toSection:="main")
	{
		This.doc.getElementById(toSection).innerHtml .= "`n" . html
	}

    LoadHTML(html, toSection:="main")
	{
		This.doc.getElementById(toSection).innerHtml := html
	}

    ParseTemplate(template, Vars := false) {
        Loop
        {
			If (RegExMatch(template, "<\!--(@@|\$).*?-->" )) {
				template := This.ParsePart(template, Vars)
			}
			Else {
                break
            }
        }
        return template
    }

    ParsePart(template, Vars := false){
		if (RegExMatch(template, "Om)(<\!--(@@|\$)(.*?)-->)", templateStrings)) {
			if (templateStrings.Value(2) == "@@") {
				includedTemplate := This.GetView(templateStrings.Value(3), Vars )
				return RegExReplace(template, "\Q" . templateStrings.Value(1) . "\E", includedTemplate , , 1 )
			} else if (templateStrings.Value(2) == "$") {
				varName := templateStrings.Value(3) 
				return RegExReplace(template, "\Q" . templateStrings.Value(1) . "\E", Vars[varName] ? Vars[varName] : %varName% , , 1 )
			}
		}
    }

	AddDynaVar(names*) {
		For id, name in names {
			This.dynaVars[This.DynaVars.Count()+1] := name
		}
	}

	UpdateDynaVars(){
		global
		For id, VarName in This.dynaVars {
			Var := %VarName%
			Label := This.doc.getElementById(VarName).getAttribute("data-label")
			if(Label){
				Gosub % Label
			}
			This.doc.getElementById(VarName).innerText := Var
		}
	}
}