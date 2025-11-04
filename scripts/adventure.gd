extends Node2D

@export var player_scene : PackedScene
@export var projectile_scene : PackedScene
@onready var background: Node2D = $Background
@onready var camera_2d: Camera2D = $Camera2D
@onready var highlight_cell: Sprite2D = $HighlightCell
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var gui: CanvasLayer = $Gui
@onready var loot_info: CanvasLayer = $LootInfo
@onready var mouse_highlight: Sprite2D = $MouseHighlight
@onready var highlight_cell_2: Sprite2D = $HighlightCell2

signal weapon_change

const generic_scenery_scene = preload("res://scenes/sprite.tscn")
var light_source = preload("res://scenes/light.tscn")

var lights = []
var width = 40
var height = 40
const cell_size = 32
var level_name : String = 'swamp'
@onready var level_info : LevelData = load("res://resources/level_data/%s.tres" % [level_name])
var player_node

func _ready():
	width = GameScript.width
	height = GameScript.height
	var light = light_source.instantiate()
	lights.append(light)
	light.light_moved.connect(light_moved)
	add_child(light)
	_generate_level_from_data(GameScript.level_data)
	background.width = width
	background.height = height
	background.resize()
	#background.map_clicked.connect(cell_clicked)
	highlight_cell.load_texture()
	highlight_cell_2.load_texture()
	create_player()
	var totem_locations : Array[Vector2i] = []
	if level_info.totem_number > 0:
		var random_tile = GameScript.random_free_cell(level_info.totem_number)
		for i in range(level_info.totem_number):
			totem_locations.append(random_tile[i])
			background.edit_tile(random_tile[i], 0, Vector2i(3,2))
	for i in totem_locations:
		EnemyManager.create_enemies(level_info, i)
	gui.change_cooldown(InventoryManager.equipped[8].value)
	InventoryManager.call_deferred('record_inventory_slots')
	PlayerManager.setup_healthbar()

func light_moved(light):
	background.light_moved(light)

func _generate_level_from_data(level_data):
	#for y in level_data.size():
		#for x in level_data[y].size():
			#var id = level_data[y][x].terrain
			#if id <= 0 or not GameScript.tile_defs.has(id) or id == 4:
				#continue
			#var tile_data = GameScript.tile_defs[id]
			#var instance = generic_scenery_scene.instantiate()
			#instance.position = Vector2i(x, y) * cell_size + Vector2i(16,16)
			#instance.sprite_name = tile_data["type"] 
			#instance.add_to_group('shaded')
			#for i in lights.size():
				#instance.point_lights.append(lights[i])
			#add_child(instance)
	pass

func create_player() ->void:
	var new_player = player_scene.instantiate()
	new_player.position = Vector2i(5, 0) * cell_size + Vector2i(16,16)
	new_player.sprite_name = "player_idle"
	for i in lights.size():
		new_player.point_lights.append(lights[i])
	new_player.add_to_group('shaded')
	add_child(new_player)
	player_node = new_player
	GameScript.player_position = player_node.position
	EnemyManager.player_scene = player_node
	WeaponScript.player_node = player_node

func cell_clicked(target: Vector2i):
	if Input.is_action_pressed('shift'):
		WeaponScript.cell_clicked( target, player_node.position, camera_2d.get_global_mouse_position(), audio_stream_player, lights)
	else:
		player_node.move_player(target)

var coords_array = [
	Vector2(1,0),Vector2(1,1),Vector2(0,1),Vector2(-1,1),Vector2(-1,0),Vector2(-1,-1),Vector2(0,-1),Vector2(1,-1)
]

