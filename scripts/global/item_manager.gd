extends Node

const item_types = [
	"sword", "cap", "cape", "plate_mail",
	"ring", "mittens", "boots", "pantaloons", 
	"hammer", "bow"
]

var created_items = []
var item_scene :PackedScene = load("res://scenes/ground_item.tscn")
var holding_item 
var alt_pressed: bool = false

func generate_item() -> String:
	return item_types.pick_random()

func create_item(item_info, position: Vector2):
	var new_item = item_scene.instantiate()
	new_item.cell = position
	new_item.item_info = item_info
	if GameScript.paused:
		new_item.pause()
	created_items.append({item=new_item, tooltip_array=[]})
	get_tree().current_scene.add_child(new_item)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and Input.is_action_pressed('show_items_on_ground'):
		alt_pressed = true
		for item in created_items:
			if item.item:
				item.item._on_area_2d_mouse_entered()
	elif event.is_action_released("show_items_on_ground"):
		alt_pressed = false
		for item in created_items:
			if item.item:
				item.item._on_area_2d_mouse_exited()
 
func paused_button_pressed():
	for item in created_items:
		if item.item:
			item.item.pause()

func add_tooltip_to_list(item, tooltip):
	var index = created_items.find_custom(func(index):return index.item == item)
	created_items[index].tooltip_array.append(tooltip)

func clear_tooltip_list(item):
	var index = created_items.find_custom(func(index):return index.item == item)
	for tooltip in created_items[index].tooltip_array:
		if tooltip:
			tooltip.queue_free()
	created_items[index].tooltip_array.clear()

func tooltip_clicked(tooltip):
	var index = created_items.find_custom(func(index): return index.tooltip_array.find(tooltip) != -1)
	print('picked up', created_items[index].item.picked_up)
	if created_items[index].item.picked_up:
		created_items[index].item.picked_up = false
		created_items[index].item.drop_in_world(GameScript.player_position)
		created_items[index].item.drop()
		holding_item = null
	elif created_items[index].item.on_ground and is_item_close(created_items[index].item):
		created_items[index].item.pick_up()
		holding_item = created_items[index].item
		clear_tooltip_list(created_items[index].item)
	else:
		tooltip.queue_free()
		GameScript.create_pop_up_text(created_items[index].item.position, 'Too far')

func item_clicked(item):
	var index = created_items.find_custom(func(index):return index.item == item)
	print('picked up', item.picked_up)
	if item.picked_up:
		created_items[index].item.picked_up = false
		created_items[index].item.drop_in_world(GameScript.player_position)
		created_items[index].item.drop()
		holding_item = null
	elif (item.on_ground and is_item_close(item)) or item.in_inventory:
		created_items[index].item.pick_up()
		holding_item = created_items[index].item
		clear_tooltip_list(item)
	else:
		GameScript.create_pop_up_text(item.position, 'Too far')

func remove_item_from_created_items_array(item):
	var index = created_items.find_custom(func(index):return index.item == item)
	created_items.remove_at(index)

func is_item_close(item):
	var distance = GameScript.player_position.distance_to(item.position)
	return distance <= 64
