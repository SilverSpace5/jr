extends Node2D

export (Vector2) var spawn = Vector2(0, 0)
export (float) var zoom = 0.7
var menu = false

func _ready():
	Global.player = Network.instance_player(Network.id, spawn)
	$Camera2D.position = spawn

func _process(delta):
	if menu == true:
		$Camera2D/Node2D/menu.visible = true
		$Camera2D/Node2D/options.visible = true
		$Camera2D/Node2D/Dark.visible = true
	if menu == false:
		$Camera2D/Node2D/menu.visible = false
		$Camera2D/Node2D/options.visible = false
		$Camera2D/Node2D/Dark.visible = false
	$Camera2D.position += (Global.player.position - $Camera2D.position)/5
	if Input. is_action_pressed("zoom_in"):
		zoom -= 0.01 * zoom
	if Input. is_action_pressed("zoom_out"):
		zoom += 0.01 * zoom
	zoom = clamp(zoom, 0.1, 1.5)
	$Camera2D.zoom = Vector2(zoom, zoom)
	$Camera2D/Node2D.scale = $Camera2D.zoom
	if Input. is_action_just_pressed("in_game_menu"):
		if menu == false:
			menu = true
		else:
			menu = false

func _on_menu_pressed():
	get_tree().change_scene("res://Scenes/Menu.tscn")


func _on_options_pressed():
	get_tree().change_scene("res://Scenes/options_in_game.tscn")
