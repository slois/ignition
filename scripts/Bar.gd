extends HBoxContainer

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Gauge.value = 0

func increase(delta):
	var count = float($Count/Background/Number.text)
	$Count/Background/Number.text = str(count + delta)
	$Gauge.value += delta
