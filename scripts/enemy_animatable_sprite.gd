extends 'res://scripts/animatable_sprite.gd'

var enemy_data : Enemy

var path: Array[Vector2i] = []

var move_timer = 0.0
var move_delay: float
var cell_size: int = 32
var recalc_path_timer: float = 0.0

enum {
	IDLE,
	AGGRO,
	ATTACK
}

var state = IDLE

func _ready() -> void:
	sprite_name = enemy_data.enemy_name
	super._ready()
	move_delay = 1.0 / enemy_data.speed
	position = ((enemy_data.position * 32) + Vector2i(16,16))

func _process(delta: float) -> void:
	super._process(delta)
	if position.distance_to(GameScript.player_position) <200:
		if state != AGGRO:
			state = AGGRO
			recalculate_path()
	else:
		state = IDLE
	match state: 
		AGGRO:
			recalc_path_timer += delta
			if recalc_path_timer >= 1.0: # recalc path every second
				recalc_path_timer = 0.0
				recalculate_path()
			#print(path)
			#path = GameScript.get_straight_line_path(position / 32, (GameScript.player_position/32) - ((GameScript.player_position/32) - (position / 32)).normalized())
	if path.size() > 0:
		move_timer += delta
		print(path, move_timer)
		if move_timer >= move_delay:
			move_timer = 0.0
			var next_tile = path.pop_front()
			position = next_tile * cell_size + Vector2i(16,16)
			print(position, path, next_tile, 'path')
			recalculate_path()

func recalculate_path():
	var from = Vector2i(position / 32)
	var to = Vector2i((GameScript.player_position/32) - ((GameScript.player_position/32) - (position / 32)).normalized())
	print(from, to, 'fromto')
	if GameScript.astar_grid.is_in_bounds(from.x, from.y) and GameScript.astar_grid.is_in_bounds(to.x, to.y):
		path = GameScript.astar_grid.get_id_path(from, to)
		if path.size() > 1 and path[0] == from:
			path.remove_at(0)
	else:
		print("Missing point in AStar:", from, to)
		path = []
	#path = GameScript.get_straight_line_path(position / 32, (GameScript.player_position/32) - ((GameScript.player_position/32) - (position / 32)).normalized())
	print("Recalculated path:", path)
