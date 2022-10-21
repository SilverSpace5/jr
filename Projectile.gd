extends RigidBody2D

export (Texture) var item
export (Vector2) var velocity
export (float) var despawn

var despawnTimer = 0
var init = false

func _physics_process(delta):
	if not init:
		init = true
		$Sprite.texture = item
		$CollisionShape2D.scale.x = $Sprite.texture.get_width()
		$CollisionShape2D.scale.y = $Sprite.texture.get_height()
		apply_impulse(Vector2.ZERO, velocity)
	despawnTimer += delta
	if despawnTimer >= despawn:
		queue_free()
