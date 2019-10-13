extends Node2D

signal spawned

var rnd = RandomNumberGenerator.new()

export (Array, PackedScene) var spawnee

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rnd.randomize()
	
func spawn():
	var index = rnd.randi_range(0, spawnee.size()-1)
	var instance = spawnee[index].instance()
	instance.type = index
	emit_signal("spawned", instance)
	return instance