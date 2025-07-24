extends NinePatchRect

@export var text : String = ''
@onready var label: Label = $Label

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
