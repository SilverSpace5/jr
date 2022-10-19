extends Control

func _on_back_pressed():
	get_tree().change_scene("res://Scenes/main.tscn")
	
func _ready():
	$Username.text = Network.databaseData["username"]

func _process(delta):
	Network.databaseData["username"] = $Username.text
