extends KinematicBody2D

export var speed = 10
export var jump = 500
export var gravity = 50

var animateTimer = 0

var velocity = Vector2(0, 0)


func _physics_process(delta):
	animateTimer += delta
	if animateTimer >= 0.25:
		animateTimer = 0
		if $BlueJumperSpriteSheet.frame == 2:
			
			$BlueJumperSpriteSheet.frame = 0
		else:
			$BlueJumperSpriteSheet.frame += 1
	
var entered = false

func _on_Area2D_body_entered(body: PhysicalBody2D):
	entered = true
	


func _on_Area2D_body_exited(body):
	entered = false
