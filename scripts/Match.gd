## Class Match
## Manage Match on GridMap

class Match:
	var _cells
	var _type
	
	func _init(cells, type):
		self._cells = cells if cells else []
		self._type = type if type else null
	
	func get_type():
		return self._type
	
	func get_cells():
		return self._cells
	
	func add_cell(cell):
		return self._cells.append(cell)
	
	func length():
		return self._cells.size()
	

