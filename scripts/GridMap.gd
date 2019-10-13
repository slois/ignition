extends Node2D

export var grid_size: Vector2			# Number rows and cols
export var cell_size: Vector2			# Width and height
export var cell_space: float			# Intercell space
export var horizontal_margin: float		# Top and bottom margin
export var vertical_margin: float		# Left and right margin
export var centered: bool				# Origin is centered

var grid = []
var map_to_grid = {}
var map_to_world = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_initialize_grid()
	_initialize_map()

func _initialize_grid() -> void:
	for col in range(grid_size.x):
		grid.append([])
		for row in range(grid_size.y):
			grid[col].append(null)

func _initialize_map() -> void:
	for col in range(grid_size.x):
		for row in range(grid_size.y):
			var grid_pos = Vector2(col, row)
			map_to_world[grid_pos] = grid_to_world(grid_pos)
			map_to_grid[map_to_world[grid_pos]] = grid_pos

func update_position(child_node):
	var next_pos = child_node.position
	
	## Next_move
	if child_node.moves.size() > 0 and is_empty(child_node.moves[0]):
		var next_move = child_node.moves.pop_front()
		grid[child_node.grid_position.x][child_node.grid_position.y] = null
		grid[next_move.x][next_move.y] = child_node
		next_pos = grid_to_world(next_move)
		child_node.grid_position = next_move
	return next_pos

func update_child_pos(child_node):
	var grid_pos = world_to_grid(child_node.position)
	var new_grid_pos = grid_pos + child_node.direction
	var limits_status = new_grid_pos.x < grid_size.x and new_grid_pos.x >= 0 and new_grid_pos.y < grid_size.y and new_grid_pos.y >= 0
	
	var target_pos = Vector2()
		
	if limits_status and is_empty(new_grid_pos):
		grid[grid_pos.x][grid_pos.y] = null
		grid[new_grid_pos.x][new_grid_pos.y] = child_node
		target_pos = grid_to_world(new_grid_pos)
	else:
		grid[grid_pos.x][grid_pos.y] = child_node
		target_pos = grid_to_world(grid_pos)
	return target_pos

func grid_to_world(cell: Vector2) -> Vector2:
	var coord = Vector2()
	var myposition = get_global_transform().get_origin()
	coord.y = myposition.y + vertical_margin + (cell.y + 1) * cell_size.y + (cell.y * cell_space) - (cell_size.y/2) 
	coord.x = myposition.x + horizontal_margin + (cell.x + 1) * cell_size.x + (cell.x * cell_space) - (cell_size.x/2)
	if centered:
		coord += (position - (size()/2))
	return coord

func world_to_grid(pos: Vector2) -> Vector2:
	var coord = Vector2()
	var myposition = get_global_transform().get_origin()
	coord.y = ((cell_size.y/2) + pos.y - myposition.y - vertical_margin - cell_size.y)/(cell_size.y + cell_space)
	coord.x = ((cell_size.x/2) + pos.x - myposition.x - horizontal_margin - cell_size.x)/(cell_size.x + cell_space)
	return coord

func size() -> Vector2:
	var size = Vector2()
	size.x = 2*horizontal_margin + grid_size.x * cell_size.x + cell_space * (grid_size.x - 1)
	size.y = 2*vertical_margin + grid_size.y * cell_size.y + cell_space * (grid_size.y - 1)
	return size

func is_empty(pos: Vector2):
	return grid[pos.x][pos.y] == null

func deepest_empty_cells():
	var available_cells = []
	for col in range(0, grid_size.x):
		for row in range(grid_size.y-1, -1, -1):
			var cell_pos = Vector2(col, row)
			if is_empty(cell_pos):
				available_cells.append(cell_pos)
				break
	return available_cells

func deepest_empty_cell_by_column(col):
	var cell = null
	for row in range(grid_size.y-1, -1, -1):
		var cell_pos = Vector2(col, row)
		if is_empty(cell_pos):
			cell = cell_pos
			break
	return cell

func deepest_cell_by_column(col):
	return Vector2(col, grid_size.y-1)


func empty_cells_by_row(row):
	var cells = []
	for col in range(0, grid_size.x):
		var cell_pos = Vector2(col, row)
		if is_empty(cell_pos):
			cells.append(cell_pos)
	return cells
	
func first_row_empty_cells():
	return empty_cells_by_row(0)


func superficial_empty_cell_by_column(col):
	var cell
	for row in range(0, grid_size.y):
		var cell_pos = Vector2(col, row)
		if not is_empty(cell_pos):
			cell = cell_pos
	if cell:
		return cell + Vector2.UP
	else:
		return deepest_empty_cell_by_column(col)
	
func surface_empty_cells():
	var available_cells = []
	for col in range(0, grid_size.x):
		for row in range(0, grid_size.y):
			var cell_pos = Vector2(col, row)
			if is_empty(cell_pos):
				available_cells.append(cell_pos)
				break
	return available_cells

