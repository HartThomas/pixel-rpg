extends Node2D
@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var gaea_generator: GaeaGenerator = $GaeaGenerator

func _ready() -> void:
	gaea_generator.generate()

func _on_gaea_generator_generation_finished(grid: GaeaGrid) -> void:
	var first = grid.get_layer(0)[Vector3i(0,0,0)] as TileMapGaeaMaterial
	print(first.atlas_coord, ' ', first.pattern_index, ' ', first.terrain_set, ' ', first.terrain)
