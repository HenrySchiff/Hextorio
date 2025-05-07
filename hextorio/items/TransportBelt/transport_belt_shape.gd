class_name TransportBeltShape extends Shape

const hex_radius: int = 32
var hex_points: Array[Vector2]
var belt_line: PackedVector2Array

var input_index = 0
var output_index = 3


func _ready():
	for i in range(6.0):
		hex_points.append(Vector2(cos(i / 3.0 * PI), sin(i / 3.0 * PI)) * hex_radius)
	update_belt_line()

func _process(delta):
	for arrow in $Path2D.get_children():
		arrow.progress_ratio += delta * 0.5

func _copy(other: Shape):
	super(other)
	var other_belt: TransportBeltShape = other as TransportBeltShape
	self.set_belt_line(other_belt.belt_line)
	self.sync_arrows(other_belt)
	self.input_index = other.input_index
	self.output_index = other.output_index

func _rotate_whole(direction: int):
	output_index = (output_index + direction) % 6
	input_index = (input_index + direction) % 6
	update_belt_line()

func _rotate_end(direction: int):
	output_index = (output_index + direction) % 6
	update_belt_line()
	
func _flip_horizontal():
	input_index = (3 - input_index) % 6
	output_index = (3 - output_index) % 6
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

func sync_arrows(other_belt):
	for i in range($Path2D.get_child_count()):
		var arrow: PathFollow2D = $Path2D.get_child(i)
		var other_arrow: PathFollow2D = other_belt.get_node("Path2D").get_child(i)
		arrow.progress_ratio = other_arrow.progress_ratio
