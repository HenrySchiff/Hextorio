class_name TransportBelt extends Entity

@onready var left_transport_line: TransportLine = $LeftTransportLine
@onready var right_transport_line: TransportLine = $RightTransportLine

const BELT_SPEED: int = 50

var next_belt: TransportBelt = null

func _ready() -> void:
	shape = $TransportBeltShape
	left_transport_line.belt_speed = BELT_SPEED
	right_transport_line.belt_speed = BELT_SPEED
		
func _sync_shape(shape: Shape, tile_pos: Vector2i) -> void:
	super(shape, tile_pos)
	var belt_shape: TransportBeltShape = shape as TransportBeltShape
	
	var input = belt_shape.input_index
	var output = belt_shape.output_index
	
	left_transport_line.curve.clear_points()
	right_transport_line.curve.clear_points()
	
	var input_pair = Global.HEX_POINTS_LEGEND["SIDE_QUARTER_PAIRS"][input]
	var output_pair = Global.HEX_POINTS_LEGEND["SIDE_QUARTER_PAIRS"][output]
	
	left_transport_line.curve.add_point(input_pair[0])
	left_transport_line.curve.add_point(output_pair[1])
	right_transport_line.curve.add_point(input_pair[1])
	right_transport_line.curve.add_point(output_pair[0])
	
	var diff = (output - input + 6) % 6
	
	if diff == 2 || diff == 4:
		var left_index
		var right_index
		if diff == 2:
			right_index = (input + 1) % 6
			left_index = (right_index + 3) % 6
		else:
			left_index = (input - 1) % 6
			right_index = (left_index + 3) % 6
			
		var left_midpoint = Global.HEX_POINTS_LEGEND["SMALL"][left_index]
		left_transport_line.curve.add_point(left_midpoint, Vector2.ZERO, Vector2.ZERO, 1)
		
		var right_midpoint = Global.HEX_POINTS_LEGEND["SMALL"][right_index]
		right_transport_line.curve.add_point(right_midpoint, Vector2.ZERO, Vector2.ZERO, 1)
	
	if diff == 1 || diff == 5:
		var point
		if diff == 1:
			var right_index = input
			var right_midpoint = Global.HEX_POINTS_LEGEND["MIDDLE_CENTER"][right_index]
			right_transport_line.curve.add_point(right_midpoint, Vector2.ZERO, Vector2.ZERO, 1)
			
			var left_index_1 = (right_index + 4) % 6
			var left_index_2 = (right_index + 3) % 6
			point = Global.HEX_POINTS_LEGEND["SMALL"][left_index_1]
			left_transport_line.curve.add_point(point, Vector2.ZERO, Vector2.ZERO, 1)
			point = Global.HEX_POINTS_LEGEND["SMALL"][left_index_2]
			left_transport_line.curve.add_point(point, Vector2.ZERO, Vector2.ZERO, 2)
		else:
			var left_index = output
			var left_midpoint = Global.HEX_POINTS_LEGEND["MIDDLE_CENTER"][left_index]
			left_transport_line.curve.add_point(left_midpoint, Vector2.ZERO, Vector2.ZERO, 1)
			
			var right_index_1 = (left_index + 3) % 6
			var right_index_2 = (left_index + 4) % 6
			point = Global.HEX_POINTS_LEGEND["SMALL"][right_index_1]
			right_transport_line.curve.add_point(point, Vector2.ZERO, Vector2.ZERO, 1)
			point = Global.HEX_POINTS_LEGEND["SMALL"][right_index_2]
			right_transport_line.curve.add_point(point, Vector2.ZERO, Vector2.ZERO, 2)

func _tile_update(tilemap: Node2D) -> void:
	var next = tilemap.get_neighbor(tile_position, shape.output_index)
	
	if !next || !(next is TransportBelt):
		return
	
	if next.shape.input_index != (shape.output_index + 3) % 6: 
		return
		
	next_belt = next
	left_transport_line.next_line = next_belt.left_transport_line
	right_transport_line.next_line = next_belt.right_transport_line

func attempt_item_place(item_type: ItemType, point: Vector2) -> bool:
	var local_point: Vector2 = point - global_position
	
	var left_point = left_transport_line.get_curve().get_closest_point(local_point)
	var right_point = right_transport_line.get_curve().get_closest_point(local_point)
	
	var offset: float
	if local_point.distance_to(left_point) < local_point.distance_to(right_point):
		offset = left_transport_line.get_curve().get_closest_offset(local_point)
		left_transport_line.receive_item(Item.new_item(item_type), offset)
	else:
		offset = right_transport_line.get_curve().get_closest_offset(local_point)
		right_transport_line.receive_item(Item.new_item(item_type), offset)

	return true
