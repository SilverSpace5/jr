extends Control

func _on_Play_pressed():
	if Global.ready:
		Server.rpc("joinGame", get_tree().get_network_unique_id(), Server.dbData["username"])
		Global.changeScene("main")

func _on_Options_pressed():
	if Global.ready:
		Global.changeScene("options")
