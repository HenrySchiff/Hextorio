class_name TransportBelt extends Entity

@onready var left_transport_line: TransportLine = $LeftTransportLine
@onready var right_transport_line: TransportLine = $RightTransportLine

# given by resource on instantiaton
var belt_speed: int

func _ready() -> void:
	super()
	
	var belt_type: BeltType = item_type.subtype as BeltType
	belt_speed = belt_type.belt_speed
	
	left_transport_line.belt_speed = belt_speed
	right_transport_line.belt_speed = belt_speed

func _sync_shape(_shape: Shape, _tile_pos: Vector2i) -> void:
	super(_shape, _tile_pos)
	var belt_shape: TransportBeltShape = _shape as TransportBeltShape
	
	var input = belt_shape.input_index
	var output = belt_shape.output_index
	
	TransportLine.set_lines(left_transport_line, right_transport_line, input, output)

func _tile_update(tilemap: HexTileMap) -> void:
	var next = tilemap.get_neighbor(tile_position, shape.output_index)
	
	if !next || !(next is TransportBelt):
		return
	
	if next.shape.input_index != (shape.output_index + 3) % 6: 
		return
		
	#next_belt = next
	left_transport_line.next_line = next.left_transport_line
	right_transport_line.next_line = next.right_transport_line

func attempt_item_place(_item_type: ItemType, point: Vector2) -> bool:
	var local_point: Vector2 = point - global_position
	
	var left_point = left_transport_line.get_curve().get_closest_point(local_point)
	var right_point = right_transport_line.get_curve().get_closest_point(local_point)
	
	var offset: float
	if local_point.distance_to(left_point) < local_point.distance_to(right_point):
		offset = left_transport_line.get_curve().get_closest_offset(local_point)
		left_transport_line.receive_item(Item.new_item(_item_type), offset)
	else:
		offset = right_transport_line.get_curve().get_closest_offset(local_point)
		right_transport_line.receive_item(Item.new_item(_item_type), offset)

	return true
