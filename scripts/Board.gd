extends Node2D

var rnd = RandomNumberGenerator.new()

enum MODE {rain, fill, grow}
export (MODE) var mode

enum CELL_FUNCTION {deep, surface, first_row, random}
export (CELL_FUNCTION) var cell_function
var free_cell_function

export var match_length: int

export var match_checking: bool

func _ready() -> void:
	rnd.randomize()
	load_mode()
	load_cell_function()
	set_physics_process(true)

func _physics_process(delta):
	if match_checking:
		var hmatches = $GridMap.find_horizontal_matches(match_length)
		var vmatches = $GridMap.find_vertical_matches(match_length)
		var matches = hmatches + vmatches
		if matches.size() > 0:
			$GridMap.remove_matches(matches)
	if Input.is_action_just_released("ui_down"):
		$GridMap.shuffle()

func _on_Timer_timeout() -> void:
	var free_cells = free_cell_function.call_func()
	if len(free_cells) > 0:
		var free_cell_pos = free_cells[rnd.randi_range(0, len(free_cells)-1)]
		var block = $Factory.spawn()
		var destination = $GridMap.deepest_cell_by_column(free_cell_pos.x)
		$GridMap.add_to_grid(block, free_cell_pos, destination)
		
func fill():
	var cells = $GridMap.empty_cells()
	for cell in cells:
		var block = $Factory.spawn()
		$GridMap.add_to_grid(block, cell)

func load_cell_function():
	if cell_function == CELL_FUNCTION.deep:
		free_cell_function = funcref($GridMap, 'deepest_empty_cells')
	elif cell_function == CELL_FUNCTION.surface:
		free_cell_function = funcref($GridMap, 'surface_empty_cells')
	elif cell_function == CELL_FUNCTION.first_row:
		free_cell_function = funcref($GridMap, 'first_row_empty_cells')
	elif cell_function == CELL_FUNCTION.random:
		free_cell_function = funcref($GridMap, 'empty_cells')
		
func load_mode():
	if mode == MODE.rain:
		$Timer.start(-1)
	elif mode == MODE.fill:
		fill()
	elif mode == MODE.grow:
		$Timer.start(-1)
	else:
		print("Default")


