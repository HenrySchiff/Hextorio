class_name SplitterShape extends Shape

@onready var rectangle: Polygon2D = $Rectangle

var belt_type: ItemType = preload("res://items/TransportBelt/transport_belt.tres")
var left_belt_shape: TransportBeltShape 
var right_belt_shape: TransportBeltShape 

func _init():
	occupied_tiles = HexUtil.DIHEX
	icon_scale = Vector2(0.25, 0.25)
	item_scale = Vector2(0.1, 0.1)
	
func _ready():
	left_belt_shape = Shape.new_shape(belt_type)
	add_child(left_belt_shape)
	left_belt_shape._rotate_whole(-1)
	
	right_belt_shape = Shape.new_shape(belt_type)
	add_child(right_belt_shape)
	right_belt_shape._rotate_whole(-1)
	right_belt_shape.position = HexUtil.hex_to_screen(occupied_tiles[1])

func _rotate_whole(_direction: int):
	occupied_tiles = HexUtil.rotate_polyhex(occupied_tiles, _direction)
	$Rectangle.rotate(PI * 1/3 * _direction)
	right_belt_shape.position = HexUtil.hex_to_screen(occupied_tiles[1])
	left_belt_shape._rotate_whole(_direction)
	right_belt_shape._rotate_whole(_direction)
	
func _flip_horizontal():
	left_belt_shape._flip_horizontal()
	right_belt_shape._flip_horizontal()
	
func _flip_vertical():
	pass

func _copy(_other: Shape):
	self.rectangle.rotation = _other.rectangle.rotation
	self.occupied_tiles = _other.occupied_tiles
	self.right_belt_shape.position = _other.right_belt_shape.position
	
	self.left_belt_shape._copy(_other.left_belt_shape)
	self.right_belt_shape._copy(_other.right_belt_shape)
