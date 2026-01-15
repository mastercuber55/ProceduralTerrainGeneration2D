extends CharacterBody2D

const SPEED := 10.0
enum Direction { Left, Up, Down, Right }
var DirectionNames = ["Left", "Up", "Down", "Right"]

@onready var sprite := $PlayerSprite

var dir : Vector2
var lastDir := Direction.Down

func _ready() -> void:
	updateAnimation()

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
	updateAnimation()
	
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

func updateAnimation():
	if dir != Vector2.ZERO:
		sprite.play("Walk" + DirectionNames[lastDir])
	else:
		sprite.play("Idle" + DirectionNames[lastDir])
