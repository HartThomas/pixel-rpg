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

func _ready() -> void:
	for i in range(32):
		equipped.append({name= 'slot%s' % [i],value=null})
	var sword_resource = load("res://resources/items/sword.tres")
	equipped[8].value = sword_resource
