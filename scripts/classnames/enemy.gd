extends Resource

class_name Enemy

@export var health: int = 20
@export var enemy_name : String = 'bogman'
@export var texture :Texture2D
@export var position : Vector2i = Vector2i(6,6)
@export var speed: float = 5.0
@export var loot_table : LootTable
