extends Sprite2D

@export var item_info : Resource
var on_ground: bool = true
var cell : Vector2
var spinning: bool = false
var spin_speed := 10.0 
var spin_angle := 0.0 
var paused: bool = false

@export var rise_height := 32.0
@export var arc_duration := 0.4
@export var arc_horizontal_offset := Vector2(12, 0)

@export var tooltip_scene :PackedScene
var tooltip_showing : bool = false
var tooltip_array = []
var tween = create_tween()

func _ready() -> void:
	texture = item_info.texture
	var offset_range = Vector2(32,32) / 2.0 - Vector2(4, 4)
	var random_offset = Vector2(
		randf_range(-offset_range.x, offset_range.x),
		randf_range(-offset_range.y, offset_range.y)
	)
	global_position = cell + random_offset  
	if on_ground:
		drop_in_world()

func drop_in_world():
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	spinning = true
	var peak_position = position - Vector2(0, rise_height) + arc_horizontal_offset * (randf_range(-0.5, 0.5))
	tween.tween_property(self, "position", peak_position, arc_duration / 2.0)
	tween.tween_property(self, "position", position, arc_duration / 2.0)
	tween.tween_callback( Callable(self, "_on_drop_finished")).set_delay(arc_duration)

func _on_drop_finished():
	spinning = false

var random_spin = randf_range(0.5,1.5)

func _process(delta: float) -> void:
	if not paused:
		if spinning:
			spin_angle += delta * spin_speed
			skew = spin_angle * 2 * random_spin

func show_tooltip(item_info :Item):
	var tooltip = tooltip_scene.instantiate()
	tooltip.text = item_info.item_name
	tooltip.position = position + Vector2(0,-25)
	tooltip_array.append(tooltip)
	tooltip_showing = true
	get_tree().current_scene.add_child(tooltip)

func _on_area_2d_mouse_entered() -> void:
	if not tooltip_showing:
		show_tooltip(item_info)

func _on_area_2d_mouse_exited() -> void:
	if not ItemManager.alt_pressed:
		for tt in tooltip_array:
			tt.queue_free()
		tooltip_array.clear()
		tooltip_showing = false

func pause():
	if not paused:
		tween.pause()
	else:
		tween.play()
	paused = !paused
