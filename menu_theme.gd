extends AudioStreamPlayer2D

var last_scene_name = Global.sceneName

func _process(delta):
	
	if last_scene_name != Global.sceneName:
		last_scene_name = Global.sceneName
		if Global.sceneName == "main":
			playing = false
		if Global.sceneName != "main" and playing == false:
			playing = true
		
