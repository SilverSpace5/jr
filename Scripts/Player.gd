extends KinematicBody2D

# Edit these in the editor
export var speed = 50
export var jumpSpeed = 500
export var gravity = 50

var velocity = Vector2(0, 0)
var onFloor = false
var floorFrames = 0
var holdJump = false
var jump = 0

func _process(delta):
	var inputX = Input.get_action_strength("right") - Input.get_action_strength("left")
	velocity.y += gravity
	
	$FloorDetect.update()
	
	if not Input.is_action_pressed("jump"):
		holdJump = false
		
	if onFloor:
		floorFrames = 0
	else:
		floorFrames += 1
	
	if is_on_floor():
		velocity.y = 0
		jump = 0
		holdJump = true
	if is_on_ceiling():
		velocity	.y = gravity
	
	if (Input.is_action_just_pressed("jump") or (Input.is_action_pressed("jump") and jump > 0)) and (floorFrames <= 3 or (jump <= 8 and holdJump)):
		var jump2 = jumpSpeed + (jumpSpeed*0.1*jump)
		velocity.y = -jump2
		jump += 1
	
	if is_on_floor():
		velocity.x *= 0.33
	else:
		velocity.x *= 0.8
		speed /= 3
	velocity.x += inputX * speed
	if not is_on_floor():
		speed *= 3
	
	if Input. is_action_pressed("ADMIN_MODE"):
		if Input. is_action_pressed("weeee"):
			gravity = -5
		if Input.is_action_pressed("oh no"):
			gravity = 40
	
	move_and_slide(velocity, Vector2.UP)
	
	if position.y >= 1000:
		position = Vector2(217, 118)

func _on_FloorDetect_body_entered(body):
	if body.name != name:
		onFloor = true

func _on_FloorDetect_body_exited(body):
	if body.name != name:
		onFloor = false
