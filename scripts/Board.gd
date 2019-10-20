extends Node2D

var rnd = RandomNumberGenerator.new()

enum INIT_MODE {filled, empty}
export (INIT_MODE) var init_mode

enum FILL_MODE {rain, grow, appear}
export (FILL_MODE) var fill_mode

export var block_movement: bool

var free_cell_function

export var match_length: int
export var match_checking: bool
export var matches_queue = []

export var time_trigger: bool

var block_selected

var PatternClass = preload("res://scripts/Pattern.gd")

var INV_T = PatternClass.Pattern.new([Vector2(0,0), Vector2(-1,0), Vector2(1,0), Vector2(0, 1)], 'inverted_t')
var T = PatternClass.Pattern.new([Vector2(0,0), Vector2(-1,0), Vector2(1,0), Vector2(0, -1)], 't')
var SQUARE =  PatternClass.Pattern.new([Vector2(0,0), Vector2(0,1), Vector2(1,0), Vector2(1,1)], 'square')
var MEGA_T = PatternClass.Pattern.new([Vector2(0,0), Vector2(-1,0), Vector2(-2,0), Vector2(1,0), Vector2(2,0), Vector2(0,-1), Vector2(0,-2)], 'mega_t')
var MEGA_INV_T = PatternClass.Pattern.new([Vector2(0,0), Vector2(-1,0), Vector2(-2,0), Vector2(1,0), Vector2(2,0), Vector2(0,1), Vector2(0,2)], 'inverted_mega_t')
var MEGA_T_LEFT = PatternClass.Pattern.new([Vector2(0,0), Vector2(0,-1), Vector2(0,-2), Vector2(0,1), Vector2(0,2), Vector2(1,0), Vector2(2,0)], 'mega_t_left')
var MEGA_T_RIGHT = PatternClass.Pattern.new([Vector2(0,0), Vector2(0,-1), Vector2(0,-2), Vector2(0,1), Vector2(0,2), Vector2(-1,0), Vector2(-2,0)], 'mega_t_right')
var T_LEFT = PatternClass.Pattern.new([Vector2(0,0), Vector2(0,-1), Vector2(0,1), Vector2(1, 0)], 't_left')
var T_RIGHT = PatternClass.Pattern.new([Vector2(0,0), Vector2(0,-1), Vector2(0,1), Vector2(-1, 0)], 't_right')

var SPECIALS = [SQUARE, T, T_LEFT, T_RIGHT, INV_T, MEGA_T, MEGA_INV_T, MEGA_T_LEFT, MEGA_T_RIGHT]


func _ready() -> void:
	rnd.randomize()
	if time_trigger:
		$Timer.start()
	else:
		$Timer.stop()
	load_fill_mode()
	load_init_mode()
	
	set_physics_process(true)

func _physics_process(delta):
	if match_checking:
		pass



func fill(n=null) -> void:
	var free_cells = free_cell_function.call_func()
	
	if free_cells.size() == 0:
		return
	
	if not n:
		n = free_cells.size()

	while n > 0:
		var free_cell_pos = free_cells[rnd.randi_range(0, len(free_cells)-1)]
		var block = $Factory.spawn()
		var destination
		if block_movement:
			destination = $GridMap.deepest_cell_by_column(free_cell_pos.x)
		else:
			destination = free_cell_pos
		$GridMap.add_to_grid(block, free_cell_pos, destination)
		
		n -= 1

func _on_Timer_timeout() -> void:
	fill(1)
		
func load_fill_mode():
	if fill_mode == FILL_MODE.rain:
		free_cell_function = funcref($GridMap, 'first_row_empty_cells')
	elif fill_mode == FILL_MODE.grow:
		free_cell_function = funcref($GridMap, 'deepest_empty_cells')
	elif fill_mode == FILL_MODE.appear:
		free_cell_function = funcref($GridMap, 'empty_cells')
	else:
		print("Default")

func load_init_mode():
	if init_mode == INIT_MODE.filled:
		fill()
	elif init_mode == INIT_MODE.empty:
		pass
	else:
		print("Default")

func _input(event):
   # Mouse in viewport coordinates
	if event is InputEventMouseButton and event.is_pressed():
		var cell_pos = $GridMap.world_to_grid(event.position)
		cell_pos.x = int(round(cell_pos.x))
		cell_pos.y = int(round(cell_pos.y))
		
		if $GridMap.is_empty(cell_pos):
			if block_selected:
				block_selected.grid_destination = cell_pos
				block_selected.moves = $GridMap.shortest_path(block_selected.grid_position, cell_pos, false, true)
				block_selected = null
		else:
			block_selected = $GridMap.grid[cell_pos.x][cell_pos.y]

func _on_GridMap_grid_ready() -> void:
	var parent = get_parent()
	var hmatches = $GridMap.find_horizontal_matches(match_length)
	var vmatches = $GridMap.find_vertical_matches(match_length)
	var sp_matches = $GridMap.find_special_matches(SPECIALS)
	
	for hmatch in hmatches:
		if not matches_queue.has(hmatch):
			matches_queue.append(hmatch)
	
	for vmatch in vmatches:
		if not matches_queue.has(vmatch):
			matches_queue.append(vmatch)
			
	for sp_match in sp_matches:
		if not matches_queue.has(sp_match):
			matches_queue.append(sp_match)
	
	var blocks_removed = 0
	if matches_queue.size() > 0:
		blocks_removed = $GridMap.remove_matches(matches_queue)
		parent.get_node("GUI/HBoxContainer/Bars/Bar").increase(blocks_removed)
	fill(6-blocks_removed)
