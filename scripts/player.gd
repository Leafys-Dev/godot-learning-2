extends CharacterBody2D


@export var speed: float = 300.0
@export var acceleration: float = 1500.0
@export var friction: float = 1200.0

var screen_size: Vector2 = Vector2.ZERO

func _ready() -> void:
	screen_size = get_viewport_rect().size

func _physics_process(delta: float) -> void:
	# Get X and Y axis input
	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
	else: 
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		
	move_and_slide()
	
	# Set player world max limit
	player_world_max_limit()

func player_world_max_limit():
	var left_top_padding: Vector2 = Vector2(32,50) # Left > Top
	var right_bottom_padding: Vector2 = Vector2(screen_size.x - 30, screen_size.y - 10) # Right > Bottom
	position = position.clamp(left_top_padding, right_bottom_padding)
