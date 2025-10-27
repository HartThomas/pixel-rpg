extends Node

var equipped : Array = [
	{name='head', value=null},
	{name= "shoulders",value=null},
	{name= "torso",value=null},
	{name= "hands",value=null},
	{name= "legs",value=null},
	{name= "feet",value=null},
	{name= "left_jewelry",value=null},
	{name= "right_jewelry",value=null},
	{name= "left_hand",value=null},
	{name= "right_hand",value=null},
]

var inventory_slots: Array = []

func _ready() -> void:
	for i in range(32):
		equipped.append({name= 'slot%s' % [i],value=null})
	var sword_resource = load("res://resources/items/bow.tres")
	sword_resource.apply_modifiers()
	equipped[8].value = sword_resource 
	self.call_deferred('record_inventory_slots')

func record_inventory_slots():
	inventory_slots = get_tree().get_nodes_in_group('inventory_slots')
	inventory_slots.sort_custom(func (a,b): return a.inventory_ref < b.inventory_ref)
	for i in range(inventory_slots.size()):
		equipped[i].slot = inventory_slots[i]

func find_free_inventory_slot(item : Item):
	for i in range(equipped.size()):
		if (item.input_slots.has(equipped[i].name) and not equipped[i].value) or (i >= 10 and not equipped[i].value):
			return equipped[i]
	return null

func equipped_items() -> Array[Item]:
	var item_array : Array[Item] = []
	for i in range(9): 
		if equipped[i].value:
			item_array.append(equipped[i].value)
	return item_array
