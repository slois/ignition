extends Node2D

var rnd = RandomNumberGenerator.new()
onready var factory = preload("res://scenes/BlockFactory.tscn").instance()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rnd.randomize()
	
func spawn_block():
	var block = factory.generate_block(rnd.randi_range(0, factory.get_child_count()-1))
	block.position = $Position.position
	return block

func move_to(pos):
	$Position.position = pos

func random_position(x_min, x_max):
	var rndpos = rnd.randf_range(x_min, x_max)
	move_to(Vector2(rndpos, $Position.position.y))

