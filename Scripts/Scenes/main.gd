extends Node2D
#lmao
export (Vector2) var spawn = Vector2(0, 0)
export (float) var zoom = 0.7
var menu = false
var consoleWait = 0
var lightNode = load("res://Instances/light.tscn")

func _ready():
	$peaceful_town.play(1.75)
	$AudioStreamPlayer2D.play(1.75)
	$peaceful_town.volume_db = Server.dbData["volume"]/2 - 50
	$AudioStreamPlayer2D.volume_db = Server.dbData["volume"]/2 - 50
	$Camera2D/Scale/Menu/Players.add_item(Server.dbData["username"], null, false)
	for tilePos in $"background(but_not)".get_used_cells():
		var lightNode2 = lightNode.instance()
		$Lights.add_child(lightNode2)
		lightNode2.position = tilePos*32+Vector2(16, 16)
	
	$Camera2D/Scale/Menu.visible = true
	Global.player = Server.instance_player(get_tree().get_network_unique_id(), spawn)
	$Camera2D.position = spawn

func _process(delta):
	if menu == true:
		$Camera2D/Scale/Menu.visible = true
	if menu == false:
		$Camera2D/Scale/Menu.visible = false
	$Camera2D.position += (Global.player.position - $Camera2D.position)/5
	if Input. is_action_pressed("zoom_in"):
		zoom -= 0.01 * zoom
	if Input. is_action_pressed("zoom_out"):
		zoom += 0.01 * zoom
	zoom = clamp(zoom, 0.1, 1.5)
	$Camera2D.zoom = Vector2(zoom, zoom)
	$Camera2D/Scale.scale = $Camera2D.zoom
	consoleWait -= delta
	if Console.focus:
		consoleWait = 0.1
	if Input. is_action_just_pressed("in_game_menu") and consoleWait <= 0:
		if menu == false:
			menu = true
		else:
			menu = false

func _on_menu_pressed():
	Global.changeScene("Menu")
	for child in Players.get_children():
		child.queue_free()
	Server.rpc("leaveGame", get_tree().get_network_unique_id())

func _on_options_pressed():
	Global.changeScene("options_in_game")
	for child in Players.get_children():
		child.queue_free()
	Server.rpc("leaveGame", get_tree().get_network_unique_id())

#          music
#func _on_Area2D_body_entered(body):
#	if Global.player.name == body.name:
#		$peaceful_town.playing = true
#
#func _on_Area2D_body_exited(body):
#	if Global.player.name == body.name:
#		$peaceful_town.playing = false


func _on_pvp_onoff_pressed():
	var tick_on_off = 0
	if tick_on_off == 0:
		if $Camera2D/Scale/Menu/Tick.visible == false:
			$Camera2D/Scale/Menu/Tick.visible = true
			tick_on_off += 1
	if tick_on_off == 1:
		if $Camera2D/Scale/Menu/Tick.visible == true:
			$Camera2D/Scale/Menu/Tick.visible = false
			tick_on_off -= 1


func _on_mute_pressed():
	$peaceful_town.autoplay
