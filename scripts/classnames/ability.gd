extends Resource

class_name Ability

@export var ability_name: String 
@export var description: String
@export var special_effect: String = ""
@export var damage_bonus: int = 0
@export var attack_speed_bonus: float = 0.0
@export var weight: int = 1
@export_enum("Any", "Weapon", "Armor", "Consumable") var target_type: String = "Any"

func apply_to_weapon(weapon: Weapon):
	weapon.final_damage += damage_bonus

func create_tooltip_info() -> String:
	var info:  String = ''
	if ability_name:
		info += ability_name.capitalize() + ': '
	if description:
		info += description
	if special_effect:
		info+= special_effect
	return info
