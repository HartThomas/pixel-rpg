extends 'res://scripts/animatable_sprite.gd'

var enemy_data : Enemy

func _ready() -> void:
	print(enemy_data)
	sprite_name = enemy_data.enemy_name
	super._ready()
	position = ((enemy_data.position * 32) + Vector2i(16,16))
