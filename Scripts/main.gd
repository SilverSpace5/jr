extends Node2D

export (Vector2) var spawn = Vector2(0, 0)
export (float) var zoom = 0.7

func _ready():
	Global.player = Network.instance_player(Network.id, spawn)
	$Camera2D.position = spawn

func _process(delta):
	$Camera2D.position += (Global.player.position - $Camera2D.position)/5
	if Input. is_action_pressed("zoom_in"):
		zoom -= 0.01 * zoom
	if Input. is_action_pressed("zoom_out"):
		zoom += 0.01 * zoom
	zoom = clamp(zoom, 0.1, 1.5)
	$Camera2D.zoom = Vector2(zoom, zoom)