func highlight_cell_nearest_mouse():
	var target_cell :Vector2i
	if Input.is_action_pressed("shift"):
		mouse_highlight.visible = false
		if InventoryManager.equipped[8].value.animation_type == 'bow':
			var mouse_pos = camera_2d.get_global_mouse_position()
			target_cell = Vector2(
				floor(mouse_pos.x / 32.0) * 32.0 + 16,
				floor(mouse_pos.y / 32.0) * 32.0 + 16
			)
		elif InventoryManager.equipped[8].value.animation_type == 'bomb':
			target_cell = find_bomb_cell_to_target()
		elif InventoryManager.equipped[8].value.animation_type == 'spear':
			target_cell = find_first_cell_toward_mouse_click()
			var player_cell = Vector2(
				floor(player_node.position.x / 32.0),
				floor(player_node.position.y / 32.0)
			)
			var target_cell_2i = Vector2(
				floor(target_cell.x / 32.0),
				floor(target_cell.y / 32.0)
			)
			var extra_highlight_cell =target_cell_2i - player_cell
			highlight_cell_2.position = (player_cell* 32) + Vector2(16,16) + ((extra_highlight_cell * 32) * 2 )
			highlight_cell_2.load_texture()
			highlight_cell_2.visible = true
		else:
			target_cell = find_first_cell_toward_mouse_click()
		highlight_cell.global_position = target_cell
		highlight_cell.load_texture()
		highlight_cell.visible = true
	else:
		highlight_cell.visible = false
		highlight_cell_2.visible = false
		mouse_highlight.visible = true
		var mouse_pos = camera_2d.get_global_mouse_position()
		target_cell = Vector2(
			floor(mouse_pos.x / 32.0) * 32.0 + 16,
			floor(mouse_pos.y / 32.0) * 32.0 + 16
		)
		mouse_highlight.global_position = target_cell

func  find_bomb_cell_to_target() -> Vector2:
	var mouse_pos = camera_2d.get_global_mouse_position()
	var cell_size = 32.0
	var half_cell = cell_size / 2.0

	# Snap mouse to nearest cell center
	var highlighted_cell = Vector2(
		floor(mouse_pos.x / cell_size) * cell_size + half_cell,
		floor(mouse_pos.y / cell_size) * cell_size + half_cell
	)
	# Compute cell offset (in whole cells)
	var dx = int(round((highlighted_cell.x - player_node.position.x) / cell_size))
	var dy = int(round((highlighted_cell.y - player_node.position.y) / cell_size))

	# Clamp to 3 cells in each direction
	dx = clamp(dx, -3, 3)
	dy = clamp(dy, -3, 3)

	# --- remove corners ---
	# If both |dx| and |dy| are large enough, shift inward
	if (abs(dx) == 3 and abs(dy) >= 2) or (abs(dy) == 3 and abs(dx) >= 2):
		#print('inside corner region', dx, dy)
		if abs(dx) == 3 and abs(dy) == 3:
			# true diagonal corner → pull both inward
			dx = sign(dx) * 2
			dy = sign(dy) * 2
		else:
			# otherwise, pull the dominant axis inward
			if abs(dx) > abs(dy):
				dx = sign(dx) * 2
			else:
				dy = sign(dy) * 2

	# Convert back to world coordinates
	return player_node.position + Vector2(dx * cell_size, dy * cell_size)

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

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if ItemManager.holding_item:
			ItemManager.item_clicked(ItemManager.holding_item)
			return
		var mouse_pos = get_global_mouse_position()
		# Build query
		var params := PhysicsPointQueryParameters2D.new()
		params.position = mouse_pos
		params.collide_with_areas = true
		params.collide_with_bodies = true
		# Run query
		var space_state = get_world_2d().direct_space_state
		var results = space_state.intersect_point(params, 32)
		#for result in results:
			#print(result['collider'].get_parent(), 'name',result['collider'].name, result['collider'].get_parent().has_method('on_click'))
		#print(results)
		if results.size() > 1:
			# Sort so the topmost (highest z_index) gets priority
			results.sort_custom(func(a, b): return a["collider"].z_index > b["collider"].z_index)
			for result in results:
				if result['collider'].get_parent().has_method('on_click') and !result['collider'].name.begins_with('Background'):
					result['collider'].get_parent().on_click()
					get_viewport().set_input_as_handled()
					return
		cell_clicked( (mouse_pos/32).floor() if InventoryManager.equipped[8].value.item_name != 'bomb' else (find_bomb_cell_to_target()/32).floor())

func _process(delta):
	highlight_cell_nearest_mouse()

func toggle_gui():
	if not gui.is_shown:
		gui.show_gui()
	else:
		gui.hide_gui()
