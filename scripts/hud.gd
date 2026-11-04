extends CanvasLayer

signal start_game

@onready var score_label: Label = $"MarginContainer/HBoxContainer/Score Label"
@onready var time_label: Label = $"MarginContainer/HBoxContainer/Time Label"
@onready var message_label: Label = $"VBoxContainer/Message Label"
@onready var high_score_label: Label = $"VBoxContainer/High Score Label"
@onready var start_button: Button = $"VBoxContainer/Start Button"
@onready var health_bar: TextureProgressBar = $"MarginContainer/HBoxContainer/Health Bar"

# Pause Menu
@onready var pause_menu: ColorRect = $PauseMenu
@onready var resume: Button = $PauseMenu/VBoxContainer/Resume
@onready var restart: Button = $PauseMenu/VBoxContainer/Restart

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.update_highscore.connect(update_high_score)
	EventBus.game_over.connect(show_game_over)
	EventBus.health_changed.connect(update_health)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		if start_button.visible:
			return
		
		get_tree().paused = not get_tree().paused
		pause_menu.visible = get_tree().paused

func update_high_score(value: int) -> void:
	high_score_label.text = "High Score: " + str(value)

func update_score(value: int) -> void:
	score_label.text = "Score: " + str(value)

func update_time(value: int) -> void:
	time_label.text = "Time: " + str(value)

func update_health(current_health: int, max_health: int) -> void:
	health_bar.max_value = max_health
	health_bar.value = current_health

func show_game_over() -> void:
	message_label.text = "Game Over!"
	high_score_label.show()
	message_label.show()
	
	start_button.text = "Play again"
	start_button.show()

func _on_start_button_pressed() -> void:
	message_label.hide()
	high_score_label.hide()
	start_button.hide()
	start_game.emit()


func _on_resume_pressed() -> void:
	get_tree().paused = false
	pause_menu.hide()

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
