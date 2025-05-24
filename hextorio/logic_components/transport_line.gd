class_name TransportLine extends Path2D

const ITEM_GAP: int = 16
var belt_speed: int

var next_line: TransportLine
var next_split_line: TransportLine

func _process(delta: float) -> void:
	for path_follower in get_children():
		path_follower.progress += belt_speed * delta
		
		var ahead: PathFollow2D
		var ahead_progress: float
		
		# If it's the last item on this belt
		if path_follower.get_index() == get_child_count() - 1:
			# And there's an item on the next belt
			if next_line && next_line.get_child_count() > 0:
				ahead = next_line.get_child(0)
				ahead_progress = ahead.progress + get_curve().get_baked_length()
		
		# If it's not the last item on the belt
		else:
			ahead = get_child(path_follower.get_index() + 1)
			ahead_progress = ahead.progress
		
		if ahead && ahead_progress - path_follower.progress < ITEM_GAP:
			path_follower.progress = ahead_progress - ITEM_GAP
		
		if path_follower.progress_ratio >= 1:
			if !next_line:
				path_follower.progress_ratio = 1
				continue
			
			var item: Item = path_follower.get_child(0)
			path_follower.remove_child(item)
			next_line.receive_item(item, path_follower.progress - get_curve().get_baked_length())
			path_follower.queue_free()
			
			# if this transport line belongs to a splitter, swap the next line
			if next_split_line:
				var temp: TransportLine = next_line
				next_line = next_split_line
				next_split_line = temp

func receive_item(item: Item, progress: float) -> bool:
	#for path_follower in get_children():
		#if path_follower.progress > progress
	
	var new_path_follower = PathFollow2D.new()
	new_path_follower.progress = progress
	new_path_follower.loop = false
	new_path_follower.rotates = false
	new_path_follower.add_child(item)
	add_child(new_path_follower)
	move_child(new_path_follower, 0)
	return true

# an input or output of -1 sets that end of each line to the hexagon's center
static func set_lines(left: TransportLine, right: TransportLine, input: int, output: int) -> void:
	left.curve.clear_points()
	right.curve.clear_points()
	
	if input == -1:
		left.curve.add_point(HexUtil.CENTER_VERTICES[(output + 4) % 6])
		right.curve.add_point(HexUtil.CENTER_VERTICES[(output + 1) % 6])
	else:
		left.curve.add_point(HexUtil.EDGE_QUARTER_RIGHT[input])
		right.curve.add_point(HexUtil.EDGE_QUARTER_LEFT[input])
	
	if output == -1:
		left.curve.add_point(HexUtil.CENTER_VERTICES[(input + 1) % 6])
		right.curve.add_point(HexUtil.CENTER_VERTICES[(input + 4) % 6])
	else:
		left.curve.add_point(HexUtil.EDGE_QUARTER_LEFT[output])
		right.curve.add_point(HexUtil.EDGE_QUARTER_RIGHT[output])
		
	if input == -1 || output == -1:
		return
	
	var diff = (output - input + 6) % 6
	
	if diff == 2 || diff == 4:
		set_lines_sixty(left, right, input, output)
	
	if diff == 1 || diff == 5:
		set_lines_thirty(left, right, input, output)

# sets each transport line's curve to a 60 degree turn
static func set_lines_sixty(left: TransportLine, right: TransportLine, input: int, output: int):
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
	left.curve.add_point(left_midpoint, Vector2.ZERO, Vector2.ZERO, 1)
	right.curve.add_point(right_midpoint, Vector2.ZERO, Vector2.ZERO, 1)

# sets each transport line's curve to a 30 degree turn
static func set_lines_thirty(left: TransportLine, right: TransportLine, input: int, output: int):
	var point
	var diff = (output - input + 6) % 6
	if diff == 1:
		var left_index = input
		var left_midpoint = HexUtil.INNER_TURN[left_index]
		left.curve.add_point(left_midpoint, Vector2.ZERO, Vector2.ZERO, 1)
		
		var right_index_1 = (left_index + 4) % 6
		var right_index_2 = (left_index + 3) % 6
		point = HexUtil.OUTER_TURN[right_index_1]
		point = HexUtil.OUTER_TURN[right_index_2]
		right.curve.add_point(point, Vector2.ZERO, Vector2.ZERO, 1)
		right.curve.add_point(point, Vector2.ZERO, Vector2.ZERO, 2)
	else:
		var right_index = output
		var right_midpoint = HexUtil.INNER_TURN[right_index]
		right.curve.add_point(right_midpoint, Vector2.ZERO, Vector2.ZERO, 1)
		
		var left_index_1 = (right_index + 3) % 6
		var left_index_2 = (right_index + 4) % 6
		point = HexUtil.OUTER_TURN[left_index_1]
		point = HexUtil.OUTER_TURN[left_index_2]
		left.curve.add_point(point, Vector2.ZERO, Vector2.ZERO, 1)
		left.curve.add_point(point, Vector2.ZERO, Vector2.ZERO, 2)
