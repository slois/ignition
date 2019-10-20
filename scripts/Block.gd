extends KinematicBody2D

var speed = 0
const MAX_SPEED = 600
var velocity = Vector2()

var grid

var grid_position = Vector2()
var grid_destination = Vector2()

var target_pos = Vector2()
var target_dir = Vector2()

var is_moving: bool = false
var is_ready setget, is_ready_get

var type
var moves: Array


func _ready() -> void:
	set_physics_process(true)
	grid = get_parent()

func is_ready_get():
	#return position == grid.grid_to_world(grid_destination)
	return target_dir == Vector2.ZERO

func _physics_process(delta):
	if not is_moving:
		target_pos = grid.update_position(self)
		target_dir = position.direction_to(target_pos)
		is_moving = position != target_pos
	else:
		var distance_to_target = Vector2(abs(target_pos.x - position.x), abs(target_pos.y - position.y))
		
		speed = MAX_SPEED
		velocity = speed * target_dir * delta
				
		if abs(velocity.x) > distance_to_target.x:
			velocity.x = distance_to_target.x * target_dir.x
			is_moving = false

		if abs(velocity.y) > distance_to_target.y:
			velocity.y = distance_to_target.y * target_dir.y
			is_moving = false
				
		move_and_collide(velocity)

func _on_Block_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		#emit_signal("clicked", message)
		print("Selected")
