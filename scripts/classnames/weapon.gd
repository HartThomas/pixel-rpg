extends Item

class_name Weapon

@export var base_damage: int
var final_damage : int

func apply_modifiers():
	final_damage = base_damage
	for ability in abilities:
		ability.apply_to_weapon(self)
