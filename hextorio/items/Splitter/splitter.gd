class_name Splitter extends Entity

var belt_speed: int

func _ready() -> void:
	super()
	
	var belt_type: BeltType = item_type.subtype as BeltType
	belt_speed = belt_type.belt_speed
	
	#left_transport_line.belt_speed = belt_speed
	#right_transport_line.belt_speed = belt_speed

func _sync_shape(_shape: Shape, _tile_pos: Vector2i) -> void:
	super(_shape, _tile_pos)
	var belt_shape: SplitterShape = _shape as SplitterShape
	
	#var input = belt_shape.input_index
	#var output = belt_shape.output_index
	var input = 4
	var output = 1
	
	TransportLine.set_lines($LeftInput/LeftLine, $LeftInput/RightLine, input, output)
	TransportLine.set_lines($RightInput/LeftLine, $RightInput/RightLine, input, output)
	TransportLine.set_lines($LeftOutput/LeftLine, $LeftOutput/RightLine, input, output)
	TransportLine.set_lines($RightOutput/LeftLine, $RightOutput/RightLine, input, output)

	$LeftInput/LeftLine.position.x += HexUtil.HEX_WIDTH
	$LeftInput/RightLine.position.x += HexUtil.HEX_WIDTH
