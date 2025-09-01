extends 'res://scripts/animatable_sprite.gd'

var path: Array[Vector2i] = []

var move_timer = 0.0
var move_delay: float
var cell_size: int = 32
var recalc_path_timer: float = 0.0
var move_speed : float = 5.0

enum States {
	IDLE,
	AGGRO,
	ATTACK
}

var state = States.IDLE
var prev_state = null

func _ready() -> void:
	sprite_name = sprite_data.name
	super._ready()
	move_delay = 1.0 / sprite_data.speed
	position = ((sprite_data.position * 32) + Vector2i(16,16))

func _process(delta: float) -> void:
	super._process(delta)
	var distance_to_player = position.distance_to(GameScript.player_position)
	match state: 
		States.AGGRO:
			recalc_path_timer += delta
			if recalc_path_timer >= 0.5: # recalc path twice every second
				recalc_path_timer = 0.0
				recalculate_path()
			if distance_to_player < 64:
				set_state(States.ATTACK)
		States.ATTACK:
			if distance_to_player >= 64:
				set_state(States.AGGRO)
		States.IDLE:
			if distance_to_player < 200:
				set_state(States.AGGRO)
	if path.size() > 0:
		move_timer += delta
	if path.size() > 0 and not CooldownManager.is_on_cooldown(self, "move"):
		var next_tile = path.pop_front()
		if next_tile:
			EnemyManager.move_enemy(self, next_tile * 32 + Vector2i(16,16),position)
		# Start cooldown for movement
		var move_delay = 1.0 / move_speed
		CooldownManager.start_cooldown(self, "move", move_delay)

func set_state(new_state):
	if new_state == state:
		return # already in this state
	prev_state = state
	state = new_state
	_on_state_enter(state)

func _on_state_enter(new_state):
	match new_state:
		States.IDLE:
			sprite_name = "bogman_idle"
			setup()
		States.AGGRO:
			sprite_name = "bogman_idle"
			setup()
			recalc_path_timer = 0.0
		States.ATTACK:
			sprite_name = "bogman_attack"
			setup()

func recalculate_path():
	var from = Vector2i(position / 32)
	var to = Vector2i(GameScript.player_position/32)
	if GameScript.astar_grid.is_in_bounds(from.x, from.y) and GameScript.astar_grid.is_in_bounds(to.x, to.y):
		path = GameScript.astar_grid.get_id_path(from, to)
		if path.size() > 1 and path[0] == from:
			path.remove_at(0)
			path.pop_back()
	else:
		print("Missing point in AStar:", from, to)
		path = []

func take_damage(amount:int):
	sprite_data.health -= amount
	if sprite_data.health <=0:
		die()

func die():
	GameScript.remove_entity_from_cell((position/32).floor())
	GameScript.astar_grid.set_point_solid((position/32).floor(), false)
	EnemyManager.enemies.erase(self)
	ItemManager.create_item(generate_loot(), position)
	queue_free()

func generate_loot() -> Item:
	var loot_gen = LootGenerator.new()
	var loot = loot_gen.generate_loot(sprite_data.loot_table)
	print("Loot dropped: %s" % loot.item_name)
	for ability in loot.abilities:
		print("- Ability: %s" % ability.name + ' - ' + ability.description)
	if loot is Weapon:
		loot.apply_modifiers()
	return loot 
