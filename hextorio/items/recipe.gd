class_name Recipe extends Resource

@export var inputs: Dictionary[ItemType, int]
@export var quantity: int
@export var craft_time: float

var empty: Dictionary[ItemType, int] = {}

func _init(_inputs = empty, _quantity = 1, _craft_time = 0):
	inputs = _inputs
	quantity = _quantity
	craft_time = _craft_time
