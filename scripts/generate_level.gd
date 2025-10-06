extends Node2D

@export var height : float = 20
@export var width : float = 20
@export var number_of_walkable_tiles : float = 50
var number_of_tiles_placed : float = 0
@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

var level_data : Array = []
var ruined_tiles : Array[Vector2i] = []

func _ready() -> void:
	generate_level()

func generate_level() ->  void:
	level_data.clear()
	number_of_tiles_placed = 0.0
	for i in range(height):
		var y = []
		y.resize(width)
		y.fill(0)
		level_data.append(y)
	var total_cells = height * width
	var percentage: float = number_of_walkable_tiles/total_cells
	generate_array_of_vector2is()
	create_path([Vector2i(5,0), Vector2i(width - 6, height -1)])
	#create_start_point(percentage, [Vector2i(width/2, height/2), Vector2i(width/4, height/4), Vector2i(width/1.5, height/1.5)])
	#recurring_generation(percentage)
	fill_tile_map_layer_using_data()
	edit_collision_shape_accordingly()

var vector2i_array : Array = []

func generate_array_of_vector2is()-> void:
	for y in range(height):
		for x in range(width):
			vector2i_array.append(Vector2i(x,y))

func create_path(points: Array[Vector2i]) -> void:
	level_data[points[0].y][points[0].x] = 5
	path(points[0], points[points.size() - 1])

func path(next : Vector2i, end_tile: Vector2i) -> void:
	var stack :  Array[Vector2i] = [next]
	while stack.size() > 0:
		var coords_array : Array[Vector2i]= [Vector2i(1,0),Vector2i(0,1),Vector2i(-1,0),Vector2i(0,-1)]
		var next_tile = check_surrounding_tiles(coords_array, stack.back(), end_tile)
		if next_tile == Vector2i(-1,-1):
			stack.pop_back()
		elif next_tile == end_tile:
			level_data[next_tile.y][next_tile.x] = 5
			return
		else:
			level_data[next_tile.y][next_tile.x] = 5
			stack.append(next_tile)
	print('no path found')

func check_surrounding_tiles(coords: Array[Vector2i], centre: Vector2i, end_tile: Vector2i) :
	coords.shuffle()
	var new_tile = centre + coords[0]
	if new_tile.x < width and new_tile.x >= 0 and new_tile.y < height and new_tile.y >= 0:
		if level_data[new_tile.y] and level_data[new_tile.y][new_tile.x] == 0:
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

func create_start_point(percentage: float, start : Array[Vector2i]= [])-> void:
	if start.size() > 0:
		for cell in start:
			level_data[cell.y][cell.x] = 5
		return
	var start_created: bool = false
	for x in range(width):
		if randf_range(0,1) < percentage:
			level_data[0][x] = 5
			start_created = true
			break
	if not start_created:
		return create_start_point(percentage)

func recurring_generation(percentage: float) -> void:
	vector2i_array.shuffle()
	for vector2i in vector2i_array:
		if not is_floor_tile_adjacent(vector2i) or level_data[vector2i.y][vector2i.x] == 5:
			continue
		else:
			if randf_range(0,1) < percentage:
				level_data[vector2i.y][vector2i.x] = 5
				number_of_tiles_placed += 1.0
				if number_of_walkable_tiles - number_of_tiles_placed <= 0:
					return
	if number_of_walkable_tiles - number_of_tiles_placed > 0:
		recurring_generation(percentage)

func is_floor_tile_adjacent(position: Vector2i) -> bool:
	var coords_array = [Vector2i(1,0),Vector2i(0,1),Vector2i(-1,0),Vector2i(0,-1)]
	for coord in coords_array:
		var new_position = position + coord
		if new_position.x >= width or new_position.x < 0 or new_position.y >=height or new_position.y <0:
			continue
		if level_data[new_position.y] and level_data[new_position.y][new_position.x] and level_data[new_position.y][new_position.x] !=0:
			return true
	return false

func fill_tile_map_layer_using_data() -> void:
	tile_map_layer.clear()
	ruined_tiles.clear()
	for y in range(height):
		for x in range(width):
			if level_data[y][x] != 0:
				tile_map_layer.set_cell(Vector2i(x,y),1,Vector2i(0,randi_range(0,1)))
			elif level_data[y][x] == 0:
				tile_map_layer.set_cell(Vector2i(x,y),2,Vector2i(0,0))
				ruined_tiles.append(Vector2i(x,y))
	tile_map_layer.set_cells_terrain_connect(ruined_tiles,0,1)

func _on_regenerate_button_down() -> void:
	generate_level()

func edit_collision_shape_accordingly()-> void:
	var rect = collision_shape_2d.shape as RectangleShape2D
	rect.size = Vector2(height, width) * 64

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse = get_global_mouse_position()
		var type = 'grass' if tile_map_layer.get_cell_tile_data((mouse/32).floor()).terrain == 0 else 'ruin'
		print(type)
