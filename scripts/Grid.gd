extends TileMap

var tile_size = get_cell_size()
var half_tile_size = tile_size / 2;

# Grid position: (x, y) x=columns; y=rows

var grid_size = Vector2(10, 6)
var grid = []
var rnd = RandomNumberGenerator.new()

func _ready() -> void:
	set_physics_process(true)
	initialize_grid()
	rnd.randomize()
	print_grid()
	
func initialize_grid():
	# Columns
	for i in range(grid_size.x):
		grid.append([])
		# Rows
		for j in range(grid_size.y):
			grid[i].append(null)

func _physics_process(delta):
	if Input.is_action_just_released("ui_up"):
		print("Press UP")
		var hmatches = find_horizontal_matches(3)
		remove_matches(hmatches)
		#var vmatches = find_vertical_matches(3)
		
func remove_matches(matches):
	for cell_matches in matches:
		remove_cells(cell_matches)

func remove_cells(cells):
	print(cells)
	return(null)
	for cell in cells:
		if not is_empty(cell):
			var block = grid[cell.x][cell.y]
			grid[cell.x][cell.y] = null
			block.free()
	
func update_child_pos(child_node):
	var grid_pos = world_to_map(child_node.position)
	var new_grid_pos = grid_pos + child_node.direction
	var limits_status = new_grid_pos.x < grid_size.x and new_grid_pos.x >= 0 and new_grid_pos.y < grid_size.y and new_grid_pos.y >= 0
	
	var target_pos = Vector2()
		
	if limits_status and is_empty(new_grid_pos):
		grid[grid_pos.x][grid_pos.y] = null
		grid[new_grid_pos.x][new_grid_pos.y] = child_node
		target_pos = map_to_world(new_grid_pos) + half_tile_size
	else:
		grid[grid_pos.x][grid_pos.y] = child_node
		target_pos = map_to_world(grid_pos) + half_tile_size
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


func find_horizontal_matches(match_length: int):
	var all_matches = []
	for row in range(0, grid_size.y - 1):
		var my_match = []
		var last_match_type = null
		for col in range(0, grid_size.x):
			var block_type = grid[col][row].type if grid[col][row] else null
			if block_type and not block_type == last_match_type:
				if len(my_match) >= match_length:
					all_matches.append(my_match)
				my_match = []
			if not block_type == null:
				my_match.append(Vector2(col, row))
				last_match_type = block_type
		if len(my_match)>=match_length:
			all_matches.append(my_match)
	return all_matches	

func find_vertical_matches(match_length: int):
	var all_matches = []
	for col in range(0, grid_size.x - 1):
		var my_match = []
		var last_match_type = null
		for row in range(0, grid_size.y):
			var block_type = grid[col][row].type if grid[col][row] else null
			if block_type and not block_type == last_match_type:
				if len(my_match) >= match_length:
					all_matches.append(my_match)
				my_match = []
			if not block_type == null:
				my_match.append(Vector2(col, row))
				last_match_type = block_type
		if len(my_match)>=match_length:
			all_matches.append(my_match)
	return all_matches

	

func print_grid():
	for row in range(0, grid_size.y-1):
		for col in range(0, grid_size.x):
			var block_type = grid[col][row].type if grid[col][row] else null
			print("(" + str(col) + ", " + str(row) +") -> " + str(block_type))
			

	
	
	
	
