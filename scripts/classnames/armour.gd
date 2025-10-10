extends Item

class_name Armour

@export var base_armour: int
var final_armour : int

func apply_modifiers():
	final_armour = base_armour
	for ability in abilities:
		ability.apply_to_armour(self)

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
	if base_armour:
		info.stats = 'Base armour: ' + str(base_armour)
	if final_armour != base_armour and info.stats:
		info.stats += '\nFinal armour: ' + str(final_armour)
	info.unique = unique
	return info
