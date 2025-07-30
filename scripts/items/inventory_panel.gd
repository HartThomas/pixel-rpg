extends Panel

var item : Item
@export var tooltip_scene : PackedScene
var tooltip_array = []
var tooltip_showing: bool = false
var sprite2

func insert_item(item):
	var texture = load("res://art/sprites/%s.png" % [item.item_name])
	var sprite = TextureRect.new()
	sprite.texture = texture
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_SCALE
	sprite.size = Vector2(16, 16)
	add_child(sprite)
	sprite2 = sprite
	print(get_children())

func _on_mouse_entered() -> void:
	if item.has_meta('item_name'):
		var tooltip = tooltip_scene.instantiate()
		tooltip.text = item.item_name
		tooltip.position = Vector2(8,-25)
		tooltip.parent_item = self
		tooltip_array.append(tooltip)
		#ItemManager.add_tooltip_to_list(self, tooltip)
		tooltip_showing = true
		get_tree().current_scene.add_child(tooltip)

func _on_mouse_exited() -> void:
	if item.has_meta('item_name'):
		for tooltip in tooltip_array:
			tooltip.queue_free()
		tooltip_array.clear()
