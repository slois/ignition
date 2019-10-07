extends TileMap

var tile_size = get_cell_size()
var half_tile_size = tile_size / 2;

var grid_size = Vector2(16, 16)
var grid = []

func _ready() -> void:
	initialize_grid()
	
	# Examples
	
	var Block = get_node("Block")
	var Block2 = get_node("Block2")
	var Block3 = get_node("Block3")
	var Block4 = get_node("Block4")
	
	var start_pos = update_child_pos(Block)
	Block.position = start_pos
	
	Block2.position = grid2position(Vector2(0,15))
	grid[0][15] = Block2
	
	Block3.position = grid2position(Vector2(1,0))
	grid[1][0] = Block3
	
	Block4.position = grid2position(Vector2(0,4))
	grid[0][4] = Block4
	
func initialize_grid():
	for i in range(grid_size.x):
		grid.append([])
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

func _on_Timer_timeout() -> void:
	pass
	
