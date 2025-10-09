extends Node

var player_stats : Player

func _ready():
	var player = load("res://resources/entities/player.tres") as Player
	player_stats = player
	setup_healthbar()

func player_takes_damage(amount: int) -> void:
	var amount_after_armour = amount - player_stats.armour if amount - player_stats.armour > 0 else 0
	player_stats.health -= amount_after_armour
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
	if healthbar:
		if healthbar.get_parent().get_parent().has_method('update_healthbar_tooltip'):
			healthbar.get_parent().get_parent().update_healthbar_tooltip()
		healthbar.max_value = player_stats.max_health
		healthbar.value = player_stats.health
	return (healthbar.value / healthbar.max_value) * 100

func setup_healthbar() -> int:
	var healthbar = get_tree().current_scene.get_node("Gui/Control/HealthBar") as TextureProgressBar
	if healthbar:
		healthbar.max_value = player_stats.max_health
		healthbar.value = player_stats.health
		return (healthbar.value / healthbar.max_value) * 100
	return 100
