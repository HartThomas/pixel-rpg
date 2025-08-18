extends Node2D

@export var player_scene : PackedScene
@export var projectile_scene : PackedScene
@onready var background: Node2D = $Background
@onready var camera_2d: Camera2D = $Camera2D
@onready var highlight_cell: Sprite2D = $HighlightCell
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var gui: CanvasLayer = $Gui

const generic_scenery_scene = preload("res://scenes/sprite.tscn")
var light_source = preload("res://scenes/light.tscn")

var lights = []
const width = 40
const height = 40
const cell_size = 32

var player_node

func _ready():
	var light = light_source.instantiate()
	lights.append(light)
	add_child(light)
	_generate_level_from_data(GameScript.level_data)
	background.width = width
	background.height = height
	background.resize()
	background.map_clicked.connect(cell_clicked)
	highlight_cell.load_texture()
	create_player()
	EnemyManager.create_enemies(5)
	gui.change_cooldown(InventoryManager.equipped[8].value)

func _generate_level_from_data(level_data):
	for y in level_data.size():
		for x in level_data[y].size():
			var id = level_data[y][x].terrain
			if id <= 0 or not GameScript.tile_defs.has(id) or id == 4:
				continue
			var tile_data = GameScript.tile_defs[id]
			var instance = generic_scenery_scene.instantiate()
			instance.position = Vector2i(x, y) * cell_size + Vector2i(16,16)
			instance.sprite_name = tile_data["type"] 
			for i in lights.size():
				instance.point_lights.append(lights[i])
			add_child(instance)

func create_player() ->void:
	var new_player = player_scene.instantiate()
	new_player.position = Vector2i(5, 5) * cell_size + Vector2i(16,16)
	new_player.sprite_name = "player"
	for i in lights.size():
		new_player.point_lights.append(lights[i])
	add_child(new_player)
	player_node = new_player
	GameScript.player_position = player_node.position
	EnemyManager.player_scene = player_node

func cell_clicked(target: Vector2i):
	if Input.is_action_pressed('shift'):
		WeaponScript.cell_clicked( target, player_node.position, camera_2d.get_global_mouse_position(), audio_stream_player, lights)
	else:
		player_node.move_player(target)

var coords_array = [
	Vector2(1,0),Vector2(1,1),Vector2(0,1),Vector2(-1,1),Vector2(-1,0),Vector2(-1,-1),Vector2(0,-1),Vector2(1,-1)
]

func highlight_best_cell():
	var target_cell :Vector2i
	if InventoryManager.equipped[8].value.item_name == 'bow':
		var mouse_pos = camera_2d.get_global_mouse_position()
		target_cell = Vector2(
			floor(mouse_pos.x / 32.0) * 32.0 + 16,
			floor(mouse_pos.y / 32.0) * 32.0 + 16
		)
	else:
		target_cell = find_first_cell_toward_mouse_click()
	highlight_cell.global_position = target_cell
	highlight_cell.load_texture()
	highlight_cell.visible = true

func find_first_cell_toward_mouse_click():
	var player_world_position = player_node.position
	var mouse_world_position = camera_2d.get_global_mouse_position()
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

func toggle_gui():
	if not gui.is_shown:
		gui.show_gui()
	else:
		gui.hide_gui()
