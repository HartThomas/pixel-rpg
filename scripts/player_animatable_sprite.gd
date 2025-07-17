extends 'res://scripts/animatable_sprite.gd'

var path: Array[Vector2i] = []
var move_speed = 5.0 
var move_timer = 0.0
var move_delay = 1.0 / move_speed

func _process(delta: float) -> void:
	super._process(delta)
	if path.size() > 0:
		move_timer += delta

func _ready() -> void:
	super._ready()

func move_player(target: Vector2i):
	var current_grid = (position / 32).floor()
	path = GameScript.astar_grid.get_id_path(current_grid, target)
