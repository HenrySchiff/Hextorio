class_name Splitter extends Entity

var belt_speed: int

func _ready() -> void:
	super()
	
	var belt_type: BeltType = item_type.subtype as BeltType
	belt_speed = belt_type.belt_speed
	
	$LeftInput/LeftLine.next_line = $LeftOutput/LeftLine
	$LeftInput/RightLine.next_line = $LeftOutput/RightLine
	$RightInput/LeftLine.next_line = $RightOutput/LeftLine
	$RightInput/RightLine.next_line = $RightOutput/RightLine

func _sync_shape(_shape: Shape, _tile_pos: Vector2i) -> void:
	super(_shape, _tile_pos)
	var splitter_shape: SplitterShape = _shape as SplitterShape
	
	var left_input = splitter_shape.left_belt_shape.input_index
	var left_output = splitter_shape.left_belt_shape.output_index
	var right_input = splitter_shape.right_belt_shape.input_index
	var right_output = splitter_shape.right_belt_shape.output_index

	$RightInput.position = splitter_shape.right_belt_shape.position
	$RightOutput.position = splitter_shape.right_belt_shape.position
	
	TransportLine.set_lines($LeftInput/LeftLine, $LeftInput/RightLine, left_input, -1)
	TransportLine.set_lines($RightInput/LeftLine, $RightInput/RightLine, right_input, -1)
	TransportLine.set_lines($LeftOutput/LeftLine, $LeftOutput/RightLine, -1, left_output)
	TransportLine.set_lines($RightOutput/LeftLine, $RightOutput/RightLine, -1, right_output)
