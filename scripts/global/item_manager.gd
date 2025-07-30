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
	created_items.append({item=new_item, tooltip_array=[]})
	get_tree().current_scene.add_child(new_item)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and Input.is_action_pressed('show_items_on_ground'):
		alt_pressed = true
		for item in created_items:
			item.item._on_area_2d_mouse_entered()
	elif event.is_action_released("show_items_on_ground"):
		alt_pressed = false
		for item in created_items:
			item.item._on_area_2d_mouse_exited()

func paused_button_pressed():
	for item in created_items:
		item.item.pause()

func add_tooltip_to_list(item, tooltip):
	var index = created_items.find_custom(func(index):return index.item == item)
	created_items[index].tooltip_array.append(tooltip)

func clear_tooltip_list(item):
	var index = created_items.find_custom(func(index):return index.item == item)
	created_items[index].tooltip_array.clear()

func tooltip_clicked(tooltip):
	var index = created_items.find_custom(func(index): return index.tooltip_array.find(tooltip))
	if not created_items[index].item.picked_up:
		created_items[index].item.pick_up()
	else:
		created_items[index].item.picked_up = false
		created_items[index].item.drop_in_world()

var count = 0

func item_clicked(item):
	count += 1
	var index = created_items.find_custom(func(index):return index.item == item)
	print('item clikced', count, item, index)
	if not created_items[index].item.picked_up:
		created_items[index].item.pick_up()
	else:
		created_items[index].item.picked_up = false
		created_items[index].item.drop_in_world(GameScript.player_position)
