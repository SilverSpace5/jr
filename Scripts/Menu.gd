extends Control

func _on_Play_pressed():
	get_tree().change_scene("res://main.tscn")


func _on_options_pressed():
	get_tree().change_scene("res://options.tscn")
