extends Camera2D

@export var max_trauma: float = 1.0
@export var max_offset: Vector2 = Vector2(15.0, 15.0)
@export var max_rotation: float = 2.0
@export var decay_rate: float = 2.0
@export var noise_speed: float = 50.0


var trauma: float = 0.0
var noise: FastNoiseLite = FastNoiseLite.new()
var noise_time: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ignore_rotation = false
	noise.seed = randi()
	print(noise.seed)
	EventBus.camera_shake.connect(add_trauma)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if trauma <= 0.0:
		offset = Vector2.ZERO
		rotation = 0.0
		return
	
	trauma = maxf(trauma - decay_rate * delta, 0.0)
	
	noise_time +=  noise_speed * delta
	
	var shake: float = trauma * trauma
	
	offset.x = max_offset.x * shake * noise.get_noise_2d(noise_time, 0.0)
	offset.y = max_offset.y * shake * noise.get_noise_2d(noise_time, 100.0)
	rotation = deg_to_rad(max_rotation) * shake * noise.get_noise_2d(noise_time, 200.0)
	

func add_trauma(amount: float):
	trauma = minf(trauma + amount, max_trauma)
	
	if trauma > max_trauma:
		return
