extends Area2D

var entered = false

func _on_Area2D_body_entered(body):
	entered = true
	

func _on_Area2D_body_exited(body):
	entered = false
if entered == true and Player arms >= 0:
	$HP.scale -= Vector2(* 0.2)
