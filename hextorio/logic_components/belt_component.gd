class_name BeltComponent extends Node2D

var left_line: TransportLine
var right_line: TransportLine

# an input or output of -1 sets that end of each line to the hexagon's center
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
func set_lines_sixty(input: int, output: int):
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
func set_lines_thirty(input: int, output: int):
	var point
	var diff = (output - input + 6) % 6
	if diff == 1:
		var left_index = input
		var left_midpoint = HexUtil.INNER_TURN[left_index]
		left_line.curve.add_point(left_midpoint, Vector2.ZERO, Vector2.ZERO, 1)
		
		var right_index_1 = (left_index + 4) % 6
		var right_index_2 = (left_index + 3) % 6
		point = HexUtil.OUTER_TURN[right_index_1]
		point = HexUtil.OUTER_TURN[right_index_2]
		right_line.curve.add_point(point, Vector2.ZERO, Vector2.ZERO, 1)
		right_line.curve.add_point(point, Vector2.ZERO, Vector2.ZERO, 2)
	else:
		var right_index = output
		var right_midpoint = HexUtil.INNER_TURN[right_index]
		right_line.curve.add_point(right_midpoint, Vector2.ZERO, Vector2.ZERO, 1)
		
		var left_index_1 = (right_index + 3) % 6
		var left_index_2 = (right_index + 4) % 6
		point = HexUtil.OUTER_TURN[left_index_1]
		point = HexUtil.OUTER_TURN[left_index_2]
		left_line.curve.add_point(point, Vector2.ZERO, Vector2.ZERO, 1)
		left_line.curve.add_point(point, Vector2.ZERO, Vector2.ZERO, 2)
