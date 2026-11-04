extends Node

signal player_position(position: Vector2)
signal health_changed(new_health: int, max_health: int)

signal camera_shake(amount: float)

signal gold_collected
signal score_update(new_score: int)
signal wave_started(wave_number: int)
signal game_over
signal update_highscore(new_high_score: int)

# Sound Effect
signal sword_swung
signal slime_hit
signal player_hit
