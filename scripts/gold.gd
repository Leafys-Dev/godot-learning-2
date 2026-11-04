extends Area2D

@export var gold_pickup_effect_scene: PackedScene = preload("res://scenes/coin_pickup_effect.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready() -> void:
	add_to_group("golds")
	
func _process(_delta: float) -> void:
	pass


func _on_body_entered(_body: Node2D) -> void:
	EventBus.gold_collected.emit()
	var gold_pickup = gold_pickup_effect_scene.instantiate()
	
	get_parent().add_child(gold_pickup)
	gold_pickup.global_position = global_position
	
	queue_free()
