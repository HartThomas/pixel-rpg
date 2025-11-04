extends Attack

@export var spear_length: int = 2

func get_affected_cells() -> Array[Vector2i]:
	var dir : Vector2i = target_cell - player_cell
	var cells : Array[Vector2i] = []
	for i in range(1,spear_length+1):
		cells.append((i * dir) + player_cell)
	return cells

func execute():
	var affected_cells = get_affected_cells()
	return affected_cells
