extends Resource

class_name LootTable

@export var base_items: Array[Item] = []
@export var base_item_weights : Array[WeightedItem] = []
@export var ability_pool: Array[Ability] = []
@export var min_abilities: int = 0
@export var max_abilities: int = 2
