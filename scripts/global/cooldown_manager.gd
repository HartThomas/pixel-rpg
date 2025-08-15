extends Node

# Stores cooldowns as { name: { time_left, total_time } }
var cooldowns : Dictionary = {}

func start_cooldown(node: Object, name : String, duration: float) -> void:
	if not cooldowns.has(node):
		cooldowns[node] = {}
	cooldowns[node][name] = {
		"time_left": duration,
		"total_time": duration
	}

func is_on_cooldown(node: Object, name: String) -> bool:
	return cooldowns.has(node) \
		and cooldowns[node].has(name) \
		and cooldowns[node][name]["time_left"] > 0

func get_cooldown_time_left(name: String) -> float:
	return cooldowns.get(name, {}).get("time_left", 0.0)

func get_cooldown_progress(name: String) -> float:
	# Returns 0.0–1.0
	if not cooldowns.has(name): return 0.0
	var cd = cooldowns[name]
	return 1.0 - (cd["time_left"] / cd["total_time"])

func _process(delta: float) -> void:
	for node in cooldowns.keys():
		for name in cooldowns[node].keys():
			cooldowns[node][name]["time_left"] -= delta
			if cooldowns[node][name]["time_left"] <= 0:
				cooldowns[node].erase(name)
		if cooldowns[node].is_empty():
			cooldowns.erase(node)
