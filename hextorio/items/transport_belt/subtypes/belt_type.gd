class_name BeltType extends Resource

@export var belt_speed: int = 50
@export var underground_distance: int = 4
@export var color: Color = Color.YELLOW

func _init(_belt_speed = 50, _underground_distance = 4, _color = Color.YELLOW):
	belt_speed = _belt_speed
	underground_distance = _underground_distance
	color = _color
