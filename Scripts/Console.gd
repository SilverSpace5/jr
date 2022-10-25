extends CanvasLayer

var focus = false
var lines = []
var updated = 0
var targetAlpha = 0
var targetAlpha2 = 0
var lastUsername = ""

remote func log2(value):
	if updated < 1:
		updated = 1
	updated += len(value) / 7.5
	lines.append(value)
	if len(lines) > 5:
		lines.pop_front()

func _process(delta):
	if Global.ready:
		if lastUsername != Server.dbData["username"]:
			lastUsername = Server.dbData["username"]
			$VBoxContainer/LineEdit.max_length = 37-len(Server.dbData["username"])
	
	var controls = ""
	if Global.sceneName == "main":
		if not Global.scene.menu:
			if not focus:
				controls += " (T) Open Chat"
			elif not Global.scene.menu:
				controls += " (ESC) Close Chat"
		else:
			focus = false
		
		if not focus:
			if Global.scene.menu:
				focus = false
				controls += " (ESC) Close Menu"
			else:
				controls += " (ESC) Open Menu"
	$Controls/Label.text = controls
	
	if not focus:
		updated -= delta
	
	
	
	if focus or updated > 0:
		targetAlpha = 0.75
		targetAlpha2 = 0.75
	else:
		targetAlpha = 0
		targetAlpha2 = 0
	
	if focus:
		if Input.is_action_just_pressed("send") and Global.ready:
			log2("[" + Server.dbData["username"] + "] " + $VBoxContainer/LineEdit.text)
			rpc("log2", "[" + Server.dbData["username"] + "] " + $VBoxContainer/LineEdit.text)
			$VBoxContainer/LineEdit.text = ""
			focus = false
	else:
		$VBoxContainer/LineEdit.text = ""
	
	if Global.sceneName == "main":
		if Input.is_action_just_pressed("chat"):
			focus = true
			$VBoxContainer/LineEdit.grab_focus()
		
		if Input.is_action_just_pressed("ui_cancel"):
			focus = false
	else:
		focus = false
	
	var text = ""
	for line in lines:
		text += "\n" + line
	$VBoxContainer/Label.text = text
	
	$VBoxContainer/Label.modulate.a += (targetAlpha2 - $VBoxContainer/Label.modulate.a)/5
	if focus:
		$VBoxContainer/LineEdit.modulate.a += (targetAlpha - $VBoxContainer/LineEdit.modulate.a)/5
	else:
		$VBoxContainer/LineEdit.modulate.a += (0 - $VBoxContainer/LineEdit.modulate.a)/5
