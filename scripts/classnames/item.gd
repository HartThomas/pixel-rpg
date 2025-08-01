extends Resource

class_name Item

@export var texture: Texture2D
@export var item_name: String
@export var type: String

#func _init(name, tex):
	#texture = tex
	#item_name = name
