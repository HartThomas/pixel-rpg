extends Attack

func execute():
	var affected_cells = get_affected_cells()
	return affected_cells

func _ready() -> void:
	print(execute())
