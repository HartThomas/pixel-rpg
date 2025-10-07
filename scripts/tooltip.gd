extends NinePatchRect

@export var text : String = ''
@onready var label: Label = $Label
var parent_item
signal pick_up
var click_cooldown:bool = false

func _ready() -> void:
	label.text = text
	call_deferred('_finalize_layout')

func _finalize_layout() -> void:
	await(get_tree().process_frame)
	label.queue_redraw()
	await get_tree().process_frame
	var label_size = label.get_minimum_size()
	size = label_size + Vector2(11, 8)
	#position -= Vector2(size.x / 2, size.y)
	modulate.a = 0.75

func _on_mouse_entered() -> void:
	modulate.a = 1.0

func _on_mouse_exited() -> void:
	modulate.a = 0.75

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not click_cooldown:
			click_cooldown = true
			ItemManager.tooltip_clicked(self)
	elif event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			click_cooldown = false

func update_text():
	label.text = text
	var label_size = label.get_minimum_size()
	size = label_size + Vector2(11, 8)
