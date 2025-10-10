extends Animatable

class_name Player

@export var max_health : int = 100
@export var health: int = 100
@export var speed: float = 5.0
@export var armour: int = 0

func update_armour_value() -> void:
	var new_armour_value : int = 0
	var items = InventoryManager.equipped_items()
	for item in items:
		if item.get('base_armour'):
			new_armour_value += item.get('base_armour')
	armour = new_armour_value
