extends Panel

var item : Item
@export var tooltip_scene : PackedScene
var tooltip_array = []
var tooltip_showing: bool = false
var sprite2
var hovering : bool = false
@export var inventory_ref : int

func _ready() -> void:
	if InventoryManager.equipped[inventory_ref].value:
		insert_item(InventoryManager.equipped[inventory_ref].value)

func insert_item(new_item):
	if item:
		ItemManager.remove_item_from_created_items_array(item)
		ItemManager.holding_item.queue_free()
		ItemManager.holding_item = null
		var item_in_inventory = item.duplicate()
		ItemManager.create_item(item_in_inventory.item_name.replace(' ', '_'), get_global_mouse_position())
		item = new_item
		InventoryManager.equipped[inventory_ref].value = new_item
		var texture = load("res://art/sprites/%s.png" % [new_item.item_name.replace(' ', '_')])
		for child in get_children():
			child.queue_free()
		var sprite = TextureRect.new()
		sprite.texture = texture
		sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		sprite.stretch_mode = TextureRect.STRETCH_SCALE
		sprite.size = Vector2(16, 16)
		add_child(sprite)
		ItemManager.item_clicked(ItemManager.created_items[ItemManager.created_items.size() - 1].item)
		_on_mouse_exited()
	else:
		item = new_item
		InventoryManager.equipped[inventory_ref].value = new_item
		var texture = load("res://art/sprites/%s.png" % [new_item.item_name.replace(' ', '_')])
		var sprite = TextureRect.new()
		sprite.texture = texture
		sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		sprite.stretch_mode = TextureRect.STRETCH_SCALE
		sprite.size = Vector2(16, 16)
		add_child(sprite)
		sprite2 = sprite
		ItemManager.remove_item_from_created_items_array(item)
		if ItemManager.holding_item:
			ItemManager.holding_item.queue_free()
		ItemManager.holding_item = null

func _on_mouse_entered() -> void:
	hovering = true
	if item:
		var tooltip = tooltip_scene.instantiate()
		tooltip.text = item.item_name
		tooltip.position = global_position + Vector2(8,-25)
		tooltip.parent_item = self
		tooltip_array.append(tooltip)
		tooltip_showing = true
		get_tree().current_scene.get_node('Gui').add_child(tooltip)
	if ItemManager.holding_item and inventory_ref < 10 and not ItemManager.holding_item.item_info.input_slots.has(InventoryManager.equipped[inventory_ref].name):
		modulate = Color.RED

func _on_mouse_exited() -> void:
	hovering=false
	if item:
		for tooltip in tooltip_array:
			tooltip.queue_free()
		tooltip_array.clear()
	modulate = Color(1,1,1,1)

#var click_cooldown : bool = false

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if ItemManager.holding_item:
			if inventory_ref >= 10 or ItemManager.holding_item.item_info.input_slots.has(InventoryManager.equipped[inventory_ref].name):
				insert_item(ItemManager.holding_item.item_info)
		elif ItemManager.holding_item:
			if inventory_ref >= 10 and not ItemManager.holding_item.item_info.input_slots.has(InventoryManager.equipped[inventory_ref].name):
				pass
		elif item:
			ItemManager.create_item(item.item_name.replace(' ', '_'), get_global_mouse_position())
			ItemManager.item_clicked(ItemManager.created_items[ItemManager.created_items.size() - 1].item)
			_on_mouse_exited()
			item = null
			InventoryManager.equipped[inventory_ref].value = null
			for child in get_children():
				child.queue_free()
	#elif event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		#click_cooldown = false
