extends Node2D

var height : float = 20
var width : float = 20
var number_of_walkable_tiles : float = 50
var number_of_tiles_placed : float = 0
@onready var tile_map_layer: TileMapLayer = $TileMapLayer

var level_data : Array = []

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
	create_start_point(percentage)
	recurring_generation(percentage)
	fill_tile_map_layer_using_data()

func create_start_point(percentage: float)-> void:
	var start_created: bool = false
	for x in range(width):
		if randf_range(0,1) < percentage:
			level_data[0][x] = 5
			start_created = true
			break
	if not start_created:
		create_start_point(percentage)

func recurring_generation(percentage: float) -> void:
	for y in range(height):
		for x in range(width):
			if not is_floor_tile_adjacent(Vector2i(x,y)):
				continue
			else:
				if randf_range(0,1) < percentage:
					level_data[y][x] = 5
					number_of_tiles_placed += 1.0
	print(number_of_tiles_placed)
	if number_of_walkable_tiles - number_of_tiles_placed >= 0:
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
	for y in range(height):
		for x in range(width):
			if level_data[y][x] != 0:
				tile_map_layer.set_cell(Vector2i(x,y),2,Vector2i(0,0))

func _on_regenerate_button_down() -> void:
	generate_level()
	print('regen')
