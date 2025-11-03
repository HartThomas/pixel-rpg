extends Node
@onready var projectile_scene : PackedScene = load("res://scenes/projectile.tscn")
@onready var animatable_sprite_scene :PackedScene = load("res://scenes/animatable_sprite.tscn")
@onready var tooltip_scene : PackedScene = load("res://scenes/tooltip.tscn")

signal attack_attempt_failed

var error_tooltip_showing: bool = false
var player_node
var paused : bool = false

var current_attack: Array = []
var projectiles = []

func hammer(target: Vector2i, player_world_position, mouse_world_position,audio_stream_player, lights):
	var hammer_scene = load("res://scenes/hammer.tscn") as PackedScene
	var attack_instance = hammer_scene.instantiate()
	var target_cell = find_first_cell_toward_mouse_click(player_world_position, mouse_world_position)
	attack_instance.player_cell = player_world_position/32
	attack_instance.target_cell = target_cell / 32
	var affected_cells = attack_instance.execute()
	for cell in affected_cells:
		var new_animated_sprite = animatable_sprite_scene.instantiate()
		new_animated_sprite.sprite_name = InventoryManager.equipped[8].value.item_name
		new_animated_sprite.position = ( cell * 32) + Vector2i(16.0,16.0)
		for i in lights:
			new_animated_sprite.point_lights.append(i)
		new_animated_sprite.affected_cells.append(cell)
		if paused:
			new_animated_sprite.paused = true
		current_attack.append(new_animated_sprite)
		get_tree().current_scene.add_child(new_animated_sprite)
	player_node.set_state(player_node.States.ATTACK)

func sword(target: Vector2i, player_world_position, mouse_world_position, audio_stream_player, lights):
	var sword_scene = load("res://scenes/sword.tscn") as PackedScene
	var attack_instance = sword_scene.instantiate()
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
	player_node.set_state(player_node.States.ATTACK)

func bow(target: Vector2i, player_world_position, mouse_world_position, audio_stream_player, lights):
	var mouse_pos = mouse_world_position
	var target_cell = Vector2(
		floor(mouse_pos.x / 32.0) * 32.0 + 16,
		floor(mouse_pos.y / 32.0) * 32.0 + 16
	)
	var new_projectile = projectile_scene.instantiate()
	new_projectile.start_cell = player_world_position
	new_projectile.target_cell = target_cell
	new_projectile.projectile_name = 'arrow'
	new_projectile.position = player_world_position
	var weapon : Weapon = InventoryManager.equipped[8].value
	new_projectile.damage = weapon.final_damage
	projectiles.append(new_projectile)
	get_tree().current_scene.add_child(new_projectile)
	#player_node.set_state(player_node.States.ATTACK)

func bomb(target: Vector2i, player_world_position, mouse_world_position, audio_stream_player, lights):
	var mouse_pos = mouse_world_position
	var target_cell = Vector2(
		target.x * 32.0 + 16,
		target.y * 32.0 + 16
	)
	var new_projectile = projectile_scene.instantiate()
	new_projectile.start_cell = player_world_position
	new_projectile.vertical_velocity = -200.0
	new_projectile.vertical_offset = 0
	new_projectile.target_cell = target_cell
	new_projectile.projectile_name = 'bomb'
	new_projectile.position = player_world_position
	var weapon : Weapon = InventoryManager.equipped[8].value
	new_projectile.damage = weapon.final_damage
	projectiles.append(new_projectile)
	get_tree().current_scene.add_child(new_projectile)
	#player_node.set_state(player_node.States.ATTACK)

