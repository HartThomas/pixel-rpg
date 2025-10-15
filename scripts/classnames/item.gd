extends Resource

class_name Item

@export var texture: Texture2D
@export var item_name: String
@export var type: String
@export var input_slots: Array[String] = []
@export var abilities: Array[Ability] = []
@export var description : String
@export var unique : bool = false

#func _init(name, tex):
	#texture = tex
	#item_name = name

enum what_to_show {full_items,
names,
affixes,
stats,
likelihood}

func create_tooltip_info(data: what_to_show = what_to_show.full_items) -> Dictionary:
	var info: Dictionary = {}
	if (data == 0 or data == 1) and item_name :
		info.name = item_name.capitalize()
	if (data == 0 or data == 1) and type:
		info.type = type.capitalize()
	if (data == 0 or data == 2) and abilities.size() > 0:
		info.affixes = ''
		for ability in abilities:
			info.affixes += ability.create_tooltip_info() + '\n'
	if data == 0 and description:
		info.description = description
	if texture:
		info.icon = texture
	info.unique = unique
	return info
