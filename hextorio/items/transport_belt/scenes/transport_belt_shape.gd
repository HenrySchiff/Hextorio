class_name TransportBeltShape extends Shape

@onready var arrows: Array[PathFollow2D] = [
	$Path2D/Arrow1,
	$Path2D/Arrow2,
	$Path2D/Arrow3
]

# given by resource on instantiaton
var belt_speed: int
var color: Color

var hex_points: Array[Vector2]
var belt_line: PackedVector2Array

var input_index = 3
var output_index = 0

func _ready():
	var belt_type: BeltType = item_type.subtype as BeltType
	belt_speed = belt_type.belt_speed
	color = belt_type.color
	
	$Path2D/Arrow1/Polygon2D.color = color
	$Path2D/Arrow2/Polygon2D.color = color
	$Path2D/Arrow3/Polygon2D.color = color
	
	hex_points = HexUtil.get_hex_points(HexUtil.INNER_RADIUS)
	update_belt_line()

func _process(_delta: float) -> void:
	#for arrow in $Path2D.get_children():
		#arrow.progress += belt_speed * delta
		
	var base_progress = ProgressSync.progress
	var offset = 96.0 / 3.0

	for i in range(arrows.size()):
		arrows[i].progress = fmod(base_progress + i * offset, 96.0) * (belt_speed / 50.0)

func _copy(other: Shape):
	super(other)
	var other_belt: TransportBeltShape = other as TransportBeltShape
	#self.set_belt_line(other_belt.belt_line)
	self.input_index = other.input_index
	self.output_index = other.output_index
	self.update_belt_line()

func _set_rotation_whole(input: int, output: int):
	input_index = input
	output_index = output
	update_belt_line()

func _set_rotation_end(index: int):
	output_index = index
	update_belt_line()

func _rotate_whole(direction: int):
	var new_input = posmod(input_index + direction, 6)
	var new_output = posmod(output_index + direction, 6)
	_set_rotation_whole(new_input, new_output)
	
func _rotate_end(direction: int):
	var new_output = posmod(output_index + direction, 6)
	_set_rotation_end(new_output)

func _flip_horizontal():
	input_index = posmod(3 - input_index, 6)
	output_index = posmod(3 - output_index, 6)
	update_belt_line()

func update_belt_line():
	belt_line = PackedVector2Array([hex_points[input_index], Vector2.ZERO, hex_points[output_index]])
	set_belt_line(belt_line)

func set_belt_line(line: PackedVector2Array):
	self.points = line
	$Path2D.curve.clear_points()
	for i in range(line.size()):
		var point = line[i]
		if i == 0:
			point *= 5.0/4.0
		if i == line.size() - 1:
			point *= 7.0/4.0
		$Path2D.curve.add_point(point)
