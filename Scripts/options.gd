extends Control

func _on_back_pressed():
	if name == "options_in_game":
		Network.sendMsg({"joingame": Network.id})
		Global.changeScene("main")
	else:
		Global.changeScene("Menu")
	
func _ready():
	$Username.text = Network.databaseData["username"]

func _process(delta):
	Network.databaseData["username"] = $Username.text
