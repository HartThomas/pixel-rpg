extends Node2D

var width : int = 20
var height : int = 15
var cell_size : int = 32
@onready var color_rect: ColorRect = $ColorRect
@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
var mouse_entered : bool = false
#signal map_clicked(cell: Vector2i)
var source_id = 0
var grass_atlas_arr = [Vector2i(0,0),Vector2i(0,1)]

func resize() -> void:
	color_rect.size = Vector2i(width * cell_size, height * cell_size)
	collision_shape_2d.shape.size = Vector2i(width * cell_size, height * cell_size)
	collision_shape_2d.position = Vector2i(collision_shape_2d.shape.size.x / 2, collision_shape_2d.shape.size.y / 2)
	var ruined_tiles : Array[Vector2i] = []
	for x in range(width):
		for y in range(height):
			if GameScript.level_data[y][x].terrain == 4:
				tile_map_layer.set_cell(Vector2i(x,y), source_id, grass_atlas_arr.pick_random())
			elif GameScript.level_data[y][x].terrain == 5:
				tile_map_layer.set_cell(Vector2i(x,y), 4, Vector2i(0,3))
				ruined_tiles.append(Vector2i(x,y))
	tile_map_layer.set_cells_terrain_connect(ruined_tiles,0,2)

func edit_tile(tile: Vector2i, source : int, atlas_coords: Vector2i) -> void:
	tile_map_layer.set_cell(tile, source, atlas_coords)

func _on_area_2d_mouse_entered() -> void:
	mouse_entered = true

func _on_area_2d_mouse_exited() -> void:
	mouse_entered = false

func light_moved(light):
	var shaded_nodes =  get_tree().get_nodes_in_group('shaded')
	for node in shaded_nodes:
		if node.position.distance_to(light.position) < 200:
			node.light_source_moved(light)
