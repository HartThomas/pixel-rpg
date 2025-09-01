extends "res://scripts/animatable_sprite.gd"

enum States {
	IDLE,
	MOVE,
	ATTACK
}

var path: Array[Vector2i] = []
var move_speed := 5.0 # tiles per second
var state = States.IDLE
var prev_state = null

func _process(delta: float) -> void:
	super._process(delta)
	# If we have a path and are NOT on cooldown, move to next tile
	if path.size() > 0 and not CooldownManager.is_on_cooldown(self, "move"):
		set_state(States.MOVE)
		EnemyManager.move_player()
		# Start cooldown for movement
		var move_delay = 1.0 / move_speed
		CooldownManager.start_cooldown(self, "move", move_delay)
	elif path.size() == 0 and state == States.MOVE:
		set_state(States.IDLE)

func set_state(new_state, skip = false):
	if new_state == state and !skip:
		return # already in this state
	prev_state = state
	state = new_state
	_on_state_enter(state)

func _on_state_enter(new_state):
	match new_state:
		States.IDLE:
			sprite_name = "player_idle"

			setup()
		States.MOVE:
			sprite_name = "player_move"

			setup()
		States.ATTACK:

			sprite_name = "player_attack"
			setup()

func _ready() -> void: 
	super._ready()
	set_state(States.IDLE, true)

func move_player(target: Vector2i) -> void:
	var current_grid = (position / 32).floor()
	path = GameScript.astar_grid.get_id_path(current_grid, target)
