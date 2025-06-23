extends Node2D

const GENERIC_SCENERY_SCENE = preload("res://scenes/sprite.tscn")
var light_source = preload("res://scenes/light.tscn")

var tile_defs = {
	1: { "type": "tree", "size": Vector2i(1, 2) },
	2: { "type": "rock", "size": Vector2i(1, 2) },
	3: { "type": "signpost", "size": Vector2i(1, 1) },
	4: { type= 'nothing', size= Vector2i(1, 1)}
}

var tile_weights = {
	1: 5,  # common
	2: 2,  # uncommon
	3: 1,   # rare
	4: 6,
}

var level_data = []
var lights = []
const WIDTH = 20
const HEIGHT = 15
const CELL_SIZE = 32

func _ready():
	var light = light_source.instantiate()
	lights.append(light)
	add_child(light)
	generate_level_data()
	_generate_level_from_data()

func _generate_level_from_data():
	#$SceneryLayer.clear_children()

	for y in level_data.size():
		for x in level_data[y].size():
			var id = level_data[y][x]
			if id <= 0 or not tile_defs.has(id) or id == 4:
				continue

			var tile_data = tile_defs[id]
			var instance = GENERIC_SCENERY_SCENE.instantiate()

			instance.position = Vector2(x, y) * CELL_SIZE
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
			if gx >= WIDTH or gy >= HEIGHT:
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
	for y in range(HEIGHT):
		occupied.append([])
		for x in range(WIDTH):
			occupied[y].append(false)
	for y in range(HEIGHT):
		var row = []
		for x in range(WIDTH):
			if occupied[y][x]:
				row.append(-1)
				continue
			var id = _pick_random_tile_id()
			if can_place_tile(id, x, y, occupied):
				row.append(id)
				mark_occupied(id, x, y, occupied)
			else:
				row.append(0)  # fallback to empty
		level_data.append(row)

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
