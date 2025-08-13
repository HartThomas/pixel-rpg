extends Projectile

var speed :float = 300.0
var velocity
var paused: bool = false
var damage: int = 0

func _ready() -> void:
	var new_texture = load("res://art/sprites/%s.png" % [projectile_name])
	texture = new_texture
	velocity = (target_cell - global_position).normalized() * speed
	rotation = velocity.angle()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area and area.get_parent().has_method('take_damage'):
		area.get_parent().take_damage(damage)
		WeaponScript.projectiles.erase(self)
		queue_free()
