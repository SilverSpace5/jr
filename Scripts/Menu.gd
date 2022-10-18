extends Control

func _on_Play_pressed():
	Network.sendMsg({"joingame": Network.id})
	Global.changeScene("main")

func _on_options_pressed():
	Global.changeScene("options")
