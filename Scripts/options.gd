extends Control

func _on_back_pressed():
	if Global.sceneName == "options_in_game":
		Network.sendMsg({"joingame": Network.id})
		Global.changeScene("main")
	else:
		Global.changeScene("Menu")
	
func _ready():
	$Username.text = Network.databaseData["username"]
	$Volume.value = Network.databaseData["volume"]
	$Id.text = Global.id

func _process(delta):
	Network.databaseData["username"] = $Username.text
	Network.databaseData["volume"] = $Volume.value
