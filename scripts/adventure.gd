extends Node2D

@export var player_scene : PackedScene
@export var projectile_scene : PackedScene
@onready var background: Node2D = $Background
@onready var camera_2d: Camera2D = $Camera2D
@onready var highlight_cell: Sprite2D = $HighlightCell
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var weapon = 'bow'
@onready var weapon_scene :PackedScene = load("res://scenes/%s.tscn" % [weapon])

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
	highlight_cell.weapon = weapon
	highlight_cell.load_texture()
	create_player()
	EnemyManager.create_enemies(1)

func _generate_level_from_data(level_data):
	for y in level_data.size():
		for x in level_data[y].size():
			var id = level_data[y][x]
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
	else:
		new_animated_sprite.sprite_name = 'sword_parallel'
		new_animated_sprite.position = target_cell
		new_animated_sprite.frame_width = 32
		new_animated_sprite.frame_height = 96
		new_animated_sprite.rotation = offset.angle()
		add_child(new_animated_sprite)
	audio_stream_player.pitch_scale = randf_range(0.85,1.15)
	audio_stream_player.play()

func bow(target: Vector2i):
	var mouse_pos = camera_2d.get_global_mouse_position()
	var target_cell = Vector2(
		floor(mouse_pos.x / 32.0) * 32.0 + 16,
		floor(mouse_pos.y / 32.0) * 32.0 + 16
	)
	var new_projectile = projectile_scene.instantiate()
	new_projectile.target_cell = target_cell
	new_projectile.projectile_name = 'arrow'
	new_projectile.position = player_node.position
	add_child(new_projectile)

func move_player(target: Vector2i):
	var current_grid = (player_node.position / cell_size).floor()
	path = GameScript.get_straight_line_path(current_grid, target)
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
	var target_cell :Vector2i
	if weapon == 'bow':
		var mouse_pos = camera_2d.get_global_mouse_position()
		target_cell = Vector2(
			floor(mouse_pos.x / 32.0) * 32.0 + 16,
			floor(mouse_pos.y / 32.0) * 32.0 + 16
		)
	else:
		target_cell = find_first_cell_toward_mouse_click()
	highlight_cell.global_position = target_cell
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
	if path.size() > 0:
		move_timer += delta
		if move_timer >= move_delay:
			move_timer = 0.0
			var next_tile = path.pop_front()
			player_node.position = next_tile * cell_size + Vector2i(16,16)
			GameScript.player_position = player_node.position

func move_enemy():
	EnemyManager.move_enemy(0, Vector2(1,1))
