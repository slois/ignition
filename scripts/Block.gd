extends KinematicBody2D

var speed = 0
const MAX_SPEED = 400
var direction = Vector2()

const TOP = Vector2(0, -1)
const RIGHT = Vector2(1, 0)
const LEFT = Vector2(-1, 0)
const DOWN = Vector2(0, 1)



var velocity = Vector2()
var grid
var target_pos = Vector2()
var target_direction = Vector2()
var is_moving = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grid = get_parent()
	set_physics_process(true)


func _physics_process(delta):
	direction = Vector2()
	
	if Input.is_action_pressed("ui_up"):
		direction.y = -1
	elif Input.is_action_pressed("ui_right"):
		direction.x = 1
	elif Input.is_action_pressed("ui_left"):
		direction.x = -1
	elif Input.is_action_pressed("ui_down"):
		direction.y = 1
	else:
		pass
	
	
	if not is_moving and direction != Vector2():
		target_direction = direction
		target_pos = grid.update_child_pos(self)
		is_moving = true
		
	elif is_moving:
		speed = MAX_SPEED
		velocity = speed * target_direction * delta
		
		var pos = position
		var distance_to_target = Vector2(abs(target_pos.x - pos.x), abs(target_pos.y - pos.y))
		
		if abs(velocity.x) > distance_to_target.x:
			velocity.x = distance_to_target.x * target_direction.x
			is_moving = false
		if abs(velocity.y) > distance_to_target.y:
			velocity.y = distance_to_target.y * target_direction.y
			is_moving = false
		
		move_and_collide(velocity)
	
