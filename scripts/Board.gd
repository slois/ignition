extends Node2D

export (PackedScene) var Cell_scene
export (int) var width
export (int) var height
export (int) var offset
export (int) var cell_size
export (int) var ncells
var grid_array
var rnd = RandomNumberGenerator.new()

func _ready() -> void:
	ncells = width * height
	grid_array = initialize_grid(width, height)
	rnd.randomize()

func generate_cell(name, position):
	var cell_instance = Cell_scene.instance()
	cell_instance.set_name(name)
	cell_instance.position = position
	add_child(cell_instance)
	return cell_instance
	
func initialize_grid(width, height):
	grid_array = []
	for row in range(0, height):
		grid_array.append([])
		for col in range(0, width):
			var x_pos = ((col + 1) * offset) + (cell_size * col)
			var y_pos = ((row + 1) * offset) + (cell_size * row)
			var position = Vector2(x_pos, y_pos)
			grid_array[row].append(generate_cell("cell:r" + str(row) + "_c" + str(col), position))
	return grid_array
			
func get_cell(row, col):
	return grid_array[row][col]

func get_available_cells():
	var available_cells = []
	for col in range(0, width):
		for row in range(height-1, -1, -1):
			var cell = get_cell(row, col)
			if cell.is_empty():
				available_cells.append(cell)
				break
	return available_cells

func _on_Timer_timeout() -> void:
	var free_cells = get_available_cells()
	if len(free_cells) > 0:
		var free_cell = free_cells[rnd.randi_range(0, len(free_cells)-1)]
		var my_position = free_cell.get_position()
		$Spawner.move_to(my_position)
		var block = $Spawner.spawn_block()
		free_cell.add_content(block)
		block.position = Vector2(0, -my_position.y-66)
		print(block.position)