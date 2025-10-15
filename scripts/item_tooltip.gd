extends NinePatchRect

@onready var icon: TextureRect = $VBoxContainer/HBoxContainer/IconContainer/Icon
@onready var name_label: Label = $VBoxContainer/HBoxContainer/VBoxContainer/Name
@onready var type_label: Label = $VBoxContainer/HBoxContainer/VBoxContainer/Type
@onready var stats_label: RichTextLabel = $VBoxContainer/Stats
@onready var affix_label: RichTextLabel = $VBoxContainer/Affixes
@onready var description_label: Label = $VBoxContainer/Description


func set_item_data(data: Dictionary) -> void:
	icon.texture = data.get("icon", null)
	name_label.text = data.get("name", "Unknown Item")
	name_label.add_theme_color_override("font_color", Color('GREEN') if data.unique else Color('d6b878'))
	type_label.text = data.get("type", "")
	stats_label.text = data.get("stats", "")
	affix_label.text = data.get("affixes", "")
	description_label.text = data.get("description", "")
	stats_label.visible = stats_label.text != ""
	affix_label.visible = affix_label.text != ""
	if description_label.text == "":
		description_label.queue_free()
	await get_tree().process_frame
	#set_scale_of_text()
	custom_minimum_size = $VBoxContainer.get_combined_minimum_size() + Vector2(16, 16)
	size = custom_minimum_size

func set_scale_of_text() ->  void:
	name_label.scale = Vector2(0.5, 0.5)
	type_label.scale = Vector2(0.5, 0.5)
	stats_label.scale = Vector2(0.5, 0.5)
	affix_label.scale = Vector2(0.5, 0.5)
	#description_label.scale = Vector2(0.05, 0.05)

func _ready() -> void:
	pass
