extends CharacterBody2D

const SPEED = 10000.0


func _physics_process(delta: float) -> void:
	
	velocity = Input.get_vector("MoveLeft", "MoveRight", "MoveUp", "MoveDown") * delta * SPEED

	move_and_slide()
