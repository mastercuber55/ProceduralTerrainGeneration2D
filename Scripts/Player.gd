extends CharacterBody2D

const SPEED := 100.0

@onready var sprite := $PlayerSprite
@onready var weapon := $Weapon

func _physics_process(_delta: float) -> void:
	
	velocity = Input.get_vector("MoveLeft", "MoveRight", "MoveUp", "MoveDown") * SPEED
	
	if velocity.x < 0:
		sprite.flip_h = true
	elif velocity.x > 0:
		sprite.flip_h = false
		
	if velocity.length() > 0:
		var time = Time.get_ticks_msec() / 100
		sprite.scale.y  = 1 + sin(time) / 10
	else:
		sprite.scale = Vector2.ONE
		
	if Input.is_action_just_pressed("Attack"):
		$Weapon/AnimationPlayer.play("Swing")
	
	move_and_slide()
