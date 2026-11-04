extends Node2D

var config = ConfigFile.new()
const SAVE_PATH = "user://records.cfg"
var high_score: int = 0

@export var gold_scene: PackedScene = preload("res://scenes/gold.tscn")
@export var slime_scene: PackedScene = preload("res://scenes/enemies/green_slime.tscn")

@onready var hud: CanvasLayer = $HUD
@onready var player: CharacterBody2D = $Player
@onready var game_timer: Timer = $GameTimer
@onready var slime_respawn_timer: Timer = $"Slime Respawn Timer"

var screen_size: Vector2 = Vector2.ZERO
var padding_left = 32
var padding_right = 30
var padding_top = 50
var padding_bottom = 10

var score: int = 0
var initial_gold_spawn_amount: int = 3
var time_left: int = 10
var wave: int = 1
var coin_remaining: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	load_high_score()
	
	EventBus.gold_collected.connect(_on_gold_connected)
	EventBus.game_over.connect(_on_game_over)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func spawn_slime() -> void:
	var slime = slime_scene.instantiate()
	
	# Generate screen edge
	# 0 = Top, 1 = Bottom, 2 = Left, 3 = Right
	var random_edge = randi_range(0, 3) 
	var rect = get_viewport_rect()
	
	var top_edge = rect.position.y - 30
	var bottom_edge = rect.end.y + 30
	var left_edge = rect.position.x - 30
	var right_edge = rect.end.x + 30
	
	var slime_spawn_position: Vector2
	
	match random_edge:
		0:
			slime_spawn_position = Vector2(randf_range(left_edge, right_edge), top_edge)
		1: 
			slime_spawn_position = Vector2(randf_range(left_edge, right_edge), bottom_edge)
		2:
			slime_spawn_position = Vector2(left_edge, randf_range(top_edge, bottom_edge))
		3:
			slime_spawn_position = Vector2(right_edge, randf_range(top_edge, bottom_edge))


	slime.position = slime_spawn_position
	add_child(slime)

func spawn_gold(count: int) -> void:
	coin_remaining = count
	for i in range(count):
		
		var gold = gold_scene.instantiate()
		
		var random_position = Vector2(
			randf_range(padding_left, screen_size.x - padding_right),
			randf_range(padding_top, screen_size.y - padding_bottom)
		)	
		
		gold.position = random_position
		add_child(gold)

func _on_gold_connected() -> void:
	score += 1
	coin_remaining -= 1
	time_left += 1
	hud.update_time(time_left)
	hud.update_score(score)
	
	if coin_remaining == 0:
		print("Wave cleared")
		wave += 1
		call_deferred("spawn_gold", initial_gold_spawn_amount + wave)

func _on_hud_start_game() -> void:
	# Reset HUD
	score = 0
	wave = 1
	time_left = 10
	player.can_move = true
	player.reset_health()
	
	hud.update_score(score)
	EventBus.update_highscore.emit(high_score)
	hud.update_time(time_left)
	
	get_tree().call_group("golds", "queue_free")
	get_tree().call_group("enemies", "queue_free")
	
	player.position = screen_size / 2
	
	game_timer.start()
	slime_respawn_timer.start()
	
	spawn_gold(initial_gold_spawn_amount)
	

func _on_game_timer_timeout() -> void:
	time_left -= 1
	hud.update_time(time_left)
	if time_left == 0:
		EventBus.game_over.emit()

func _on_game_over() -> void:
	game_timer.stop()
	slime_respawn_timer.stop()
	
	get_tree().call_group("golds", "queue_free")
	get_tree().call_group("enemies", "queue_free")
	player.can_move = false
	
	# Save Score
	if score > high_score:
		high_score = score
		EventBus.update_highscore.emit(high_score)
		config.set_value("records", "high_score", high_score)
		config.save(SAVE_PATH)

func _on_slime_respawn_timer_timeout() -> void:
	spawn_slime()
	

# Load High Score
func load_high_score() -> void:
	config.load(SAVE_PATH)
	
	high_score = config.get_value("records", "high_score", 0)
