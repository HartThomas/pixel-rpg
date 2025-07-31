extends Panel

var item : Item
@export var tooltip_scene : PackedScene
var tooltip_array = []
var tooltip_showing: bool = false
var sprite2
var hovering : bool = false

func insert_item(new_item):
	item = new_item
	var texture = load("res://art/sprites/%s.png" % [new_item.item_name])
	var sprite = TextureRect.new()
	sprite.texture = texture
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_SCALE
	sprite.size = Vector2(16, 16)
	add_child(sprite)
	sprite2 = sprite

func _on_mouse_entered() -> void:
	hovering = true
	if item:
		var tooltip = tooltip_scene.instantiate()
		tooltip.text = item.item_name
		tooltip.position = global_position + Vector2(8,-25)
		tooltip.parent_item = self
		tooltip_array.append(tooltip)
		#ItemManager.add_tooltip_to_list(self, tooltip)
		tooltip_showing = true
		get_tree().current_scene.get_node('Gui').add_child(tooltip)

func _on_mouse_exited() -> void:
	hovering=false
	if item:
		for tooltip in tooltip_array:
			tooltip.queue_free()
		tooltip_array.clear()

var click_cooldown : bool = false

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if ItemManager.holding_item:
			click_cooldown = true
			insert_item(ItemManager.holding_item.item_info)
			ItemManager.remove_item_from_created_items_array(item)
			ItemManager.holding_item.queue_free()
			ItemManager.holding_item = null
		elif item:
			ItemManager.create_item(ItemManager.WeaponType.sword, get_global_mouse_position())
			ItemManager.item_clicked(ItemManager.created_items[ItemManager.created_items.size() - 1].item)
			_on_mouse_exited()
			item = null
			for child in get_children():
				child.queue_free()
	elif event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		click_cooldown = false
