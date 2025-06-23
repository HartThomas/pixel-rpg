extends Sprite2D
@onready var shadow: Sprite2D = $Shadow
@onready var point_light_2d: PointLight2D = $"../PointLight2D"

func _process(delta: float) -> void:
	var light_position = point_light_2d.position
	var light_dir = (position - light_position).normalized()
	var shadow_angle = light_dir.angle() + (PI * 0.5) 
	var light_distance = position.distance_to(light_position)
	var scale_y = clamp(light_distance / 100.0,1.0, 1.5)
	var shader = shadow.material as ShaderMaterial
	if shadow:
		shadow.skew = shadow_angle
		var color: Color = shader.get_shader_parameter("color")
		var light_distance_fade = clamp(1.0 - (light_distance / 200.0), 0.0, 1.0)
		color.a = light_distance_fade
		shader.set_shader_parameter("color", color)
