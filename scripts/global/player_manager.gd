extends Node

var player_stats : Player

func _ready():
	var player = load("res://resources/entities/player.tres") as Player
	player_stats = player
	update_healthbar()

func player_takes_damage(amount: int) -> void:
	player_stats.health -= amount
	var amount_after_damage = update_healthbar()
	if amount_after_damage > 75:
		get_tree().current_scene.get_node("Gui").after_damage_above_75()
	elif amount_after_damage>50:
		get_tree().current_scene.get_node("Gui").after_damage_above_50()
	elif amount_after_damage>25:
		get_tree().current_scene.get_node("Gui").after_damage_above_25()
	elif amount_after_damage>0:
		get_tree().current_scene.get_node("Gui").after_damage_above_0()

func update_healthbar() -> int:
	var healthbar = get_tree().current_scene.get_node("Gui/Control/HealthBar") as TextureProgressBar
	healthbar.max_value = player_stats.max_health
	healthbar.value = player_stats.health
	return (healthbar.value / healthbar.max_value) * 100
