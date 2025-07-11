extends Node

var enemies : Array[AnimatedSprite2D]
const enemy_scene : PackedScene  = preload("res://scenes/enemy_animatable_sprite.tscn")

func create_enemies(amount:int, enemy_name:String = 'bogman'):
	for i in range(amount):
		var enemy = load('res://resources/enemies/%s.tres' % [enemy_name])
		var new_enemy = enemy_scene.instantiate()
		new_enemy.enemy_data = enemy
		for j in get_tree().current_scene.lights.size():
			new_enemy.point_lights.append(get_tree().current_scene.lights[j])
		enemies.append(new_enemy)
		get_tree().current_scene.add_child(new_enemy)

func move_enemy(index :int, direction: Vector2):
	enemies[index].position = ((enemies[index].position /32) + direction) * 32
