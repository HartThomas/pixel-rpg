extends Sprite2D
@onready var attack: Sprite2D = $Attack

var fluctuating_up = true
var transparency = 0.5
var weapon : String = 'hammer'

func _ready() -> void:
	load_texture()

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

func load_texture() :
	var attack_texture = load("res://art/sprites/%s_attack.png" % [weapon])
	attack.texture = attack_texture
