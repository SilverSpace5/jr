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
var arms = [false, false]
var itemR = 0
var itemL = 0
var RCooldown = 0
var LCooldown = 0
var mousePos = Vector2(0, 0)

var items = ["sword", "stick", "bow", "shield"]

puppet var nPosition = Vector2(0, 0)
puppet var nVelocity = Vector2(0, 0)
puppet var nUsername = "Unnamed"
puppet var nAnimation = "Idle"
puppet var nArms = [[false, false], Vector2(0, 0)]
puppet var nItems = [0, 0]

onready var spawn = position
onready var caves = position

onready var tween = $Tween

puppet func used(item, pos=global_position, rotation2=0, id=0):
	if item == "bow":
#		var rotation3 = rotation2
#		if $Visual.scale.x == 1:
#			rotation3 -= 45
#		else:
#			rotation3 += 45
		var proj = load("res://Projectile.tscn").instance()
		Global.scene.add_child(proj)
		proj.global_position = pos
		proj.rotation_degrees = rotation2
		proj.despawn = 2
		proj.id = id
		proj.item = load("res://Projectiles/arrow.png")
		proj.velocity = Vector2(500, 500).rotated(deg2rad(rotation2-45))

func _process(delta):
	if is_network_master():
		tick(delta)
	else:
			
		$Username.text = nUsername
		$Visual/Player/AnimationPlayer.play(nAnimation)
		
		velocity = nVelocity
		
		if nAnimation != "Idle":
			$Visual/Player/AnimationPlayer.playback_speed = velocity.x/100
		else:
			$Visual/Player/AnimationPlayer.playback_speed = 0.5
		
		if abs(velocity.x) > 0.2:
			if velocity.x > 0:
				$Visual.scale.x = 1
			else:
				$Visual.scale.x = -1
		
		$Visual/Player/Skeleton2D/Body/RightArm/Item.texture = load("res://Items/" + items[nItems[0]-1] + ".png")
		$Visual/Player/Skeleton2D/Body/LeftArm/Item.texture = load("res://Items/" + items[nItems[1]-1] + ".png")
		$Visual/Player/Skeleton2D/Body/RightArm/Item.visible = nItems[0] != 0
		$Visual/Player/Skeleton2D/Body/LeftArm/Item.visible = nItems[1] != 0
		
		if true in nArms[0]:
			mousePos = nArms[1]
			arms = nArms[0]
			if arms[0]:
				$Visual/Player/Skeleton2D/Body/LeftArm.look_at(mousePos)
			if arms[1]:
				$Visual/Player/Skeleton2D/Body/RightArm.look_at(mousePos)
			if true in arms:
				if abs(velocity.x) < 0.2:
					if mousePos.x < position.x:
						$Visual.scale.x = -1
					else:
						$Visual.scale.x = 1
		
		if nPosition != position:
			tween.interpolate_property(self, "global_position", global_position, nPosition, 0.1)
			tween.start()
		if not tween.is_active():
			velocity.y += gravity
			move_and_slide(velocity)

func tick(delta):
	var canMove = not Console.focus and not Global.scene.menu
	
	if canMove:
		mousePos = get_global_mouse_position()
		
		if Input.is_action_just_pressed("1"):
			itemR += 1
			if itemR > len(items):
				itemR = 0
	
		if Input.is_action_just_pressed("2"):
			itemL += 1
			if itemL > len(items):
				itemL = 0
	
	$Username.text = Server.dbData["username"]
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
		velocity.y = gravity * delta
	
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
			gravity = -231
		if Input.is_action_pressed("oh no"):
			gravity = 1850
	
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
	
	arms = [false, false]
	if canMove:
		if Input.is_action_pressed("arms"):
			arms = [true, true]
		if Input.is_action_pressed("rightClick"):
			arms[0] = true
		if Input.is_action_pressed("leftClick"):
			arms[1] = true
	
	$Visual/Player/Skeleton2D/Body/RightArm/Item.texture = load("res://Items/" + items[itemR-1] + ".png")
	$Visual/Player/Skeleton2D/Body/LeftArm/Item.texture = load("res://Items/" + items[itemL-1] + ".png")
	$Visual/Player/Skeleton2D/Body/RightArm/Item.visible = itemR != 0
	$Visual/Player/Skeleton2D/Body/LeftArm/Item.visible = itemL != 0
	
	if arms[0]:
		$Visual/Player/Skeleton2D/Body/LeftArm.look_at(get_global_mouse_position())
	if arms[1]:
		$Visual/Player/Skeleton2D/Body/RightArm.look_at(get_global_mouse_position())
	if true in arms:
		if abs(velocity.x) < 0.2:
			if get_global_mouse_position().x < position.x:
				$Visual.scale.x = -1
			else:
				$Visual.scale.x = 1
	
	if position.y >= 5000:
		position = spawn
		velocity = Vector2.ZERO
	
	RCooldown -= delta
	LCooldown -= delta
	if canMove:
		if (Input.is_action_pressed("leftClick") or Input.is_action_pressed("arms")) and RCooldown <= 0:
			if Input.is_action_pressed("ADMIN_MODE"):
				RCooldown = 0
			else:
				RCooldown = 0.35
			used(items[itemR-1], $Visual/Player/Skeleton2D/Body/RightArm/Item.global_position, $Visual/Player/Skeleton2D/Body/RightArm.global_rotation_degrees, get_tree().get_network_unique_id())
			rpc("used", items[itemR-1], $Visual/Player/Skeleton2D/Body/RightArm/Item.global_position, $Visual/Player/Skeleton2D/Body/RightArm.global_rotation_degrees, get_tree().get_network_unique_id())
		if (Input.is_action_pressed("rightClick") or Input.is_action_pressed("arms")) and LCooldown <= 0:
			if Input.is_action_pressed("ADMIN_MODE"):
				LCooldown = 0
			else:
				LCooldown = 0.35
			used(items[itemL-1], $Visual/Player/Skeleton2D/Body/LeftArm/Item.global_position, $Visual/Player/Skeleton2D/Body/LeftArm.global_rotation_degrees, get_tree().get_network_unique_id())
			rpc("used", items[itemL-1], $Visual/Player/Skeleton2D/Body/LeftArm/Item.global_position, $Visual/Player/Skeleton2D/Body/LeftArm.global_rotation_degrees, get_tree().get_network_unique_id())

func _on_FloorDetect_body_entered(body):
	if body.name != name and body.name != "Projectile":
		onFloor = true

func _on_FloorDetect_body_exited(body):
	if body.name != name and body.name != "Projectile":
		onFloor = false

func _on_EnemyDetect_body_entered(body):
	if "slime" in body.name or "Blue_jumper" in body.name:
		velocity.x = -2000*$Visual.scale.x
		velocity.y = -250
	if "Projectile" in body.name:
		if is_network_master() and get_tree().get_network_unique_id() != body.id:
			position = spawn
			velocity = Vector2.ZERO

func _on_tick_rate_timeout():
	if is_network_master():
		rset_unreliable("nPosition", global_position)
		rset_unreliable("nVelocity", velocity)
		rset_unreliable("nUsername", $Username.text)
		rset_unreliable("nAnimation", lastAnim)
		rset_unreliable("nArms", [arms, mousePos])
		rset_unreliable("nItems", [itemR, itemL])
