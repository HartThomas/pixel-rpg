extends Node
const POP_UP_TEXT = preload("res://scenes/pop_up_text.tscn")


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
	3: 1,  # rare
	4: 6,
}

var player_position: Vector2

var level_data = []
const width = 30
const height = 30
const cell_size = 32
var astar_grid : AStarGrid2D
var start_tile :Vector2i = Vector2i(5,0)
var free_cells: Array[Vector2i] = []
var end_tile: Vector2i 

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
	for i in range(height):
		var y = []
		y.resize(width)
		y.fill({
				"terrain": 5,
				"entity": null
			})
		level_data.append(y)
	var occupied = []
	for y in range(height):
		occupied.append([])
		for x in range(width):
			occupied[y].append(false)
	create_path([start_tile, Vector2i(width - 6, height -1)])
	#var rows_top_down = []
	#for y in range(height):
		#var row = []
		#for x in range(width):
			#var tile_id: int
			#if x == 0 or y == 0 or x == width - 1 or y == height - 1:
				#tile_id = 5  
			#elif occupied[y][x]:
				#tile_id = 4  
			#else:
				#var id = _pick_random_tile_id()
				#if can_place_tile(id, x, y, occupied):
					#tile_id = id
					#mark_occupied(id, x, y, occupied)
				#else:
					#tile_id = 0 
			#row.append({
				#"terrain": tile_id,
				#"entity": null
			#})
		#rows_top_down.append(row)
	#level_data = rows_top_down
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

func create_path(points: Array[Vector2i]) -> void:
	end_tile = points[points.size() - 1]
	level_data[points[0].y][points[0].x] = {
				"terrain": 4,
				"entity": null
			}
	path(points[0], points[points.size() - 1])

func path(next : Vector2i, end_tile: Vector2i) -> void:
	var stack :  Array[Vector2i] = [next]
	while stack.size() > 0:
		var coords_array : Array[Vector2i]= [Vector2i(1,0),Vector2i(0,1),Vector2i(-1,0),Vector2i(0,-1)]
		var next_tile = check_surrounding_tiles(coords_array, stack.back(), end_tile)
		if next_tile == Vector2i(-1,-1):
			stack.pop_back()
		elif next_tile == end_tile:
			level_data[next_tile.y][next_tile.x] = {
				"terrain": 4,
				"entity": null
			}
			return
		else:
			level_data[next_tile.y][next_tile.x] = {
				"terrain": 4,
				"entity": null
			}
			stack.append(next_tile)
			free_cells.append(next_tile)
	print('no path found')

func check_surrounding_tiles(coords: Array[Vector2i], centre: Vector2i, end_tile: Vector2i) :
	coords.shuffle()
	var new_tile = centre + coords[0]
	if new_tile == end_tile:
		return end_tile
	if new_tile.x < width -1 and new_tile.x >= 1 and new_tile.y < height -1 and new_tile.y >= 1:
		if level_data[new_tile.y] and level_data[new_tile.y][new_tile.x].terrain == 5:
			return new_tile
		else:
			coords.pop_front()
			if coords.size() > 0:
				return check_surrounding_tiles(coords, centre, end_tile)
	else:
		coords.remove_at(0)
		if coords.size() > 0:
			return check_surrounding_tiles(coords, centre, end_tile)
	return Vector2i(-1,-1)

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
		print('Trying to add ' + str(entity) + 'to ' + str(cell) + 'but it is not empty')

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

func create_pop_up_text(position, text, color = Color('BLACK')):
	var pop_up = POP_UP_TEXT.instantiate()
	pop_up.new_text = text
	pop_up.new_position = position
	pop_up.new_color = color
	get_tree().current_scene.add_child(pop_up)

func random_free_cell(amount: int) -> Array[Vector2i]:
	free_cells.shuffle()
	var tiles : Array[Vector2i] = []
	for i in range(amount):
		tiles.append(free_cells.pop_front())
	return tiles

func get_random_cells_around(center: Vector2i, radius: int, count: int) -> Array[Vector2i]:
	var nearby : Array[Vector2i] = []
	for cell in free_cells:
		if cell.distance_to(center) <= radius:
			nearby.append(cell)
	nearby.shuffle()
	return nearby.slice(0, min(count, nearby.size()))

func end_level() -> void:
	print('ending level')
