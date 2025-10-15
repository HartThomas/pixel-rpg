extends CanvasLayer

@export var tooltip_scene : PackedScene
@onready var v_box_container: VBoxContainer = $TextureRect/ScrollContainer/VBoxContainer
@onready var texture_rect: TextureRect = $TextureRect

var is_shown: bool = false
var start_position
var target_position
var slide_duration := 1.0

var enemy_array : Array = ['bogman']
var items : Array[WeightedItem] = []
@onready var tween := create_tween()

func _ready() -> void:
	start_position = texture_rect.position
	target_position = Vector2(480.0,0.0)
	var label = Label.new()
	label.text = 'Nothing here yet... try killing'
	label.add_theme_color_override('font_color', Color('d6b878'))
	label.add_theme_font_size_override('font_size', 8)
	v_box_container.add_child(label)

func show_gui():
	if is_shown: return
	is_shown = true
	tween.kill()
	tween = create_tween()
	tween.tween_property(texture_rect, "position", target_position, slide_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func hide_gui():
	if not is_shown: return
	is_shown = false
	tween.kill()
	tween = create_tween()
	tween.tween_property(texture_rect, "position", start_position, slide_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

func refresh(enemy: Enemy, number_killed:int) -> void:
	var table = load("res://resources/loot_tables/%s.tres" % [enemy.name]) as LootTable
	var new_items = table.get_revealed_loot_items(number_killed) as Array[WeightedItem]
	print(new_items)
	if arrays_equal(items, new_items):
		return
	items = new_items
	var children = v_box_container.get_children()
	for child in children:
		child.queue_free()
	for item in items:
		var tooltip = tooltip_scene.instantiate()
		#tooltip.parent_item = self
		v_box_container.add_child(tooltip)
		var tooltip_info = item.item.create_tooltip_info(2)
		tooltip.call_deferred("set_item_data", tooltip_info)

func _on_button_button_down() -> void:
	if is_shown:
		hide_gui()
	else:
		show_gui()

func arrays_equal(a: Array, b: Array) -> bool:
	if a.size() != b.size():
		return false
	
	for i in a.size():
		var val_a = a[i]
		var val_b = b[i]
		
		# If both are arrays, compare recursively
		if val_a is Array and val_b is Array:
			if not arrays_equal(val_a, val_b):
				return false
		
		# If both are dictionaries, compare recursively too
		elif val_a is Dictionary and val_b is Dictionary:
			if not dictionaries_equal(val_a, val_b):
				return false
		
		# Otherwise, compare directly
		elif val_a != val_b:
			return false
	
	return true

func dictionaries_equal(a: Dictionary, b: Dictionary) -> bool:
	if a.size() != b.size():
		return false
	
	for key in a.keys():
		if not b.has(key):
			return false
		
		var val_a = a[key]
		var val_b = b[key]
		
		if val_a is Array and val_b is Array:
			if not arrays_equal(val_a, val_b):
				return false
		elif val_a is Dictionary and val_b is Dictionary:
			if not dictionaries_equal(val_a, val_b):
				return false
		elif val_a != val_b:
			return false
	
	return true
