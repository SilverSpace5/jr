extends Control

func _on_back_pressed():
	if Global.sceneName == "options_in_game":
		Server.rpc("joinGame", get_tree().get_network_unique_id(), Server.dbData["username"])
		Global.changeScene("main")
	else:
		Global.changeScene("Menu")
	
func _ready():
	$Username.text = Server.dbData["username"]
	$Volume.value = Server.dbData["volume"]
	$Id.text = Global.id

func _process(delta):
	Server.dbData["username"] = $Username.text
	Server.dbData["volume"] = $Volume.value