func empty_cells():
	var available_cells = []
	for col in range(0, grid_size.x):
		for row in range(0, grid_size.y):
			var cell_pos = Vector2(col, row)
			if is_empty(cell_pos):
				available_cells.append(cell_pos)
	return available_cells

func find_horizontal_matches(match_length: int):
	var all_matches = []
	for row in range(0, grid_size.y):
		var my_match = []
		var last_block_type = null
		for col in range(0, grid_size.x):
			var block = grid[col][row]
			if my_match.size() > 0 and (not block or not block.type == last_block_type):
				if my_match.size() >= match_length:
					all_matches.append(my_match.duplicate(true))
				my_match.clear()
			if block and block.is_ready:
				my_match.append(Vector2(col, row))
				last_block_type = block.type
		if my_match.size() >= match_length:
			all_matches.append(my_match.duplicate(true))
	return all_matches

func find_vertical_matches(match_length: int):
	var all_matches = []
	for col in range(0, grid_size.x):
		var my_match = []
		var last_block_type = null
		for row in range(0, grid_size.y):
			var block = grid[col][row]
			if my_match.size() > 0 and (not block or not block.type == last_block_type):
				if my_match.size() >= match_length:
					all_matches.append(my_match.duplicate(true))
				my_match.clear()
			if block and block.is_ready:
				my_match.append(Vector2(col, row))
				last_block_type = block.type
		if my_match.size() >= match_length:
			all_matches.append(my_match.duplicate(true))
	return all_matches

func add_to_grid(object, source, destination):
	if is_empty(source):
		grid[source.x][source.y] = object
		object.position = map_to_world[source]
		object.grid_position = source
		object.grid_destination = destination
		object.moves = shortest_path(source, destination, true, true)
		add_child(object)

func remove_matches(matches):
	for cell_matches in matches:
		remove_cells(cell_matches)

func remove_cells(cells):
	for cell in cells:
		if not is_empty(cell):
			var block = grid[cell.x][cell.y]
			grid[cell.x][cell.y] = null
			block.free()

# Breadth First Search algorithm
func shortest_path(source: Vector2, destination: Vector2, ignore_empty: bool, exclude_source: bool) -> Array:
	if source == destination:
		return []
	
	var queue = []
	var visited = initialize_grid_dict(false)
	
	# Source cell visited and enqueued
	queue.append([source, []])
	visited[source] = true
		
	while queue.size() > 0:
		var q = queue.pop_front()
		var node = q[0]
		var path = q[1]
		for neighbour in get_neighbours(node, ignore_empty):
			if neighbour == destination:
				var final_path = path + [node, neighbour]
				if exclude_source:
					final_path.pop_front()
				return final_path
			if not visited[neighbour]:
				queue.append([neighbour, path + [node]])
				visited[neighbour] = true
	return []

func check_cell(cell):
	return cell.x >= 0 and cell.x < grid_size.x and cell.y >= 0 and cell.y < grid_size.y

func get_neighbours(cell: Vector2, ignore_empty: bool) -> Array:
	var neighbours = []
	for direction in [Vector2.DOWN, Vector2.UP, Vector2.RIGHT, Vector2.LEFT]:
		var neighbour = cell + direction
		if check_cell(neighbour):
			if ignore_empty or is_empty(neighbour):
				neighbours.append(neighbour)
	return neighbours

func initialize_grid_dict(value) -> Dictionary:
	var D = {}
	for col in range(grid_size.x):
		for row in range(grid_size.y):
			D[Vector2(col, row)] = value
	return D


func adjacency_matrix() -> Dictionary:
	var adj = {}
	for col in range(grid_size.x):
		for row in range(grid_size.y):
			adj[Vector2(col, row)] = get_neighbours(Vector2(col, row), true)
	return adj

func swap(cell1: Vector2, cell2: Vector2):
	var tmp1 = grid[cell1.x][cell1.y]
	var tmp2 = grid[cell2.x][cell2.y]
	grid[cell1.x][cell1.y] = null	
	grid[cell2.x][cell2.y] = null
	add_to_grid(tmp1, Vector2(cell2.x, cell2.y), deepest_cell_by_column(cell2.x))
	add_to_grid(tmp2, Vector2(cell1.x, cell1.y), deepest_cell_by_column(cell1.x))

func get_all_cells():
	var cells = []
	for col in range(grid_size.x):
		for row in range(grid_size.y):
			cells.append(Vector2(col,row))
	return cells

func shuffle():
	var cells = get_all_cells()
	cells.shuffle()
	while cells.size() >= 2:	
		var cell1 = cells.pop_front()
		var cell2 = cells.pop_back()
		swap(cell1, cell2)
	
	
	
	