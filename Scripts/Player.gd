extends CharacterBody2D

const SPEED := 100.0

@onready var sprite := $Pivot/PlayerSprite
@onready var weapon := $Pivot/Weapon

func _physics_process(_delta: float) -> void:
	
	velocity = Input.get_vector("MoveLeft", "MoveRight", "MoveUp", "MoveDown") * SPEED
	
	if velocity.x < 0:
		$Pivot.scale.x = -1
	elif velocity.x > 0:
		$Pivot.scale.x = 1
		
	if velocity.length() > 0:
		var time = Time.get_ticks_msec() * 0.01
		sprite.scale.y  = 1 + sin(time) / 10
	else:
		sprite.scale.y = 1
		
	if Input.is_action_just_pressed("Attack"):
		weapon.get_node("AnimationPlayer").play("Swing")
	
	move_and_slide()
