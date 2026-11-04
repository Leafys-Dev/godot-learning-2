extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var i_frame_timer: Timer = $IFrameTimer
@onready var hitstun_timer: Timer = $HitstunTimer
@onready var weapon_pivot: Node2D = $WeaponPivot
@onready var sword_hit_box: Area2D = $WeaponPivot/SwordHitBox
@onready var sword_collision_shape: CollisionShape2D = $WeaponPivot/SwordHitBox/CollisionShape2D

# Player stats
@export var max_health: int = 3
var current_health: int = 3
@export var can_move: bool = true
@export var is_attacking: bool = false
@export var damage: int = 1

var get_small_hit_trauma: float = 0.5
var death_trauma: float = 0.6


@export var speed: float = 300.0
@export var acceleration: float = 1500.0
@export var friction: float = 1200.0
@export var knockback_force: float = 600.0


var screen_size: Vector2 = Vector2.ZERO

func _ready() -> void:
	screen_size = get_viewport_rect().size
	can_move = false

func _physics_process(delta: float) -> void:
	EventBus.player_position.emit(global_position)
	
	# If player cannot move
	if not can_move:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		move_and_slide()
		return
	
	if Input.is_action_just_pressed("basic_attack") and not is_attacking and can_move:
		start_attack()
	
	if is_attacking:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		move_and_slide()
		return
	
	# Get X and Y axis input
	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if direction.x > 0:
		animated_sprite.flip_h = false
	elif direction.x < 0:
		animated_sprite.flip_h = true
	
	if direction != Vector2.ZERO:
		animated_sprite.play("run")
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
	else: 
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		animated_sprite.play("idle")
	
	move_and_slide()
	
	# Set player world max limit
	player_world_max_limit()

func player_world_max_limit():
	var left_top_padding: Vector2 = Vector2(32,50) # Left > Top
	var right_bottom_padding: Vector2 = Vector2(screen_size.x - 30, screen_size.y - 10) # Right > Bottom
	position = position.clamp(left_top_padding, right_bottom_padding)
	
# Detect hitbox
func take_damage(damage: int, enemy_position: Vector2):
	if i_frame_timer.time_left > 0:
		return
	
	# Decrease player health
	current_health -= damage
	EventBus.player_hit.emit()
	EventBus.health_changed.emit(current_health, max_health)
	
	# Check if player still have health
	if current_health <= 0:
		EventBus.camera_shake.emit(death_trauma)
		can_move = false
		EventBus.game_over.emit()
		return
	
	# Hitstun
	EventBus.camera_shake.emit(get_small_hit_trauma)
	can_move = false
	hitstun_timer.start()
	
	# Apply Knockback
	var knockback_direction = enemy_position.direction_to(global_position)
	velocity = knockback_direction * knockback_force
	
	# Hit Flash Effect
	var tween = get_tree().create_tween()
	tween.tween_property(animated_sprite, "material:shader_parameter/hitflash_amount", 0.3, 0.1)
	tween.chain()
	tween.tween_property(animated_sprite, "material:shader_parameter/hitflash_amount", 0, 0.1)
	
	# Start Iframe timer
	i_frame_timer.start()

# Reset Player Health
func reset_health():
	current_health = max_health
	can_move = true
	EventBus.health_changed.emit(current_health, max_health)

# Start attack
func start_attack() -> void:
	is_attacking = true
	EventBus.sword_swung.emit()
	
	# Change hitbox position and rotation
	var mouse_pos: Vector2 = get_global_mouse_position()
	weapon_pivot.look_at(mouse_pos)
	
	# Change sprite flip h
	animated_sprite.flip_h = (mouse_pos.x < global_position.x)
	
	# Rotate Sprite
	var diff: Vector2 = mouse_pos - (global_position + Vector2(0, -32))
	var target_angle = clampf(diff.y * 0.002, deg_to_rad(-15.0), deg_to_rad(15.0))
	animated_sprite.rotation = target_angle
	
	sword_collision_shape.set_deferred("disabled", false)
	animated_sprite.play("basic_attack")
	

func _on_hurt_box_area_entered(area: Area2D) -> void:
	take_damage(area.get_parent().damage, area.global_position)
	

func _on_hitstun_timer_timeout() -> void:
	if current_health > 0: 
		can_move = true

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "basic_attack":
		is_attacking = false
		sword_collision_shape.set_deferred("disabled", true)
		animated_sprite.play("idle")
		animated_sprite.rotation = 0
		
