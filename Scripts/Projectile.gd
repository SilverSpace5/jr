extends RigidBody2D

export (Texture) var item
export (Vector2) var velocity
export (float) var despawn

var despawnTimer = 0
var init = false
var collided = false
var hitPos = Vector2(0, 0)
var hitRotation = 0
var id = 0
var despawnTimer2 = 0
var itemName = ""

func _physics_process(delta):
	if not init:
		visible = true
		init = true
		$Sprite.texture = item
		$CollisionShape2D.scale.x = $Sprite.texture.get_width()
		$CollisionShape2D.scale.y = $Sprite.texture.get_height()
		apply_impulse(Vector2.ZERO, velocity)
	
	if itemName == "arrow":
		if collided:
			$CollisionShape2D.disabled = true
			position = hitPos
			rotation_degrees = hitRotation
			despawnTimer2 += delta
			if despawnTimer2 >= 2:
				queue_free()
		else:
			look_at(position + linear_velocity)
	if itemName == "trail":
		gravity_scale = 0
		$CollisionShape2D.disabled = true
	despawnTimer += delta
	if despawnTimer >= despawn:
		queue_free()

func _on_Projectile_body_entered(body):
	if itemName == "arrow":
		if not "Projectile" in body.name:
			collided = true
			hitPos = position
			hitRotation = rotation_degrees
