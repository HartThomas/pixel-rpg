extends "res://scripts/animatable_sprite.gd"

var path: Array[Vector2i] = []
var move_speed := 5.0 # tiles per second

func _process(delta: float) -> void:
	super._process(delta)
	# If we have a path and are NOT on cooldown, move to next tile
	if path.size() > 0 and not CooldownManager.is_on_cooldown(self, "move"):
		EnemyManager.move_player()
		# Start cooldown for movement
		var move_delay = 1.0 / move_speed
		CooldownManager.start_cooldown(self, "move", move_delay)

func _ready() -> void: super._ready()

func move_player(target: Vector2i) -> void:
	var current_grid = (position / 32).floor()
	path = GameScript.astar_grid.get_id_path(current_grid, target)
