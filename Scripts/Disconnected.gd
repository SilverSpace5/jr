extends Control

func _ready():
	if Network.reconnect:
		$Label2.text = "Reconnecting"
