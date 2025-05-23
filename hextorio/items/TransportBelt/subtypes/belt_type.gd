class_name BeltType extends Resource

@export var belt_speed: int = 50
@export var underground_distance: int = 4
@export var color: Color = Color.YELLOW

func _init(_belt_speed = 50, _color = Color.YELLOW):
	belt_speed = _belt_speed
	color = _color
