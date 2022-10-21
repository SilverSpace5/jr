extends AudioStreamPlayer2D

var last_scene_name = Global.sceneName

func _process(delta):
	
	if Global.ready:
		volume_db = 10 * (Network.databaseData["volume"]/100)
	
	if last_scene_name != Global.sceneName:
		last_scene_name = Global.sceneName
		if Global.sceneName == "main" or Global.sceneName == "Connect":
			playing = false
		elif not playing:
			playing = true
		
