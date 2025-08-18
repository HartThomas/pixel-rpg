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
	await get_tree().process_frame
	size = label.size + Vector2(30,0)
	var global_position = position
	position = Vector2(global_position.x-size.x/2,global_position.y)
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
