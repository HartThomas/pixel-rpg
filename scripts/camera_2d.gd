extends Camera2D

var zoom_target: Vector2

var drag_start_mouse_pos= Vector2.ZERO
var drag_start_camera_pos= Vector2.ZERO
var is_dragging: bool = false

func _ready() -> void:
	zoom_target = zoom

func _process(delta: float) -> void:
	zoom_camera(delta)
	click_and_drag()

func zoom_camera(delta):
	if Input.is_action_just_pressed("camera_zoom_in"):
		zoom_target *=  1.1
	if Input.is_action_just_pressed("camera_zoom_out"):
		zoom_target*= 0.9
	zoom = zoom.slerp(zoom_target, 15 * delta)

func click_and_drag():
	if !is_dragging and Input.is_action_just_pressed('camera_pan'):
		drag_start_mouse_pos = get_viewport().get_mouse_position()
		drag_start_camera_pos = position
		is_dragging = true
	if is_dragging and Input.is_action_just_released('camera_pan'):
		is_dragging = false
	if is_dragging:
		var move_vector = get_viewport().get_mouse_position() - drag_start_mouse_pos
		position = drag_start_camera_pos - move_vector * 1/zoom.x
