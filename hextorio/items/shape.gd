class_name Shape extends Node2D

# The tiles that this shape occupies (aka its polyhex) relative to its center (0, 0)
var occupied_tiles: Array[Vector2i] = Global.MONOHEX
var icon_scale: Vector2 = Vector2(1, 1)
var item_scale: Vector2 = Vector2(0.5, 0.5)

func _rotate_whole(direction: int):
	pass
	
func _rotate_end(direction: int):
	pass
	
func _flip_horizontal():
	pass
	
func _flip_vertical():
	pass

func _copy(other: Shape):
	#self.position = other.position
	pass
