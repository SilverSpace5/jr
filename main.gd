extends Node2D





func _process(delta):
	if Input. is_action_pressed("zoom_in"):
		$entitys/YOU/Player/Camera2D.zoom -= Vector2(.01, .01)
	if Input. is_action_pressed("zoom_out"):
		$entitys/YOU/Player/Camera2D.zoom += Vector2(.01, .01)

