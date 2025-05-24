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
	self.set_belt_line(other_belt.belt_line)
	#self.sync_arrows(other_belt)
	self.input_index = other.input_index
	self.output_index = other.output_index

func _rotate_whole(direction: int):
	output_index = posmod(output_index + direction, 6)
	input_index = posmod(input_index + direction, 6)
	update_belt_line()

func _rotate_end(direction: int):
	output_index = posmod(output_index + direction, 6)
	update_belt_line()
	
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

func sync_arrows(other_belt):
	for i in range($Path2D.get_child_count()):
		var arrow: PathFollow2D = $Path2D.get_child(i)
		var other_arrow: PathFollow2D = other_belt.get_node("Path2D").get_child(i)
		arrow.progress_ratio = other_arrow.progress_ratio
