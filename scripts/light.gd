extends PointLight2D

var light_position = Vector2.ZERO
@export var light_speed = 200.0

func _process(delta: float) -> void:
	var input = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		input.x += 1.0
	if Input.is_action_pressed("ui_left"):
		input.x -= 1.0
	if Input.is_action_pressed("ui_down"):
		input.y += 1.0
	if Input.is_action_pressed("ui_up"):
		input.y -= 1.0

	light_position += input * light_speed * delta
	position = light_position


@export_range(0.5, 2.0, 0.01) var min_energy = 0.8
@export_range(0.5, 2.0, 0.01) var max_energy = 1.2
@export var flicker_speed = 0.05 

func _ready():
	flicker()

func flicker():
	var next_energy = randf_range(min_energy, max_energy)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "energy", next_energy, flicker_speed).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(Callable(self, "flicker"))
