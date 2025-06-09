class_name TransportLinePair extends Node2D

@onready var left_line: TransportLine = $LeftTransportLine
@onready var right_line: TransportLine = $RightTransportLine

# -1 indicates that this pair is not an input/output of the belt component it's in
var output_dir: HexUtil.HexDirection = -1
var input_dir: HexUtil.HexDirection = -1


func set_belt_speed(speed: int) -> void:
	left_line.belt_speed = speed
	right_line.belt_speed = speed

func set_next_lines(next: TransportLinePair) -> void:
	left_line.next_line = next.left_line
	right_line.next_line = next.right_line

func set_next_split_lines(next: TransportLinePair, split: TransportLinePair) -> void:
	left_line.next_line = next.left_line
	left_line.next_split_line = split.left_line
	right_line.next_line = next.right_line
	right_line.next_split_line = split.right_line


# TODO: All of this still needs to be cleaned up

# an input or output of -1 sets that end of each line to center
func set_lines(input: int, output: int) -> void:
	left_line.curve.clear_points()
	right_line.curve.clear_points()
	
	if input == -1:
		left_line.curve.add_point(HexUtil.CENTER_VERTICES[(output + 4) % 6])
		right_line.curve.add_point(HexUtil.CENTER_VERTICES[(output + 1) % 6])
	else:
		left_line.curve.add_point(HexUtil.EDGE_QUARTER_RIGHT[input])
		right_line.curve.add_point(HexUtil.EDGE_QUARTER_LEFT[input])
	
	if output == -1:
		left_line.curve.add_point(HexUtil.CENTER_VERTICES[(input + 1) % 6])
		right_line.curve.add_point(HexUtil.CENTER_VERTICES[(input + 4) % 6])
	else:
		left_line.curve.add_point(HexUtil.EDGE_QUARTER_LEFT[output])
		right_line.curve.add_point(HexUtil.EDGE_QUARTER_RIGHT[output])
		
	if input == -1 || output == -1:
		return
	
	var diff = (output - input + 6) % 6
	
	if diff == 2 || diff == 4:
		set_lines_sixty(input, output)
	
	if diff == 1 || diff == 5:
		set_lines_thirty(input, output)

# sets each transport line's curve to a 60 degree turn
func set_lines_sixty(input: int, output: int) -> void:
	var left_index
	var right_index
	var diff = (output - input + 6) % 6
	if diff == 2:
		left_index = (input + 1) % 6
		right_index = (left_index + 3) % 6
	else:
		right_index = (input - 1) % 6
		left_index = (right_index + 3) % 6
		
	var left_midpoint = HexUtil.OUTER_TURN[left_index]
	var right_midpoint = HexUtil.OUTER_TURN[right_index]
	left_line.curve.add_point(left_midpoint, Vector2.ZERO, Vector2.ZERO, 1)
	right_line.curve.add_point(right_midpoint, Vector2.ZERO, Vector2.ZERO, 1)

# sets each transport line's curve to a 30 degree turn
func set_lines_thirty(input: int, output: int) -> void:
	var point
	var diff = (output - input + 6) % 6
	if diff == 1:
		var left_index = input
		var left_midpoint = HexUtil.INNER_TURN[left_index]
		left_line.curve.add_point(left_midpoint, Vector2.ZERO, Vector2.ZERO, 1)
		
		var right_index_1 = (left_index + 4) % 6
		var right_index_2 = (left_index + 3) % 6
		point = HexUtil.OUTER_TURN[right_index_1]
		right_line.curve.add_point(point, Vector2.ZERO, Vector2.ZERO, 1)
		point = HexUtil.OUTER_TURN[right_index_2]
		right_line.curve.add_point(point, Vector2.ZERO, Vector2.ZERO, 2)
	else:
		var right_index = output
		var right_midpoint = HexUtil.INNER_TURN[right_index]
		right_line.curve.add_point(right_midpoint, Vector2.ZERO, Vector2.ZERO, 1)
		
		var left_index_1 = (right_index + 3) % 6
		var left_index_2 = (right_index + 4) % 6
		point = HexUtil.OUTER_TURN[left_index_1]
		left_line.curve.add_point(point, Vector2.ZERO, Vector2.ZERO, 1)
		point = HexUtil.OUTER_TURN[left_index_2]
		left_line.curve.add_point(point, Vector2.ZERO, Vector2.ZERO, 2)
