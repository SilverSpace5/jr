extends Control

var timer = 0

func _ready():
	if Network.reconnect:
		$Label2.text = "Reconnecting"

func _process(delta):
	if Network.connected:
		if timer >= 0.5:
			Global.changeScene("Menu")
		timer += delta
	else:
		timer = 0
