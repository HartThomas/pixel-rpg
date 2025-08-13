extends Resource

class_name Ability

@export var name: String 
@export var description: String
@export var special_effect: String = ""
@export var damage_bonus: int = 0
@export var attack_speed_bonus: float = 0.0
@export var weight: int = 1
@export_enum("Any", "Weapon", "Armor", "Consumable") var target_type: String = "Any"

func apply_to_weapon(weapon: Weapon):
	weapon.final_damage += damage_bonus
