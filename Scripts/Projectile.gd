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

func _physics_process(delta):
	if not init:
		init = true
		$Sprite.texture = item
		$CollisionShape2D.scale.x = $Sprite.texture.get_width()
		$CollisionShape2D.scale.y = $Sprite.texture.get_height()
		apply_impulse(Vector2.ZERO, velocity)
	if collided:
		$CollisionShape2D.disabled = true
		position = hitPos
		rotation_degrees = hitRotation
		despawnTimer += delta
		if despawnTimer >= despawn:
			queue_free()
	else:
		look_at(position + linear_velocity)
		#rotation_degrees -= 45
	despawnTimer2 += delta
	if despawnTimer2 >= despawn*10:
		queue_free()

func _on_Projectile_body_entered(body):
	if not "Projectile" in body.name:
		collided = true
		hitPos = position
		hitRotation = rotation_degrees
