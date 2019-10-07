extends TileMap

var tile_size = get_cell_size()
var half_tile_size = tile_size / 2;

var grid_size = Vector2(16, 16)
var grid = []

func _ready() -> void:
	initialize_grid()
	
	var Block = get_node("Block")
	var start_pos = update_child_pos(Block)
	Block.position = start_pos

func initialize_grid():
	for i in range(grid_size.x):
		grid.append([])
		for j in range(grid_size.y):
			grid[i].append(null)

func update_child_pos(child_node):
	var grid_pos = world_to_map(child_node.position)
	print(grid_pos)
	grid[grid_pos.x][grid_pos.y] = null
	
	var new_grid_pos = grid_pos + child_node.direction
	grid[new_grid_pos.x][new_grid_pos.y] = child_node
	
	var target_pos = map_to_world(new_grid_pos) + half_tile_size
	return target_pos