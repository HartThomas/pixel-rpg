extends Attack


func get_affected_cells() -> Array[Vector2i]:
	var center = target_cell
	var offsets: Array[Vector2i] = [
		Vector2i(0, 0),
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1)
	]
	var affected:  Array[Vector2i] = []
	for offset in offsets:
		affected.append(center + offset)
	return affected

func execute():
	var affected_cells = get_affected_cells()
	return affected_cells
