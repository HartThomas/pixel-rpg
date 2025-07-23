extends CanvasLayer

@export var slide_distance: float = 200.0
@export var slide_duration: float = 0.5
@onready var control: Control = $Control

var start_position: Vector2
var target_position: Vector2
var is_shown: bool = false

@onready var tween := create_tween()

func _ready():
	start_position = control.position
	target_position = start_position + Vector2(slide_distance, 0)
	control.position = start_position

func show_gui():
	if is_shown: return
	is_shown = true
	tween.kill()
	tween = create_tween()
	tween.tween_property(control, "position", target_position, slide_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func hide_gui():
	if not is_shown: return
	is_shown = false
	tween.kill()
	tween = create_tween()
	tween.tween_property(control, "position", start_position, slide_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
