extends TileMap

var tile_size = get_cell_size()
var half_tile_size = tile_size / 2;

# Grid position: (x, y) x=columns; y=rows

var grid_size = Vector2(9, 12)
var grid = []
var rnd = RandomNumberGenerator.new()

func _ready() -> void:
	initialize_grid()
	rnd.randomize()
	
func initialize_grid():
	# Columns
	for i in range(grid_size.x):
		grid.append([])
		# Rows
		for j in range(grid_size.y):
			grid[i].append(null)

func update_child_pos(child_node):
	var grid_pos = world_to_map(child_node.position)
	var new_grid_pos = grid_pos + child_node.direction
	
	if new_grid_pos.x >= grid_size.x or new_grid_pos.x < 0 or new_grid_pos.y >= grid_size.y or new_grid_pos.y < 0 :
		grid[grid_pos.x][grid_pos.y] = child_node
		new_grid_pos = grid_pos
	else:
		grid[grid_pos.x][grid_pos.y] = null
		grid[new_grid_pos.x][new_grid_pos.y] = child_node
	
	var target_pos = map_to_world(new_grid_pos) + half_tile_size
	return target_pos

func position2grid(node):
	return world_to_map(node.position)

func grid2position(position: Vector2):
	return map_to_world(position) + half_tile_size

func is_empty(pos: Vector2):
	return grid[pos.x][pos.y] == null

func spawn_block(cell_pos: Vector2, fall: bool):
	if fall:
		cell_pos.y = -1
	
	var my_position = grid2position(cell_pos)

	$Spawner.move_to(my_position)
	var block = $Spawner.spawn_block()
	add_child(block)
	
	block.position = my_position
	grid[cell_pos.x][cell_pos.y] = block
	print_grid()

func get_available_cells():
	var available_cells = []
	for col in range(0, grid_size.x):
		for row in range(0, grid_size.y-1):
			var cell_pos = Vector2(grid_size.x - col - 1, grid_size.y - row - 1)
			if is_empty(cell_pos):
				available_cells.append(cell_pos)
				break
	return available_cells

func _on_Timer_timeout() -> void:
	var free_cells = get_available_cells()
	if len(free_cells) > 0:
		var free_cell_pos = free_cells[rnd.randi_range(0, len(free_cells)-1)]
		spawn_block(free_cell_pos, true)
		
func print_grid():
	for row in range(0, grid_size.y-1):
		for col in range(0, grid_size.x):
			print(row, col, grid[col][row])
			

	
	
	
	
