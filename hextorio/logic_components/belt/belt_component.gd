class_name BeltComponent extends Node2D

# TODO: This class should probably be abstracted into a base class with a subclass
# for each pair type instead of using an enum 

enum PairType { ONE_PAIR, TWO_PAIR }

static var transport_line_scene: PackedScene = preload("res://logic_components/belt/TransportLine.tscn")

@export var pair_type: PairType = PairType.ONE_PAIR

var tile_position: Vector2i
var relative_position: Vector2i
var input_index: int
var output_index: int

# ONE PAIR
var left_line: TransportLine
var right_line: TransportLine

# TWO PAIR
var left_input_line: TransportLine
var left_output_line: TransportLine
var right_input_line: TransportLine
var right_output_line: TransportLine

var all_lines: Array[TransportLine]

# Tuples
var input_lines: Array[TransportLine]
var output_lines: Array[TransportLine]


func _ready() -> void:
	match pair_type:
		PairType.ONE_PAIR:
			left_line = transport_line_scene.instantiate()
			right_line = transport_line_scene.instantiate()
			all_lines = [left_line, right_line]
			input_lines = all_lines
			output_lines = all_lines
		
		PairType.TWO_PAIR:
			left_input_line = transport_line_scene.instantiate()
			left_output_line = transport_line_scene.instantiate()
			right_input_line = transport_line_scene.instantiate()
			right_output_line = transport_line_scene.instantiate()
			all_lines = [left_input_line, left_output_line, right_input_line, right_output_line]
			input_lines = [left_input_line, right_input_line]
			output_lines = [left_output_line, right_output_line]
	
	for line in all_lines:
		add_child(line)

func set_belt_speed(speed: int) -> void:
	for line in all_lines:
		line.belt_speed = speed
	
func set_next_belt(next: BeltComponent) -> void:
	output_lines[0].next_line = next.input_lines[0]
	output_lines[1].next_line = next.input_lines[1]

# to be used with TWO_PAIR i.e. splitters
func set_internal_next_belt(next: BeltComponent) -> void:
	left_input_line.next_line = left_output_line
	left_input_line.next_split_line = next.left_output_line
	right_input_line.next_line = right_output_line
	right_input_line.next_split_line = next.right_output_line

func tile_update(tilemap: HexTileMap) -> void:
	var next: BeltComponent = tilemap.get_neighbor_belt(tile_position, output_index)
	
	if !next: return
	
	if next.input_index != (output_index + 3) % 6: 
		return
	
	set_next_belt(next)

func attempt_item_place(_item_type: ItemType, point: Vector2) -> bool:
	var local_point: Vector2 = point - global_position
	
	var min_distance: float = 1000.0
	var closest_point: Vector2
	var closest_line: TransportLine
	
	for line in all_lines:
		var p: Vector2 = line.get_curve().get_closest_point(local_point)
		var distance: float = local_point.distance_to(p)
		if distance < min_distance:
			min_distance = distance
			closest_point = p
			closest_line = line
	
	var offset: float = closest_line.get_curve().get_closest_offset(closest_point)
	closest_line.receive_item(Item.new_item(_item_type), offset)
	
	#var left_point = left_line.get_curve().get_closest_point(local_point)
	#var right_point = right_line.get_curve().get_closest_point(local_point)
	#
	#var offset: float
	#if local_point.distance_to(left_point) < local_point.distance_to(right_point):
		#offset = left_line.get_curve().get_closest_offset(local_point)
		#left_line.receive_item(Item.new_item(_item_type), offset)
	#else:
		#offset = right_line.get_curve().get_closest_offset(local_point)
		#right_line.receive_item(Item.new_item(_item_type), offset)
	
	return true


# TODO: Simplify these functions

# an input or output of -1 sets that end of each line to center
func set_lines(input: int, output: int) -> void:
	input_index = input
	output_index = output
	
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

# for two pairs of lines; sets the input and output pairs to meet in the center
func set_lines_two_pair(input: int, output: int) -> void:
	input_index = input
	output_index = output
	
	left_input_line.curve.clear_points()
	left_output_line.curve.clear_points()
	right_input_line.curve.clear_points()
	right_output_line.curve.clear_points()
	
	left_input_line.curve.add_point(HexUtil.EDGE_QUARTER_RIGHT[input])
	left_input_line.curve.add_point(HexUtil.CENTER_VERTICES[(output + 4) % 6])
	left_output_line.curve.add_point(HexUtil.CENTER_VERTICES[(input + 1) % 6])
	left_output_line.curve.add_point(HexUtil.EDGE_QUARTER_LEFT[output])
	
	right_input_line.curve.add_point(HexUtil.EDGE_QUARTER_LEFT[input])
	right_input_line.curve.add_point(HexUtil.CENTER_VERTICES[(output + 1) % 6])
	right_output_line.curve.add_point(HexUtil.CENTER_VERTICES[(input + 4) % 6])
	right_output_line.curve.add_point(HexUtil.EDGE_QUARTER_RIGHT[output])
