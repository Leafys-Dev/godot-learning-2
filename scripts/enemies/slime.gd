extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var slime_death_effect_scene: PackedScene = preload("res://scenes/slime_death_effect.tscn")

# Enemy Stat
@export var current_health: int = 2
@export var damage: int = 1

@export var can_move: bool = true

@export var speed: float = 100.0
@export var acceleration: float = 400.0
@export var knockback_force: float = 300.0

var get_hit_trauma: float = 0.5

var target_position: Vector2 = Vector2.ZERO
var has_target: bool = false

func _ready() -> void:
	add_to_group("enemies")
	EventBus.player_position.connect(_on_player_position)

func _physics_process(delta: float) -> void:
	if not has_target:
		return
	
	if not can_move:
		return
	
	if global_position.distance_to(target_position) < 25.0:
		velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
		move_and_slide()
		return
	
	var direction: Vector2 = global_position.direction_to(target_position)
	velocity = velocity.move_toward(direction * speed, acceleration * delta)
	move_and_slide()


func _on_player_position(new_position: Vector2) -> void:
	target_position = new_position
	has_target = true

func take_damage(damage: int, enemy_position: Vector2) -> void:
	current_health -= damage
	EventBus.slime_hit.emit()
	EventBus.camera_shake.emit(get_hit_trauma)
	
	var attack_direction: Vector2 = enemy_position.direction_to(global_position)
	velocity = attack_direction * knockback_force 
	
	# Play Hitflash
	var tween = get_tree().create_tween()
	tween.tween_property(animated_sprite, "material:shader_parameter/hitflash_amount", 0.3, 0.1)
	tween.chain()
	tween.tween_property(animated_sprite, "material:shader_parameter/hitflash_amount", 0.0, 0.1)
	
	if current_health <= 0:
		var slime_death_effect = slime_death_effect_scene.instantiate()
		
		get_parent().add_child(slime_death_effect)
		slime_death_effect.global_position = global_position
		
		queue_free()

func _on_hurt_box_area_entered(area: Area2D) -> void:
	take_damage(area.get_parent().get_parent().damage, area.global_position)
