extends Item

class_name Armour

@export var base_armour: int
var final_armour : int

func apply_modifiers():
	final_armour = base_armour
	for ability in abilities:
		ability.apply_to_armour(self)

func create_tooltip_info(data: what_to_show = what_to_show.full_items) -> Dictionary:
	var info: Dictionary = {}
	if (data == 0 or data == 1 or data == 2) and item_name :
		info.name = item_name.capitalize()
	if (data == 0 or data == 1 or data == 2) and type:
		info.type = type.capitalize()
	if (data == 0 or data == 2) and abilities.size() > 0:
		info.affixes = ''
		for ability in abilities:
			info.affixes += ability.create_tooltip_info() + '\n'
	if data == 0 and description:
		info.description = description
	if texture:
		info.icon = texture
	if (data == 0 or data == 3 or data == 2) and base_armour:
		info.stats = 'Base damage: ' + str(base_armour)
	if (data == 0 or data == 3 or data == 2) and final_armour != base_armour and info.stats:
		info.stats += '\nFinal damage: ' + str(final_armour)
	info.unique = unique
	return info
