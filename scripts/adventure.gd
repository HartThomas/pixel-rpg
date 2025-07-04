extends Node2D

@export var player_scene : PackedScene
@onready var background: Node2D = $Background
@onready var camera_2d: Camera2D = $Camera2D
@onready var highlight_cell: Sprite2D = $HighlightCell
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var weapon = 'sword'
@onready var weapon_scene :PackedScene = load("res://scenes/%s.tscn" % [weapon])

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
	background.map_clicked.connect(cell_clicked)
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

var path: Array[Vector2i] = []
var move_speed = 5.0 
var move_timer = 0.0
var move_delay = 1.0 / move_speed

func cell_clicked(target: Vector2i):
	if Input.is_action_pressed('shift'):
		call(weapon, target)
	else:
		move_player(target)

func hammer(target: Vector2i):
	var attack_instance = weapon_scene.instantiate()
	var target_cell = find_first_cell_toward_mouse_click()
	attack_instance.player_cell = player_node.position/32
	attack_instance.target_cell = target_cell / 32
	var affected_cells = attack_instance.execute()
	for cell in affected_cells:
		var new_animated_sprite = player_scene.instantiate()
		new_animated_sprite.sprite_name = weapon
		new_animated_sprite.position = ( cell * 32) + Vector2i(16.0,16.0)
		for i in lights:
			new_animated_sprite.point_lights.append(i)
		add_child(new_animated_sprite)

func sword(target: Vector2i):
	var attack_instance = weapon_scene.instantiate()
	var target_cell = find_first_cell_toward_mouse_click()
	attack_instance.player_cell = player_node.position/32
	attack_instance.target_cell = target_cell / 32
	var offset : Vector2 =  attack_instance.target_cell - attack_instance.player_cell
	var is_corner = abs(offset.x) == 1 and abs(offset.y) == 1
	var affected_cells = attack_instance.execute()
	var new_animated_sprite = player_scene.instantiate()
	if is_corner:
		new_animated_sprite.sprite_name = 'sword_corner'
		new_animated_sprite.frame_width = 64
		new_animated_sprite.frame_height = 64
		new_animated_sprite.centered = false
		var base_dir = Vector2(1, 1).normalized()
		var current_dir = offset.normalized()
		var angle_difference = current_dir.angle_to(base_dir)
		new_animated_sprite.rotation = -angle_difference
		
		var new_offset = Vector2(16,16).rotated(-angle_difference)
		new_animated_sprite.position = player_node.position - new_offset
		add_child(new_animated_sprite)
		audio_stream_player.pitch_scale = randf_range(0.85,1.15)
		audio_stream_player.play()
	else:
		new_animated_sprite.sprite_name = 'sword_parallel'
		new_animated_sprite.position = target_cell
		new_animated_sprite.frame_width = 32
		new_animated_sprite.frame_height = 96
		new_animated_sprite.rotation = offset.angle()
		add_child(new_animated_sprite)
		audio_stream_player.pitch_scale = randf_range(0.85,1.15)
		audio_stream_player.play()

func move_player(target: Vector2i):
	var current_grid = (player_node.position / cell_size).floor()
	path = get_straight_line_path(current_grid, target)
	queue_redraw()

func _draw():
	for tile in path:
		var rect = Rect2(tile * cell_size, Vector2(cell_size, cell_size))
		draw_rect(rect, Color(0, 1, 0, 0.3))
	var player_tile = (player_node.position / cell_size).floor()
	var rect = Rect2(player_tile * cell_size, Vector2(cell_size, cell_size))
	draw_rect(rect, Color(1, 0, 0, 0.3))

var coords_array = [
	Vector2(1,0),Vector2(1,1),Vector2(0,1),Vector2(-1,1),Vector2(-1,0),Vector2(-1,-1),Vector2(0,-1),Vector2(1,-1)
]

func highlight_best_cell():
	var target_cell = find_first_cell_toward_mouse_click()
	highlight_cell.global_position = target_cell 
	highlight_cell.visible = true

func find_first_cell_toward_mouse_click():
	var player_world_position = player_node.position
	var mouse_world_position = get_viewport().get_mouse_position()
	var player_to_mouse_angle = (mouse_world_position - player_world_position).angle()
	var best_offset = Vector2.ZERO
	var smallest_angle_diff = INF
	for offset in coords_array:
		var offset_angle = offset.angle()
		var angle_diff = abs(wrapf(player_to_mouse_angle - offset_angle, -PI, PI))
		if angle_diff < smallest_angle_diff:
			smallest_angle_diff = angle_diff
			best_offset = offset
	return player_world_position + (best_offset * 32)

func _process(delta):
	if Input.is_action_pressed("shift"):
		highlight_best_cell()
	else:
		highlight_cell.visible = false
	if path.size() > 0:
		move_timer += delta
		if move_timer >= move_delay:
			move_timer = 0.0
			var next_tile = path.pop_front()
			player_node.position = next_tile * cell_size + Vector2i(16,16)
