extends KinematicBody2D

export var speed = 10
export var jump = 500
export var gravity = 50

var velocity = Vector2(0, 0)


func _physics_process(delta):
	$BlueJumperSpriteSheet.frame = 0
	yield(get_tree().create_timer(1),"timeout")
	$BlueJumperSpriteSheet.frame = 1
	yield(get_tree().create_timer(1),"timeout")
	$BlueJumperSpriteSheet.frame = 2
	yield(get_tree().create_timer(1),"timeout")
	#yield(get_tree().create_timer(2),"timeout")
