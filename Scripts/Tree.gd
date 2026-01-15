extends StaticBody2D

var health := 10

func _on_attack(_body: Node2D) -> void:
	health -= 1
	
	$Sprite2D/AnimationTree.play("Hit")
		
	if health <= 0:
		call_deferred("queue_free")
