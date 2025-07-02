extends Attack


func get_affected_cells() -> Array[Vector2i]:
	var center = target_cell
	var offsets = [
		Vector2i(0, 0), # the main hit
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1)
	]
	return offsets.map(func(offset): return center + offset)

func execute():
	for cell in get_affected_cells():
		var world_pos = cell
		# spawn animation or effect at world_pos
		print("Hammer hits: ", cell)
