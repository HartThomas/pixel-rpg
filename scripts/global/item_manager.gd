extends Node

enum WeaponType {bow, sword, hammer}
var created_items = []
var item_scene :PackedScene = load("res://scenes/ground_item.tscn")

func create_item(type :WeaponType, position: Vector2):
	var new_item = item_scene.instantiate()
	var item_info = load("res://resources/items/sword.tres").duplicate()
	new_item.cell = position
	new_item.item_info = item_info
	get_tree().current_scene.add_child(new_item)
