extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func add_content(object):
	$Container.add_child(object)
	
func is_empty():
	return not $Container.get_child_count() > 0

func clear():
	if not is_empty():
		for child in $Container.get_children():
			child.queue_free()
