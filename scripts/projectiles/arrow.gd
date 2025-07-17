extends Projectile

var speed :float = 300.0
var velocity

func _process(delta: float) -> void:
	var distance_to_target = global_position.distance_to(target_cell)
	var step = speed * delta
	if step >= distance_to_target:
		global_position = target_cell
		queue_free()
	else:
		global_position += velocity * delta

func _ready() -> void:
	var new_texture = load("res://art/sprites/%s.png" % [projectile_name])
	texture = new_texture
	velocity = (target_cell - global_position).normalized() * speed
	rotation = velocity.angle()


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area and area.get_parent().has_method('take_damage'):
		area.get_parent().take_damage(5)
		queue_free()
