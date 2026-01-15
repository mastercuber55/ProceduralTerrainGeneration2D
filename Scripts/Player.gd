extends CharacterBody2D

enum Direction { Left, Up, Down, Right }

@onready var sprite := $PlayerSprite
@onready var generator := $"../NoiseGenerator"

var dir : Vector2
var lastDir := Direction.Down

const SPEED := 15.0

func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	
	dir = Input.get_vector("MoveLeft", "MoveRight", "MoveUp", "MoveDown") * SPEED
	
	if Input.is_action_just_pressed("Attack"):
		position = get_global_mouse_position()
	
	if dir != Vector2.ZERO:
		updateDirection()
		velocity = dir * SPEED
	else:
		velocity = Vector2.ZERO
		
	wobblePlayer()
	
	move_and_slide()

func updateDirection():
	if dir == Vector2.ZERO:
		return
	
	# More movement on x axis
	if abs(dir.x) > abs(dir.y):
		lastDir = Direction.Left if dir.x < 0 else Direction.Right
	else:
		lastDir = Direction.Up if dir.y < 0 else Direction.Down

func wobblePlayer():
	if velocity.length() > 0:
		var time = Time.get_ticks_msec() * 0.01
		sprite.scale.y  = 1 + sin(time) / 10
	else:
		sprite.scale.y = 1
