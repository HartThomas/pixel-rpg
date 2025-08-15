extends Node

var enemies : Array[AnimatedSprite2D]
const enemy_scene : PackedScene  = preload("res://scenes/enemy_animatable_sprite.tscn")
var player_scene 
var claimed_tiles = {}

var paused: bool = false

func create_enemies(amount:int, enemy_name:String = 'bogman'):
	for i in range(amount):
		var enemy = load('res://resources/enemies/%s.tres' % [enemy_name]) as Enemy
		var enemy_stats = enemy.duplicate()
		var new_enemy = enemy_scene.instantiate()
		enemy_stats.position = Vector2i(enemy.position.x+i, enemy.position.y)
		new_enemy.enemy_data = enemy_stats
		for j in get_tree().current_scene.lights.size():
			new_enemy.point_lights.append(get_tree().current_scene.lights[j])
		enemies.append(new_enemy)
		GameScript.add_entity_to_cell(enemy_stats.position, new_enemy)
		GameScript.astar_grid.set_point_solid(enemy_stats.position, true)
		get_tree().current_scene.add_child(new_enemy)

func move_enemy(entity, direction: Vector2, current: Vector2):
	if entity:
		var direction_tile = (direction/32).floor()
		if direction_tile in claimed_tiles:
			return
		if GameScript.astar_grid.is_point_solid((direction / 32).floor()):
			if entity.path.size() > 0:
				var target = entity.path.pop_back()
				entity.path = GameScript.astar_grid.get_id_path(current, target)
				if entity.path.size() >0:
					direction = entity.path.pop_front() * 32 + Vector2(16,16)
					direction_tile = (direction/32).floor()
					claimed_tiles[direction_tile] = true
					entity.position = direction
					GameScript.update_cells_based_on_entity_movement((current/32).floor(), (direction/32).floor(), entity)
					#GameScript.astar_grid.set_point_solid((current/32).floor(), false)
					#GameScript.astar_grid.set_point_solid((direction/32).floor(), true)
		elif direction:
			claimed_tiles[direction_tile] = true
			entity.position = direction
			GameScript.update_cells_based_on_entity_movement((current/32).floor(), (direction/32).floor(), entity)
			#GameScript.astar_grid.set_point_solid((current/32).floor(), false)
			##GameScript.astar_grid.set_point_solid((direction/32).floor(), true)

func move_player() -> void:
		if player_scene.path.size() > 0:
			var next_tile = player_scene.path.pop_front()
			#move_enemy(player_scene,next_tile* 32 + Vector2i(16,16),player_scene.position)
			if next_tile in claimed_tiles:
				return # This blocks a move, perhaps there should be something that happens to the player when they get blocked
			if GameScript.astar_grid.is_point_solid(next_tile):
				if player_scene.path.size() > 0:
					var target = player_scene.path.pop_back()
					player_scene.path = GameScript.astar_grid.get_id_path((player_scene.position / 32).floor(), target)
					if player_scene.path.size() > 0:
						next_tile = player_scene.path.pop_front() 
						claimed_tiles[next_tile] = true
						player_scene.position = next_tile * 32 + Vector2i(16,16)
						GameScript.update_cells_based_on_player_movement(player_scene.position,player_scene)
			elif next_tile:
				claimed_tiles[next_tile] = true
				player_scene.position = next_tile * 32 + Vector2i(16,16)
				GameScript.update_cells_based_on_player_movement(player_scene.position,player_scene)

func _process(delta: float) -> void:
	if not paused:
		#if player_scene.path.size() > 0:
			#if player_scene.move_timer >= player_scene.move_delay:
				#player_scene.move_timer = 0.0
				#var next_tile = player_scene.path.pop_front()
				##move_enemy(player_scene,next_tile* 32 + Vector2i(16,16),player_scene.position)
				#if next_tile in claimed_tiles:
					#return # This blocks a move, perhaps there should be something that happens to the player when they get blocked
				#if GameScript.astar_grid.is_point_solid(next_tile):
					#if player_scene.path.size() > 0:
						#var target = player_scene.path.pop_back()
						#player_scene.path = GameScript.astar_grid.get_id_path((player_scene.position / 32).floor(), target)
						#if player_scene.path.size() > 0:
							#next_tile = player_scene.path.pop_front() 
							#claimed_tiles[next_tile] = true
							#player_scene.position = next_tile * 32 + Vector2i(16,16)
							#GameScript.update_cells_based_on_player_movement(player_scene.position,player_scene)
				#elif next_tile:
					#claimed_tiles[next_tile] = true
					#player_scene.position = next_tile * 32 + Vector2i(16,16)
					#GameScript.update_cells_based_on_player_movement(player_scene.position,player_scene)
		for enemy in enemies:
			if enemy:
				if enemy.state == 1:
					if enemy.move_timer >= enemy.move_delay:
						enemy.move_timer = 0.0
						var next_tile = enemy.path.pop_front()
						if next_tile:
							move_enemy(enemy, next_tile * 32 + Vector2i(16,16), enemy.position) 
						recalculate_path(enemy)
		claimed_tiles.clear()

func recalculate_path(entity, to = Vector2i(GameScript.player_position/32)):
	var from = Vector2i(entity.position / 32)
	if GameScript.astar_grid.is_in_bounds(from.x, from.y) and GameScript.astar_grid.is_in_bounds(to.x, to.y):
		entity.path = GameScript.astar_grid.get_id_path(from, to)
		if entity.path.size() > 1 and entity.path[0] == from:
			entity.path.remove_at(0)
			entity.path.pop_back()
	else:
		print("Missing point in AStar:", from, to)
		entity.path = []

func paused_button_pressed():
	paused = !paused
