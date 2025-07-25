extends Node
var weapon: String = 'sword'
@onready var weapon_scene :PackedScene = load("res://scenes/%s.tscn" % [weapon])
@onready var projectile_scene : PackedScene = load("res://scenes/arrow.tscn")
@onready var animatable_sprite_scene :PackedScene = load("res://scenes/animatable_sprite.tscn")

var paused : bool = false

var current_attack: Array = []
var projectiles = []

func hammer(target: Vector2i, player_world_position, mouse_world_position,audio_stream_player, lights):
	var attack_instance = weapon_scene.instantiate()
	var target_cell = find_first_cell_toward_mouse_click(player_world_position, mouse_world_position)
	attack_instance.player_cell = player_world_position/32
	attack_instance.target_cell = target_cell / 32
	var affected_cells = attack_instance.execute()
	for cell in affected_cells:
		var new_animated_sprite = animatable_sprite_scene.instantiate()
		new_animated_sprite.sprite_name = weapon
		new_animated_sprite.position = ( cell * 32) + Vector2i(16.0,16.0)
		for i in lights:
			new_animated_sprite.point_lights.append(i)
		new_animated_sprite.affected_cells.append(cell)
		if paused:
			new_animated_sprite.paused = true
		current_attack.append(new_animated_sprite)
		get_tree().current_scene.add_child(new_animated_sprite)

func sword(target: Vector2i,player_world_position, mouse_world_position, audio_stream_player, lights):
	var attack_instance = weapon_scene.instantiate()
	var target_cell = find_first_cell_toward_mouse_click(player_world_position, mouse_world_position)
	attack_instance.player_cell = player_world_position/32
	attack_instance.target_cell = target_cell / 32
	var offset : Vector2 =  attack_instance.target_cell - attack_instance.player_cell
	var is_corner = abs(offset.x) == 1 and abs(offset.y) == 1
	var affected_cells = attack_instance.execute()
	var new_animated_sprite = animatable_sprite_scene.instantiate()
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
		new_animated_sprite.position = player_world_position - new_offset
		new_animated_sprite.affected_cells = get_sword_affected_cells(Vector2i(player_world_position)/32, Vector2i(sign(offset.x), sign(offset.y)))
		if paused:
			new_animated_sprite.paused = true
		current_attack.append(new_animated_sprite)
		get_tree().current_scene.add_child(new_animated_sprite)
	else:
		new_animated_sprite.sprite_name = 'sword_parallel'
		new_animated_sprite.position = target_cell
		new_animated_sprite.frame_width = 32
		new_animated_sprite.frame_height = 96
		new_animated_sprite.rotation = offset.angle()
		new_animated_sprite.affected_cells = get_sword_affected_cells(Vector2i(player_world_position)/32, Vector2i(sign(offset.x), sign(offset.y)))
		if paused:
			new_animated_sprite.paused = true
		current_attack.append(new_animated_sprite)
		get_tree().current_scene.add_child(new_animated_sprite)
	audio_stream_player.pitch_scale = randf_range(0.85,1.15)
	audio_stream_player.play()

func bow(target: Vector2i, player_world_position, mouse_world_position, audio_stream_player, lights):
	var mouse_pos = mouse_world_position
	var target_cell = Vector2(
		floor(mouse_pos.x / 32.0) * 32.0 + 16,
		floor(mouse_pos.y / 32.0) * 32.0 + 16
	)
	var new_projectile = projectile_scene.instantiate()
	new_projectile.target_cell = target_cell
	new_projectile.projectile_name = 'arrow'
	new_projectile.position = player_world_position
	projectiles.append(new_projectile)
	get_tree().current_scene.add_child(new_projectile)

var coords_array = [
	Vector2(1,0),Vector2(1,1),Vector2(0,1),Vector2(-1,1),Vector2(-1,0),Vector2(-1,-1),Vector2(0,-1),Vector2(1,-1)
]

func find_first_cell_toward_mouse_click(player_world_position, mouse_world_position):
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

func cell_clicked(target, player_node, camera_2d, audio_stream_player, lights):
	call(weapon, target, player_node, camera_2d, audio_stream_player, lights)

func on_weapon_animation_finished(cells: Array[Vector2i]):
	for cell in cells:
		var entity = GameScript.get_entity_from_cell(cell)
		if entity and entity.has_method('take_damage'):
			entity.take_damage(10)

func get_sword_affected_cells(player_cell: Vector2i, direction: Vector2i) -> Array[Vector2i]:
	var affected : Array[Vector2i] = []
	# For cardinal directions
	if direction.x == 0 or direction.y == 0:
		# Swing hits the cell directly in front and optionally above/below it
		var forward = player_cell + direction
		var side1 = forward + Vector2i(-direction.y, -direction.x)  # perpendicular
		var side2 = forward + Vector2i(direction.y, direction.x)
		affected.append(forward)
		affected.append(side1)
		affected.append(side2)
	# For corner/diagonal swings
	elif abs(direction.x) == 1 and abs(direction.y) == 1:
		var corner = player_cell + direction
		var side1 = player_cell + Vector2i(direction.x, 0)
		var side2 = player_cell + Vector2i(0, direction.y)
		affected.append(corner)
		affected.append(side1)
		affected.append(side2)
	return affected

func paused_button_pressed():
	paused = !paused
	for i in current_attack:
		i.pause_animation()

func _process(delta: float) -> void:
	if not paused:
		for projectile in projectiles:
			var distance_to_target = projectile.global_position.distance_to(projectile.target_cell)
			var step = projectile.speed * delta
			if step >= distance_to_target:
				projectile.global_position = projectile.target_cell
				projectiles.erase(projectile)
				projectile.queue_free()
			else:
				projectile.global_position += projectile.velocity * delta