func dagger(target: Vector2i, player_world_position, mouse_world_position, audio_stream_player, lights):
	var dagger_scene = load("res://scenes/dagger.tscn") as PackedScene
	var attack_instance = dagger_scene.instantiate()
	var target_cell = find_first_cell_toward_mouse_click(player_world_position, mouse_world_position)
	attack_instance.player_cell = player_world_position/32
	attack_instance.target_cell = target_cell / 32
	var offset : Vector2 =  attack_instance.target_cell - attack_instance.player_cell
	var is_corner = abs(offset.x) == 1 and abs(offset.y) == 1
	var affected_cells = attack_instance.execute()
	var new_animated_sprite = animatable_sprite_scene.instantiate()
	if is_corner:
		new_animated_sprite.sprite_name = 'dagger_diagonal'
		new_animated_sprite.frame_width = 32
		new_animated_sprite.frame_height = 32
		#new_animated_sprite.centered = false
		var base_dir = Vector2(1, -1).normalized()
		var current_dir = offset.normalized()
		var angle_difference = current_dir.angle_to(base_dir)
		new_animated_sprite.rotation = -angle_difference
		var new_offset = Vector2(16,16).rotated(-angle_difference)
		new_animated_sprite.position = target_cell 
		new_animated_sprite.affected_cells = attack_instance.execute()
		if paused:
			new_animated_sprite.paused = true
		current_attack.append(new_animated_sprite)
		get_tree().current_scene.add_child(new_animated_sprite)
	else:
		var base_dir = Vector2(0, -1).normalized()
		var current_dir = offset.normalized()
		var angle_difference = current_dir.angle_to(base_dir)
		new_animated_sprite.sprite_name = 'dagger_parallel'
		new_animated_sprite.position = target_cell 
		new_animated_sprite.frame_width = 32
		new_animated_sprite.frame_height = 32
		new_animated_sprite.rotation = -angle_difference
		new_animated_sprite.affected_cells = attack_instance.execute()
		if paused:
			new_animated_sprite.paused = true
		current_attack.append(new_animated_sprite)
		get_tree().current_scene.add_child(new_animated_sprite)
	player_node.set_state(player_node.States.ATTACK)

func spear(target: Vector2i, player_world_position, mouse_world_position, audio_stream_player, lights):
	pass

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
	var weapon = InventoryManager.equipped[8].value as Weapon
	if CooldownManager.is_on_cooldown(weapon, "attack"):
		attack_attempt_failed.emit()
	else:
		call(weapon.animation_type, target, player_node, camera_2d, audio_stream_player, lights)
		CooldownManager.start_cooldown(weapon, "attack", weapon.cooldown)

func on_weapon_animation_finished(cells: Array[Vector2i]):
	for cell in cells:
		var entity = GameScript.get_entity_from_cell(cell)
		if entity and entity.has_method('take_damage'):
			var weapon: Weapon = InventoryManager.equipped[8].value
			entity.take_damage(weapon.final_damage)
	player_node.set_state(player_node.States.IDLE)

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
			if projectile.projectile_name == "bomb":
				_update_bomb_projectile(projectile, delta)
			else:
				_update_linear_projectile(projectile, delta)
			#var distance_to_target = projectile.global_position.distance_to(projectile.target_cell)
			#var step = projectile.speed * delta
			#if step >= distance_to_target:
				#projectile.global_position = projectile.target_cell
				#projectiles.erase(projectile)
				#projectile.queue_free()
			#else:
				#projectile.global_position += projectile.velocity * delta

func _update_linear_projectile(projectile, delta):
	var distance_to_target = projectile.global_position.distance_to(projectile.target_cell)
	var step = projectile.speed * delta
	if step >= distance_to_target:
		projectile.global_position = projectile.target_cell
		projectiles.erase(projectile)
		projectile.queue_free()
	else:
		projectile.global_position += projectile.velocity * delta

func _update_bomb_projectile(projectile: ThrownProjectile, delta):
	var gravity = 800.0
	var bounce_loss = 0.6
	var min_bounce_velocity = 60.0
	var damping = 0.982

	# Direction of main travel (flat path)
	var dir = (projectile.target_cell - projectile.start_cell).normalized()
	projectile.velocity = dir * projectile.velocity.length() * damping

	# Move along path (the bomb’s projected ground position)
	projectile.progress += projectile.velocity.length() * delta
	var path_length = projectile.start_cell.distance_to(projectile.target_cell)
	var t = clamp(projectile.progress / path_length, 0.0, 1.0)
	
	var base_pos = projectile.start_cell.lerp(projectile.target_cell, t)
	
	# Perpendicular direction for bounce
	var perp = Vector2(-dir.y, dir.x)
	var screen_up = Vector2(0, -1)
	if perp.dot(screen_up) < 0:
		perp = -perp
	# Apply vertical (bounce) motion along the perpendicular
	projectile.vertical_velocity += gravity * delta
	projectile.vertical_offset += projectile.vertical_velocity * delta
	
	# Bounce when passing below baseline
	if projectile.vertical_offset > 0:
		projectile.vertical_offset = 0
		projectile.vertical_velocity = -projectile.vertical_velocity * bounce_loss
		if abs(projectile.vertical_velocity) < min_bounce_velocity:
			projectile.vertical_velocity = 0
	
	# Combine path position + bounce offset
	projectile.global_position = base_pos + perp * -projectile.vertical_offset
	
	# Remove when finished
	if t >= 1.0 and projectile.vertical_velocity == 0:
		projectiles.erase(projectile)
		projectile.queue_free()
