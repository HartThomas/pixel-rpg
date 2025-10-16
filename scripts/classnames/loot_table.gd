extends Resource

class_name LootTable

@export var base_item_weights : Array[WeightedItem] = []
@export var ability_pool: Array[Ability] = []
@export var min_abilities: int = 0
@export var max_abilities: int = 2

@export var discovery_data: LootDiscoveryData

func get_revealed_loot_items(kill_count: int) -> Array[WeightedItem]:
	if not discovery_data:
		return base_item_weights
	var thresholds = discovery_data.reveal_thresholds
	var reveal_count = 0
	for threshold in thresholds:
		if kill_count >= threshold.amount_needed:
			reveal_count += 1
	#print('reveal_count: ', reveal_count,' thresholds: ',thresholds, ' kill_count: ',kill_count)
	reveal_count = clamp(reveal_count, 0, base_item_weights.size())
	return base_item_weights.slice(0, reveal_count + 1)

func how_much_info_to_reveal(kill_count : int) -> int:
	if not discovery_data:
		return 0
	var thresholds = discovery_data.reveal_thresholds
	var reveal_count = 0
	for threshold in thresholds:
		if kill_count >= threshold.amount_needed:
			reveal_count += 1
	#print('reveal_count: ', reveal_count,' thresholds: ',thresholds, ' kill_count: ',kill_count)
	reveal_count = clamp(reveal_count, 0, thresholds.size() -1)
	return thresholds[reveal_count].revealed_data

func get_loot_drop_percentages() -> Array:
	var results: Array = []
	
	if base_item_weights.is_empty():
		return results
	
	# Calculate total weight
	var total_weight := 0.0
	for entry in base_item_weights:
		total_weight += entry.weight
	
	# Avoid divide-by-zero
	if total_weight <= 0:
		return results
	
	# Calculate percentage for each entry
	for entry in base_item_weights:
		var percent := (entry.weight / total_weight) * 100.0
		results.append({
			"item": entry.item,
			"weight": entry.weight,
			"chance": percent
		})
	
	return results
