extends Node

const BGM = preload("res://assets/music/time_for_adventure.mp3")
const GOLD_PICKUP = preload("res://assets/sounds/coin.wav")
const GAME_OVER = preload("res://assets/sounds/explosion.wav")

# Sound Effect
const PLAYER_HIT = preload("res://assets/sounds/hurt.wav")
const SLIME_HIT = preload("res://assets/sounds/jump.wav")
const SWORD = preload("res://assets/sounds/sword_randomizer.tres")


var music_player: AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Play BGM
	music_player = AudioStreamPlayer.new()
	music_player.stream = BGM
	music_player.bus = "BGM"
	music_player.autoplay = true
	add_child(music_player)
	music_player.play()
	
	# VFX PLAYER
	EventBus.player_hit.connect(func(): play_vfx(PLAYER_HIT))
	EventBus.slime_hit.connect(func(): play_vfx(SLIME_HIT))
	EventBus.sword_swung.connect(func(): play_vfx(SWORD))
	
	EventBus.gold_collected.connect(_on_gold_collected)
	EventBus.game_over.connect(_on_gameover)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_gold_collected() -> void:
	play_vfx(GOLD_PICKUP)

func _on_gameover() -> void:
	play_vfx(GAME_OVER)

func play_vfx(audiostream: AudioStream) -> void:
	var vfx_player: AudioStreamPlayer = AudioStreamPlayer.new()
	vfx_player.stream = audiostream
	vfx_player.bus = "VFX"
	vfx_player.finished.connect(vfx_player.queue_free)
	add_child(vfx_player)
	vfx_player.play()
