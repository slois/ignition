## Class Pattern
## Manage Pattern on GridMap

class Pattern:
	var _coords
	var _type

	func _init(coords, type):
		self._coords = coords
		self._type = type

	func get_type():
		return self._type

	func get_coords():
		return self._coords



