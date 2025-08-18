extends Node

var tile_defs = {
	1: { "type": "tree", "size": Vector2i(1, 2),"walkable": false },
	2: { "type": "rock", "size": Vector2i(1, 2), "walkable": false },
	3: { "type": "signpost", "size": Vector2i(1, 1), "walkable": true },
	4: { type= 'nothing', size= Vector2i(1, 1), "walkable"= true},
	5: { type= 'ruin', size= Vector2i(1, 1), "walkable"= false},
}

var paused: bool = false

var tile_weights = {
	1: 5,  # common
	2: 2,  # uncommon
	3: 1,   # rare
	4: 6,
}

var player_position: Vector2

var level_data = []
const width = 40
const height = 40
const cell_size = 32
var astar_grid : AStarGrid2D

func can_place_tile(id: int, x: int, y: int, occupied: Array) -> bool:
	if not tile_defs.has(id):
		return false
	var size = tile_defs[id]["size"]
	for dy in range(size.y):
		for dx in range(size.x):
			var gx = x + dx
			var gy = y + dy
			if gx >= width or gy >= height:
				return false
			if occupied[gy][gx]:
				return false
	return true

func mark_occupied(id: int, x: int, y: int, occupied: Array):
	var size = tile_defs[id]["size"]
	for dy in range(size.y):
		for dx in range(size.x):
			var gx = x + dx
			var gy = y + dy
			occupied[gy][gx] = true

func generate_level_data():
	level_data.clear()
	var occupied = []
	for y in range(height):
		occupied.append([])
		for x in range(width):
			occupied[y].append(false)
	var rows_top_down = []
	for y in range(height):
		var row = []
		for x in range(width):
			var tile_id: int
			if x == 0 or y == 0 or x == width - 1 or y == height - 1:
				tile_id = 5  
			elif occupied[y][x]:
				tile_id = 4  
			else:
				var id = _pick_random_tile_id()
				if can_place_tile(id, x, y, occupied):
					tile_id = id
					mark_occupied(id, x, y, occupied)
				else:
					tile_id = 0 
			row.append({
				"terrain": tile_id,
				"entity": null
			})
		rows_top_down.append(row)
	level_data = rows_top_down
	var astar = AStarGrid2D.new()
	astar.region = Rect2i(0, 0, width, height)
	astar.cell_size = Vector2(1, 1)
	astar.update()
	for y in range(height):
		for x in range(width):
			var pos = Vector2i(x, y)
			var cell = level_data[y][x]
			var solid = not can_player_move_here(pos)
			#if pos == player_position:
				#solid = true
			astar.set_point_solid(pos, solid)
	astar_grid = astar

func _pick_random_tile_id() -> int:
	var total_weight = 0
	for weight in tile_weights.values():
		total_weight += weight
	var roll = randi() % total_weight
	var accum = 0
	for id in tile_weights.keys():
		accum += tile_weights[id]
		if roll < accum:
			return id
	return tile_weights.keys()[0]

func get_straight_line_path(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	var line: Array[Vector2i] = []
	var x0 = start.x
	var y0 = start.y
	var x1 = end.x
	var y1 = end.y

	var dx = abs(x1 - x0)
	var dy = -abs(y1 - y0)
	var sx = 1 if x0 < x1 else -1
	var sy = 1 if y0 < y1 else -1
	var err = dx + dy

	while true:
		var current = Vector2i(x0, y0)
		if current != start:
			#print({current= current,start=start},tile_defs[level_data[current.y][current.x]].type)
			if can_player_move_here(current):
				line.append(current)
			else:
				break  

		if x0 == x1 and y0 == y1:
			break

		var e2 = 2 * err
		if e2 >= dy:
			err += dy
			x0 += sx
		if e2 <= dx:
			err += dx
			y0 += sy
	return line

func can_player_move_here(coord: Vector2i) -> bool:
	#print(level_data[coord.x][coord.y], 'canmovehere?')
	return level_data[coord.y][coord.x].terrain == 3 or level_data[coord.y][coord.x].terrain == 4 or level_data[coord.y][coord.x].terrain == -1

func _ready() -> void:
	generate_level_data()

func update_cells_based_on_player_movement(to: Vector2i, player):
	astar_grid.set_point_solid(player_position, false)
	level_data[player_position.y/32][player_position.x/32].entity = null
	player_position = to
	astar_grid.set_point_solid(player_position, true)
	level_data[player_position.y/32][player_position.x/32].entity = player

func update_cells_based_on_entity_movement(from: Vector2i, to: Vector2i, entity):
	astar_grid.set_point_solid(from, false)
	level_data[from.y][from.x].entity = null
	astar_grid.set_point_solid(to, true)
	level_data[to.y][to.x].entity = entity

func get_entity_from_cell(cell: Vector2i):
	return level_data[cell.y][cell.x].entity

func add_entity_to_cell(cell: Vector2i, entity):
	if not level_data[cell.y][cell.x].entity:
		level_data[cell.y][cell.x].entity = entity
	else:
		print('Trying to add ' + entity + 'to ' + str(cell) + 'but it is not empty')

func remove_entity_from_cell(cell: Vector2i):
	if level_data[cell.y][cell.x].entity:
		level_data[cell.y][cell.x].entity = null
	else:
		print('Trying to remove the entity from ' + str(cell) + 'but it is empty')

func _input(event: InputEvent) -> void:
	if event is InputEventKey and Input.is_action_pressed('pause'):
		EnemyManager.paused_button_pressed()
		WeaponScript.paused_button_pressed()
		ItemManager.paused_button_pressed()
		CooldownManager.paused_button_pressed()
		if get_tree().current_scene.has_method('toggle_gui'):
			get_tree().current_scene.toggle_gui()
		paused = !paused
