class_name Recipe extends Resource

@export var inputs: PackedStringArray
@export var output: String
@export var quantity: int
@export var craft_time: float
@export var shape: PackedScene

func _init(_inputs = [], _output = "", _quantity = 1, _craft_time = 0, _shape = null):
	inputs = _inputs
	output = _output
	quantity = _quantity
	craft_time = _craft_time
	shape = _shape
