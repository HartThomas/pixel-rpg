extends 'res://scripts/animatable_sprite.gd'

var path: Array[Vector2i] = []
var move_speed = 5.0 
var move_timer = 0.0
var move_delay = 1.0 / move_speed

func _process(delta: float) -> void:
	super._process(delta)
	if path.size() > 0:
		move_timer += delta
		#if move_timer >= move_delay:
			#move_timer = 0.0
			#var next_tile = path.pop_front()
			#if GameScript.astar_grid.is_point_solid(next_tile):
				#if path.size() > 0:
					#var target = path.pop_back()
					#path = GameScript.astar_grid.get_id_path((position / 32).floor(), target)
					#if path.size() > 0:
						#next_tile = path.pop_front()
						#position = next_tile * 32 + Vector2i(16,16)
						#GameScript.astar_grid.set_point_solid(GameScript.player_position, false)
						#GameScript.player_position = position
						#GameScript.astar_grid.set_point_solid(GameScript.player_position, true)
			#elif next_tile:
				#position = next_tile * 32 + Vector2i(16,16)
				#GameScript.astar_grid.set_point_solid(GameScript.player_position, false)
				#GameScript.player_position = position
				#GameScript.astar_grid.set_point_solid(GameScript.player_position, true)

func _ready() -> void:
	super._ready()

func move_player(target: Vector2i):
	var current_grid = (position / 32).floor()
	path = GameScript.astar_grid.get_id_path(current_grid, target)
