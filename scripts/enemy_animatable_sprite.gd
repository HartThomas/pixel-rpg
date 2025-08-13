extends 'res://scripts/animatable_sprite.gd'

var enemy_data : Enemy

var path: Array[Vector2i] = []

var move_timer = 0.0
var move_delay: float
var cell_size: int = 32
var recalc_path_timer: float = 0.0

enum {
	IDLE,
	AGGRO,
	ATTACK
}

var state = IDLE

func _ready() -> void:
	sprite_name = enemy_data.enemy_name
	super._ready()
	move_delay = 1.0 / enemy_data.speed
	position = ((enemy_data.position * 32) + Vector2i(16,16))

func _process(delta: float) -> void:
	super._process(delta)
	var distance_to_player = position.distance_to(GameScript.player_position)
	if distance_to_player <= 32:
		state = ATTACK
	elif distance_to_player <200:
		if state != AGGRO:
			state = AGGRO
			recalculate_path()
	else:
		if state != AGGRO:
			state = IDLE
	match state: 
		AGGRO:
			recalc_path_timer += delta
			if recalc_path_timer >= 0.5: # recalc path twice every second
				recalc_path_timer = 0.0
				recalculate_path()
		ATTACK:
			pass
		IDLE:
			pass
	if path.size() > 0:
		move_timer += delta

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
	enemy_data.health -= amount
	if enemy_data.health <=0:
		die()

func die():
	GameScript.remove_entity_from_cell((position/32).floor())
	GameScript.astar_grid.set_point_solid((position/32).floor(), false)
	EnemyManager.enemies.erase(self)
	ItemManager.create_item(generate_loot(), position)
	queue_free()

func generate_loot() -> Item:
	var loot_gen = LootGenerator.new()
	var loot = loot_gen.generate_loot(enemy_data.loot_table)
	print("Loot dropped: %s" % loot.item_name)
	for ability in loot.abilities:
		print("- Ability: %s" % ability.name + ' - ' + ability.description)
	return loot 
