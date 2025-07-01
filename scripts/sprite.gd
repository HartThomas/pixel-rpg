extends Sprite2D

@onready var shadow: Sprite2D = $Shadow
@onready var point_lights: Array[PointLight2D]
var sprite_name: String
var shadow_instances : Array[Sprite2D] = []

var shadow_offset_dictionary : Dictionary = {tree= Vector2(0.0,-21.0), bush= Vector2(0.0, -1.0), rock=Vector2(0.0,-21.0), small_bush=Vector2(0.0,-11.0), signpost=Vector2(0.0,-11.0), ruin=Vector2(0.0,-9.0)}

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
		self.modulate = Color(brightness, brightness, brightness, 1.0)

func _ready() -> void:
	texture = load("res://art/sprites/%s.png" % [sprite_name.to_lower()])
	var shadow_texture = load("res://art/sprites/%s_shadow.png" % [sprite_name.to_lower()])
	for light in point_lights:
		var shadow_instance = shadow.duplicate() as Sprite2D
		var base_material = shadow.material
		var new_material = base_material.duplicate() as ShaderMaterial
		shadow_instance.material = new_material
		shadow_instance.visible = true
		shadow_instance.texture = shadow_texture
		shadow_instance.centered = true
		shadow_instance.offset = shadow_offset_dictionary[sprite_name]
		shadow_instance.position = Vector2(shadow_offset_dictionary[sprite_name].x, -shadow_offset_dictionary[sprite_name].y)
		add_child(shadow_instance)
		shadow_instances.append(shadow_instance)
	shadow.visible = false
	if texture.get_height() == 64:
		position.y -= 16
