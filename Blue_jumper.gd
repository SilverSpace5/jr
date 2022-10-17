extends KinematicBody2D

export var speed = 10
export var jump = 500
export var gravity = 50

var velocity = Vector2(0, 0)


func _physics_process(delta):
	velocity = Vector2(0, 0)
	yield(get_tree().create_timer(2),"timeout")
	velocity.x -= 5
	
