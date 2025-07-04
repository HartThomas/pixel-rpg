extends Attack

var directions = [
		Vector2i(1, 0),
		Vector2i(1, 1),
		Vector2i(0, 1),
		Vector2i(-1, 1),
		Vector2i(-1, 0),
		Vector2i(-1, -1),
		Vector2i(0, -1),
		Vector2i(1, -1),
	]

func get_affected_cells() -> Array[Vector2i]:
	var cells :  Array[Vector2i] = []
	var start = directions.find(target_cell)
	for i in range(3):
		var index = (start + i) % directions.size()
		var offset = directions[index]
		cells.append(player_cell + offset)
	return cells

func execute():
	var affected_cells = get_affected_cells()
	return affected_cells
