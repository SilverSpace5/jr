extends AudioStreamPlayer2D

func _process(delta):
	if Global.ready:
		volume_db = 60 * (Server.dbData["volume"]/100) - 50
		if Global.sceneName == "main":
			stop()
		elif not playing:
			play(1.75)
		
