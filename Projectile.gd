extends RigidBody2D

export (Texture) var item
export (Vector2) var velocity

func _ready():
	yield(get_tree().create_timer(0.1), "timeout")
	$CollisionShape2D.scale.x = $Sprite.texture.get_width()
	$CollisionShape2D.scale.y = $Sprite.texture.get_height()
	apply_impulse(Vector2.ZERO, velocity)
