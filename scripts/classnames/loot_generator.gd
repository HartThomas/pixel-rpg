extends Resource

class_name LootGenerator

func generate_loot(table: LootTable) -> Item:
	var base_item = table.base_items.pick_random()
	var new_item: Item = base_item.duplicate(true)
	var valid_abilities : Array[Ability] = []
	for ability in table.ability_pool:
		if _ability_is_valid_for_item(ability, new_item):
			valid_abilities.append(ability)
	var num_abilities = randi_range(table.min_abilities, table.max_abilities)
	for i in range(num_abilities):
		var chosen = pick_weighted(valid_abilities)
		if chosen and chosen not in new_item.abilities:
			new_item.abilities.append(chosen)
	if new_item is Weapon or new_item is Armour:
		new_item.apply_modifiers()
	return new_item

func _ability_is_valid_for_item(ability: Ability, item: Item) -> bool:
	if ability.target_type == "Any":
		return true
	if ability.target_type == "Weapon" and item is Weapon:
		return true
	#if ability.target_type == "Armor" and item is Armor:
		#return true
	#if ability.target_type == "Consumable" and item is Consumable:
		#return true
	return false

func pick_weighted(pool: Array[Ability]) -> Ability:
	var total_weight = 0
	for ability in pool:
		total_weight += ability.weight
	var roll = randi_range(1, total_weight)
	var running_total = 0
	for ability in pool:
		running_total += ability.weight
		if roll <= running_total:
			return ability
	return null
