extends Control

func _ready():
	while not Global.ready:
		yield(get_tree().create_timer(0), "timeout")
	Global.changeScene("Menu")
