extends Item

class_name Weapon

@export var base_damage: int
@export var cooldown: float
var final_damage : int
@export_enum('sword', 'hammer', 'bow', 'bomb') var animation_type  = ''

func apply_modifiers():
	final_damage = base_damage
	for ability in abilities:
		ability.apply_to_weapon(self)

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
	if (data == 0 or data == 3 or data == 2) and base_damage:
		info.stats = 'Base damage: ' + str(base_damage)
	if (data == 0 or data == 3 or data == 2) and final_damage != base_damage and info.stats:
		info.stats += '\nFinal damage: ' + str(final_damage)
	if (data == 0 or data == 3 or data == 2) and cooldown:
		if not info.stats:
			info.stats = ''
		info.stats += '\nCooldown: ' + str(cooldown)
	info.unique = unique
	return info
