extends Node

enum WeaponType {bow, sword, hammer}
var created_items = []
var item_scene :PackedScene = load("res://scenes/ground_item.tscn")

var alt_pressed: bool = false

func create_item(type :WeaponType, position: Vector2):
	var new_item = item_scene.instantiate()
	var item_info = load("res://resources/items/sword.tres").duplicate()
	new_item.cell = position
	new_item.item_info = item_info
	created_items.append(new_item)
	get_tree().current_scene.add_child(new_item)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and Input.is_action_pressed('show_items_on_ground'):
		alt_pressed = true
		for item in created_items:
			item._on_area_2d_mouse_entered()
	elif event.is_action_released("show_items_on_ground"):
		alt_pressed = false
		for item in created_items:
			item._on_area_2d_mouse_exited()

func paused_button_pressed():
	for item in created_items:
		item.pause()
