extends KinematicBody2D

# Edit these in the editor
export var speed = 200
export var jumpSpeed = 500
export var gravity = 50

var velocity = Vector2(0, 0)
var onFloor = false
var floorFrames = 0
var holdJump = false
var jump = 0
var data = {}
var lastAnim = "Idle"
onready var spawn = position
onready var caves = position

onready var tween = $Tween

func _process(delta):
	if Network.playerData.has(name):
		data = Network.playerData[name]
	if Input. is_action_just_released("ADMIN_MODE"):
		$CollisionShape2D.disabled = false
		speed = 200
	if name == Network.id:
		tick(delta)
	else:
		if not data.has("position"):
			return
			
		$Username.text = data["username"]
		$Visual/Player/AnimationPlayer.play(data["animation"])
		
		var pos = Global.getVector(data["position"])
		velocity = Global.getVector(data["velocity"])
		
		if data["animation"] != "Idle":
			$Visual/Player/AnimationPlayer.playback_speed = velocity.x/100
		else:
			$Visual/Player/AnimationPlayer.playback_speed = 0.5
		
		if abs(velocity.x) > 0.2:
			if velocity.x > 0:
				$Visual.scale.x = 1
			else:
				$Visual.scale.x = -1
		
		if data["arms"]:
			var mousePos = Global.getVector(data["arms"])
			$Visual/Player/Skeleton2D/Body/LeftArm.look_at(mousePos)
			$Visual/Player/Skeleton2D/Body/RightArm.look_at(mousePos)
			if abs(velocity.x) < 0.2:
				if mousePos.x < position.x:
					$Visual.scale.x = -1
				else:	
					$Visual.scale.x = 1
		
		if pos != position:
			tween.interpolate_property(self, "global_position", global_position, pos, 0.1)
#			if Global.fasterNetwork:
#				#print(pos)
#				#print("--> " + str(pos+velocity*delta/2))
#				tween.interpolate_property(self, "global_position", global_position, pos+velocity*delta*2, 0.05)
#			else:
			tween.start()
		if not tween.is_active():
			velocity.y += gravity
#			if Global.fasterNetwork:
				
			move_and_slide(velocity)

func tick(delta):
	var canMove = not Console.focus and not Global.scene.menu
	
	$Username.text = Network.databaseData["username"]
	var inputX = Input.get_action_strength("right") - Input.get_action_strength("left")
	velocity.y += gravity * delta
	
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
		velocity.y = gravity
	
	if canMove and (Input.is_action_just_pressed("jump") or (Input.is_action_pressed("jump") and jump > 0)) and (floorFrames <= 3 or (jump <= 8 and holdJump)):
		var jump2 = jumpSpeed + (jumpSpeed*0.1*jump)
		velocity.y = -jump2
		jump += 48 * delta
	
	if is_on_floor():
		velocity.x *= 0.33 
	else:
		velocity.x *= 0.8 
		speed /= 3
	if canMove:
		velocity.x += inputX * speed
	if not is_on_floor():
		speed *= 3
	
	if Input.is_action_pressed("ADMIN_MODE") and canMove:
		if Input. is_action_pressed("fast"):
			speed += 10
		if Input. is_action_pressed("slow"):
			speed -= 10
		if Input.is_action_pressed("no_clip"):
			$CollisionShape2D.disabled = true
		if Input. is_action_pressed("now_clip"):
			$CollisionShape2D.disabled = false
		if Input. is_action_pressed("weeee"):
			gravity = -5
		if Input.is_action_pressed("oh no"):
			gravity = 40
	
	move_and_slide(velocity, Vector2.UP)
	
	if abs(velocity.x) > 0.2:
		$Visual/Player/AnimationPlayer.play("run")
		lastAnim = "run"
		$Visual/Player/AnimationPlayer.playback_speed = velocity.x/100
		#print(velocity.x/200)
		if velocity.x > 0:
			$Visual.scale.x = 1
		else:
			$Visual.scale.x = -1
	else:
		$Visual/Player/AnimationPlayer.playback_speed = 0.5
		$Visual/Player/AnimationPlayer.play("Idle")
		lastAnim = "Idle"
	
	if not onFloor and not is_on_floor():
		$Visual/Player/AnimationPlayer.play("Jump")
		lastAnim = "Jump"
	
	if Input.is_action_pressed("arms"):
		$Visual/Player/Skeleton2D/Body/LeftArm.look_at(get_global_mouse_position())
		$Visual/Player/Skeleton2D/Body/RightArm.look_at(get_global_mouse_position())
		if abs(velocity.x) < 0.2:
			if get_global_mouse_position().x < position.x:
				$Visual.scale.x = -1
			else:
				$Visual.scale.x = 1
	
	if position.y >= 5000:
		position = spawn
		velocity = Vector2.ZERO
	

func _on_FloorDetect_body_entered(body):
	if body.name != name:
		onFloor = true

func _on_FloorDetect_body_exited(body):
	if body.name != name:
		onFloor = false

func _on_EnemyDetect_body_entered(body):
	if "slime" in body.name or "Blue_jumper" in body.name:
		velocity.x = -2000*$Visual.scale.x
		velocity.y = -250

func _on_tick_rate_timeout():
	if name == Network.id:
		Network.data["position"] = global_position
		Network.data["velocity"] = velocity
		Network.data["username"] = $Username.text
		Network.data["animation"] = lastAnim
		if Input.is_action_pressed("arms"):
			Network.data["arms"] = get_global_mouse_position()
		else:
			Network.data["arms"] = false
