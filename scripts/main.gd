extends Node2D

@export var gold_scene: PackedScene = preload("res://scenes/gold.tscn")

var screen_size: Vector2 = Vector2.ZERO
var padding_left = 32
var padding_right = 30
var padding_top = 50
var padding_bottom = 10

var gold_exist: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not gold_exist:
		spawn_gold(3)
		gold_exist = true

func spawn_gold(counts):
	for count in counts:
		var gold = gold_scene.instantiate()
		
		var random_position = Vector2(
			randf_range(padding_left, screen_size.x - padding_right),
			randf_range(padding_top, screen_size.y - padding_bottom)
		)
		
		gold.position = random_position
		
		add_child(gold)
