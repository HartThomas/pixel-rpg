extends Resource

class_name LootGenerator

func generate_loot(table: LootTable) -> Item:
	# Step 1: Pick a random base item
	var base_item = table.base_items.pick_random()
	var new_item: Item = base_item.duplicate(true) # deep copy

	# Step 2: Pick a random number of abilities
	var num_abilities = randi_range(table.min_abilities, table.max_abilities)

	# Step 3: Shuffle abilities and pick
	var shuffled_abilities = table.ability_pool.duplicate()
	shuffled_abilities.shuffle()

	for i in range(num_abilities):
		new_item.abilities.append(shuffled_abilities[i])

	return new_item
