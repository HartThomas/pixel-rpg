extends Node2D

@export var player_scene : PackedScene
@onready var background: Node2D = $Background
@onready var camera_2d: Camera2D = $Camera2D

const generic_scenery_scene = preload("res://scenes/sprite.tscn")
var light_source = preload("res://scenes/light.tscn")

var tile_defs = {
	1: { "type": "tree", "size": Vector2i(1, 2) },
	2: { "type": "rock", "size": Vector2i(1, 2) },
	3: { "type": "signpost", "size": Vector2i(1, 1) },
	4: { type= 'nothing', size= Vector2i(1, 1)},
	5: { type= 'ruin', size= Vector2i(1, 1)},
	-1: {type= 'blah', size= Vector2i(1, 1)}
}

var tile_weights = {
	1: 5,  # common
	2: 2,  # uncommon
	3: 1,   # rare
	4: 6,
}

var level_data = []
var lights = []
const width = 40
const height = 40
const cell_size = 32

var player_node

func _ready():
	var light = light_source.instantiate()
	lights.append(light)
	add_child(light)
	generate_level_data()
	_generate_level_from_data()
	background.width = width
	background.height = height
	background.resize()
	background.map_clicked.connect(move_player)
	create_player()

func _generate_level_from_data():
	for y in level_data.size():
		for x in level_data[y].size():
			var id = level_data[y][x]
			if id <= 0 or not tile_defs.has(id) or id == 4:
				continue
			var tile_data = tile_defs[id]
			var instance = generic_scenery_scene.instantiate()
			instance.position = Vector2i(x, y) * cell_size + Vector2i(16,16)
			instance.sprite_name = tile_data["type"] 
			for i in lights.size():
				instance.point_lights.append(lights[i])
			add_child(instance)

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
			if x == 0 or y == 0 or x == width - 1 or y == height - 1:
				row.append(5) 
				continue
			if occupied[y][x]:
				row.append(4) 
				continue
			var id = _pick_random_tile_id()
			if can_place_tile(id, x, y, occupied):
				row.append(id)
				mark_occupied(id, x, y, occupied)
			else:
				row.append(0) 
		rows_top_down.append(row)
	level_data = rows_top_down

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

func can_player_move_here(coord: Vector2i) -> bool:
	#print(level_data[coord.x][coord.y], 'canmovehere?')
	return level_data[coord.y][coord.x] == 3 or level_data[coord.y][coord.x] == 4 or level_data[coord.y][coord.x] == -1

func create_player() ->void:
	var new_player = player_scene.instantiate()
	new_player.position = Vector2i(5, 5) * cell_size + Vector2i(16,16)
	new_player.sprite_name = "player"
	for i in lights.size():
		new_player.point_lights.append(lights[i])
	add_child(new_player)
	player_node = new_player

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
			print({current= current,start=start},tile_defs[level_data[current.y][current.x]].type)
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

var path: Array[Vector2i] = []
var move_speed := 5.0  # tiles per second
var move_timer := 0.0
var move_delay := 1.0 / move_speed

func move_player(target: Vector2i):
	var current_grid = (player_node.position / cell_size).floor()
	path = get_straight_line_path(current_grid, target)
	print(path)
	queue_redraw()

func _draw():
	for tile in path:
		var rect = Rect2(tile * cell_size, Vector2(cell_size, cell_size))
		draw_rect(rect, Color(0, 1, 0, 0.3))
	var player_tile = (player_node.position / cell_size).floor()
	var rect = Rect2(player_tile * cell_size, Vector2(cell_size, cell_size))
	draw_rect(rect, Color(1, 0, 0, 0.3))  # Red for player tile

func _process(delta):
	if path.size() > 0:
		move_timer += delta
		if move_timer >= move_delay:
			move_timer = 0.0
			var next_tile = path.pop_front()
			player_node.position = next_tile * cell_size + Vector2i(16,16)
