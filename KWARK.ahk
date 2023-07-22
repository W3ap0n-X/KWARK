#Include %A_LineFile%\..\Neutron.ahk
class KWARK Extends NeutronWindowX {
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
	PollRate := 100
	ViewDir := StrReplace(A_LineFile, "KWARK.ahk" , "") . "Views\"

	__New(html:="", css:="", js:="", title:="KWARK") {
		This.CreateWindow(html, css, js, title)
	}

	Show(options:=""){
		This._Show(options)
		This.WindowPoll := WindowPoll := ObjBindMethod(This, "UpdateDynaVars")
		This.PollingStart()
	}

	Destroy(){
		This.PollingStop()
		
	}

	LoadTemplate(filename, title:= "" ){
		if(!title){
			title := fileName
		}
		This.Load(filename)
		
		customcsstest := "wpx"
		headerHtml := This.doc.head.innerhtml
		headerVars := {"customcsstest": customcsstest}
		headerHtml := This.ParseTemplate(headerHtml, headerVars)

		bodyHtml:= This.doc.body.innerHtml
		
		bodyHtml := This.ParseTemplate(bodyHtml , headerVars)
		This.doc.body.innerhtml := bodyHtml

		This.doc.head.innerhtml := headerHtml
		This.doc.getElementById("title").innerText := title
	}

	AppendView(fileName, toSection:="main", Vars := false){
		fileName := A_WorkingDir "/" fileName . ".html"
		FileRead, section, %fileName%
		section := This.ParseTemplate(section , Vars)
		newcontent := This.doc.getElementById(toSection).innerHtml . section
		This.doc.getElementById(toSection).innerHtml := newcontent
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
			IniRead, ValidatorRegex, regex.ini, patterns, templateString 
			IniRead, ViewRegex, regex.ini, patterns, view 
			IniRead, VarRegex, regex.ini, patterns, variable 

			If ( match := RegExMatch(template, "O)" . ValidatorRegex, tMatch )) {
				; MsgBox % tMatch.Value("templateString")
				
				; MsgBox % "inVars.Count()3: " . inVars.Count()
				; template := This.ParsePart(template, Vars)
				If (match := RegExMatch(tMatch.Value("templateString"), "O)" . ViewRegex, tView ) ) {
					; MsgBox % "viewName: "tView.Value("viewName")
					; MsgBox % tView.Count()
					incTemplate := This.GetView(tView.Value("viewName"), Vars )
					; MsgBox % incTemplate
					template := RegExReplace(template, "\Q" . tMatch.Value("templateString") . "\E", incTemplate , , 1 )
				} Else If (match := RegExMatch(tMatch.Value("templateString"), "O)" . VarRegex, tVariable )){
					; MsgBox % "varname: " . tVariable.Value("varname") . "`n" . Vars.HasKey("customcsstest")
					
					if (Vars.HasKey(tVariable.Value("varname"))) {
						; MsgBox % "meep`n" . tVariable.Value("varname") . "`n" . Vars[tVariable.Value("varname")]
						template := RegExReplace(template, "\Q" . tMatch.Value("templateString") . "\E", Vars[tVariable.Value("varname")] , , 1 )
					}
					
				}
				
				; MsgBox % tMatch.Value("templateString")
				
			}
			Else {
                break
            }
        }
        return template
    }

	PollingSet(rate){
		; MsgBox % rate
		This.PollRate := rate
		This.PollingStart()

	}

	PollingStart(){
		WindowPoll := This.WindowPoll
		SetTimer, % WindowPoll, % This.PollRate
	}
	
	PollingStop(){
		WindowPoll := This.WindowPoll
		SetTimer, % WindowPoll, Off
	}

	AddDynaVar(names*) {
		For id, name in names {
			val := % %name%
			if (isFunc(val)) {
				This.dynaVars[This.DynaVars.Count()+1] := new This.DynaFunc(name)
			} Else If (IsObject(val)){
				This.dynaVars[This.DynaVars.Count()+1] := new This.DynaObj(name)
			} Else {
				This.dynaVars[This.DynaVars.Count()+1] := new This.DynaVar(name)
			}
			
		}
	}

	AddBoundFunc(funcObj){
		val := % %funcObj%
		If (IsObject(val)){
			This.dynaVars[This.DynaVars.Count()+1] := new This.DynaFunc(funcObj)
		}
	}

	UpdateDynaVars(){
		For id, Var in This.dynaVars {
			Label := This.doc.getElementById(Var.Name).getAttribute("data-label")
			if(Label){
				Gosub % Label
			}
			This.doc.getElementById(Var.Name).innerHtml := Var.Value
		}
	}

	Button(event)
	{
		If (Label := event.target.getAttribute("data-label")){
			Gosub, % Label
		}
	}

	Class DynaVar {
		__New(Var) {
			This.Name := Var
			return % This
		}

		Value {
			get {
				name := % This.name
				val := %name%
				return % val
			}
			set {
				name := % This.name
				return %name% := value
			}
		}
	}
	Class DynaFunc {
		__New(FuncRef) {
			This.Name := FuncRef
			This.Func := %FuncRef%
			return % This
		}

		Value {
			get {
				return % This.Func.Call()
			}
		}
	}
	Class DynaObj {
		__New(objname){
			
			This.Name := objname
			This.Obj := %objname%
			return % This
		}

		__Get(key) {
			name := % This.name
			obj := This.Obj := %name%
			Return % obj[key]
		}

		Value[key:=""] {
			get {
				name := % This.name
				obj := %name%
				if (key) {
					val := obj[key]
				} Else {
					val := obj
				}
				This.Obj := obj
				return % val
			}

			set {
				name := % This.name
				objval := %name%
				if(key) {
					objval[key] := value
				}
				This.Obj := objval
				return %name% := objval
			}
		}
	}
}
