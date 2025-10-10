extends Item

class_name Weapon

@export var base_damage: int
@export var cooldown: float
var final_damage : int
@export_enum('sword', 'hammer', 'bow') var animation_type  = ''

func apply_modifiers():
	final_damage = base_damage
	for ability in abilities:
		ability.apply_to_weapon(self)

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
	if base_damage:
		info.stats = 'Base damage: ' + str(base_damage)
	if final_damage != base_damage and info.stats:
		info.stats += '\nFinal damage: ' + str(final_damage)
	if cooldown:
		if not info.stats:
			info.stats = ''
		info.stats += '\nCooldown: ' + str(cooldown)
	info.unique = unique
	return info
