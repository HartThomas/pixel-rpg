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

func create_tooltip_info() -> Dictionary:
	var info: Dictionary = {}
	if item_name:
		info.name = item_name.capitalize()
	if type:
		info.type = type.capitalize()
	if abilities.size() > 0:
		info.affixes = ''
		for ability in abilities:
			info.affixes += ability.create_tooltip_info() + '\n'
	if description:
		info.description = description
	if texture:
		info.icon = texture
	info.unique = unique
	return info
