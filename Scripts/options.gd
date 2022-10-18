extends Control

func _on_back_pressed():
	Global.changeScene("Menu")
	
func _ready():
	$Username.text = Network.databaseData["username"]

func _process(delta):
	Network.databaseData["username"] = $Username.text
