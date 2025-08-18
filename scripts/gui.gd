extends CanvasLayer

@export var slide_distance: float = 200.0
@export var slide_duration: float = 0.5
@onready var control: Control = $Control
@onready var cooldown_progress: ProgressBar = $CooldownBorder/CooldownProgress
@onready var cooldown_texture: TextureRect = $CooldownBorder/CooldownTexture

var cooldown_showing

var start_position: Vector2
var target_position: Vector2
var is_shown: bool = false

@onready var tween := create_tween()

func _ready():
	start_position = control.position
	target_position = start_position + Vector2(slide_distance, 0)
	control.position = start_position
	cooldown_texture.texture = null

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

func change_cooldown(weapon : Weapon):
	cooldown_texture.texture = weapon.texture
	cooldown_progress.max_value = 1.0
	cooldown_showing = weapon

func _process(delta: float) -> void:
	if cooldown_showing:
		cooldown_progress.value = CooldownManager.get_cooldown_progress(cooldown_showing, 'attack')
		var bar = cooldown_progress
		var progress = 1.0 - CooldownManager.get_cooldown_progress(cooldown_showing, 'attack')
		var steps = 5
		var snapped = round(progress * steps) / steps
		bar.value = snapped * bar.max_value
