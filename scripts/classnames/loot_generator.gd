extends Resource

class_name LootGenerator

func generate_loot(table: LootTable) -> Item:
	var base_item = pick_weighted(table.base_item_weights).item
	var new_item: Item = base_item.duplicate(true)
	if not new_item.unique:
		var valid_abilities : Array[Ability] = []
		for ability in table.ability_pool:
			if _ability_is_valid_for_item(ability, new_item):
				valid_abilities.append(ability)
		var num_abilities = randi_range(table.min_abilities, table.max_abilities)
		for i in range(num_abilities):
			if valid_abilities.is_empty():
				break
			var chosen = pick_weighted(valid_abilities)
			new_item.abilities.append(chosen)
			valid_abilities.erase(chosen)
	if new_item is Weapon or new_item is Armour:
		new_item.apply_modifiers()
	return new_item
	
func _ability_is_valid_for_item(ability: Ability, item: Item) -> bool:
	match ability.target_type:
		"Any": return true
		"Weapon": return item is Weapon
		"Armour": return item is Armour
		_: return false 

func pick_weighted(pool: Array) -> Object:
	var total_weight = 0
	for i in pool:
		total_weight += i.weight
	var roll = randf() * total_weight
	var running_total = 0
	for i in pool:
		running_total += i.weight
		if roll <= running_total:
			return i
	return null
