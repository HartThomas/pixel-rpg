extends Sprite2D


var fluctuating_up = true
var transparency = 0.5

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if transparency > 0.9:
		fluctuating_up = false
	if transparency < 0.5:
		fluctuating_up = true
	
	if fluctuating_up:
		transparency += 1 * delta
	else:
		transparency -= 1 * delta
	self_modulate.a = transparency
