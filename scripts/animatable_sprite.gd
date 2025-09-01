extends AnimatedSprite2D

@onready var shadow: AnimatedSprite2D = $Shadow
@onready var point_lights: Array[PointLight2D]
var sprite_name: String
var shadow_instances : Array[AnimatedSprite2D] = []
@export var frame_width = 32
@export var frame_height = 32
var affected_cells: Array[Vector2i]= []
var paused : bool = false
var sprite_data

var animation_dictionary : Dictionary = {
	player={ offset=Vector2(0.0,-11.0), columns= 3, rows = 1, used_columns = 1, loop = true, despawn = false }, 
	hammer= { offset = Vector2(0.0,-11.0),columns= 3, rows = 1, used_columns = 3, loop=false, despawn = true },
	sword_corner= {offset = Vector2(0.0,-11.0),columns= 3, rows = 1, used_columns = 3, loop=false, despawn = true},
	sword_parallel= {offset = Vector2(0.0,-11.0),columns= 3, rows = 1, used_columns = 3, loop=false, despawn = true},
	bogman= {offset = Vector2(0.0,-11.0),columns= 3, rows = 1, used_columns = 3, loop=true, despawn = false},
	bogman_attack= {offset = Vector2(0.0,-11.0),columns= 3, rows = 1, used_columns = 3, loop=true, despawn = false},
}

func _process(delta: float) -> void:
	for i in point_lights.size():
		var light = point_lights[i]
		var found_shadow = shadow_instances[i]
		var light_position = light.position
		var light_dir = (global_position - light_position).normalized()
		var shadow_angle = light_dir.angle() + PI * 0.5
		var light_distance = global_position.distance_to(light_position)
		var scale_y = clamp(light_distance / 100.0, 1.0, 1.5)
		var alpha = clamp(1.0 - (light_distance / 200.0), 0.0, 1.0)
		found_shadow.skew = shadow_angle
		var shader = found_shadow.material as ShaderMaterial
		if shader:
			var color: Color = shader.get_shader_parameter("color")
			color.a = alpha
			shader.set_shader_parameter("color", color)
		var up_vector = Vector2(0, 1)
		var above_factor = clamp(up_vector.dot(light_dir), 0.0, 1.0)
		var brightness = lerp(1.0, 0.7, above_factor)
		modulate = Color(brightness, brightness, brightness, 1.0)

func _ready() -> void:
	setup()

func setup():
	for shdw in shadow_instances:
		if shdw:
			shdw.queue_free()
	shadow_instances.clear()
	var frames = SpriteFrames.new()
	var data
	if sprite_name == 'bogman_idle' or sprite_name == 'bogman_attack':
		data = load("res://resources/entities/enemies/bogman.tres" % sprite_name) as Enemy
		frames = data.animations['idle' if sprite_name.contains('idle') else 'attack'].to_sprite_frames(sprite_name)
	elif sprite_name.contains('player'):
		data = load("res://resources/entities/player.tres") as Player
		frames = data.animations['idle' if sprite_name.contains('idle') else 'move' if sprite_name.contains('move') else 'attack'].to_sprite_frames(sprite_name)
	else:
		var sprite_sheet = load("res://art/cell_animations/%s.png" % [sprite_name])
		frames.add_animation(sprite_name)
		frames.set_animation_loop(sprite_name, animation_dictionary[sprite_name].loop)
		if animation_dictionary[sprite_name].despawn:
			animation_finished.connect(_on_animation_finished)
		var image = sprite_sheet.get_image()
		for y in range(animation_dictionary[sprite_name].rows):
			for x in range(animation_dictionary[sprite_name].used_columns):
				var rect = Rect2(x * frame_width, y * frame_height, frame_width, frame_height)
				var frame_image = image.get_region(rect)
				var frame_tex = ImageTexture.create_from_image(frame_image)
				frames.add_frame(sprite_name, frame_tex)
	sprite_frames = frames
	animation =  sprite_name
	if not paused:
		play()
	for light in point_lights:
		var shadow_instance = shadow.duplicate() as AnimatedSprite2D
		var base_material = shadow.material
		var new_material = base_material.duplicate() as ShaderMaterial
		shadow_instance.material = new_material
		shadow_instance.visible = true
		shadow_instance.centered = true
		shadow_instance.sprite_frames = frames
		shadow_instance.animation = sprite_name
		if not paused:
			shadow_instance.play()
		#shadow_instance.animation_finished.connect(_on_animation_finished)
		var base_offset_change = Vector2i(0,-11)
		if data and data.animations.has('idle' if sprite_name.contains('idle') else 'attack'):
			shadow_instance.offset = data.animations['idle' if sprite_name.contains('idle') else 'attack'].offset
		else:
			shadow_instance.offset = base_offset_change
		shadow_instance.position = Vector2(base_offset_change.x, -base_offset_change.y)
		add_child(shadow_instance)
		shadow_instances.append(shadow_instance)
	shadow.visible = false

func _on_animation_finished():
	var weapon = InventoryManager.equipped[8].value.item_name
	WeaponScript.on_weapon_animation_finished(affected_cells)
	WeaponScript.current_attack.erase(self)
	queue_free()

func pause_animation():
	if is_playing():
		pause()
		for shadow in shadow_instances:
			shadow.pause()
	else:
		play()
		for shadow in shadow_instances:
			shadow.play()
