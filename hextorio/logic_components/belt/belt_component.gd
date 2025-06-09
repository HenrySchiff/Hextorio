class_name BeltComponent extends Node2D

static var transport_line_pair_scene: PackedScene = preload("res://logic_components/belt/TransportLinePair.tscn")

@export var num_pairs: int = 1

var tile_position: Vector2i
var relative_position: Vector2i

# the location of each pair in this array corresponds to the hex_dir / index
# it's occupying. For a regular transportbelt, the same transport line will
# be in two indices. Unoccupied sides are null
var pair_map: Array[TransportLinePair]

func _ready() -> void:
	pair_map.resize(6)
	
	for i in range(num_pairs):
		var new_pair: TransportLinePair = transport_line_pair_scene.instantiate()
		add_child(new_pair)

func set_pair(input: int = 0, output: int = 0) -> void:
	match num_pairs:
		1: set_normal_lines(input, output)
		2: set_splitter_lines(input, output)
		6: set_balancer_lines()
		_: pass

func set_normal_lines(input: int, output: int) -> void:
	var pair: TransportLinePair = get_child(0)
	pair.set_lines(input, output)
	
	pair_map.fill(null)
	pair_map[input] = pair
	pair_map[output] = pair
	pair.input_dir = input
	pair.output_dir = output

func set_splitter_lines(input: int, output: int) -> void:
	var input_pair: TransportLinePair = get_child(0)
	var output_pair: TransportLinePair = get_child(1)
	input_pair.set_lines(input, -1)
	output_pair.set_lines(-1, output)
	
	pair_map.fill(null)
	pair_map[input] = input_pair
	pair_map[output] = output_pair
	input_pair.input_dir = input
	input_pair.output_dir = -1
	output_pair.input_dir = -1
	output_pair.output_dir = output
	
func set_balancer_lines() -> void:
	for i in range(num_pairs):
		var pair: TransportLinePair = get_child(i)
		pair.set_lines(i, -1)
		pair_map[i] = pair

func set_belt_speed(speed: int) -> void:
	for pair in get_children():
		pair.set_belt_speed(speed)

func accepts_input(input_index: HexUtil.HexDirection) -> bool:
	return pair_map[input_index] && pair_map[input_index].input_dir != -1

func tile_update(tilemap: HexTileMap) -> void:
	for i in range(6):
		if !pair_map[i] || pair_map[i].output_dir != i: continue
		
		var output_index: int = i
		var next: BeltComponent = tilemap.get_neighbor_belt(tile_position, output_index)
		
		if !next: continue
		
		var opposite: int = HexUtil.get_opposite_dir(output_index)
		if !next.accepts_input(opposite): continue
		
		pair_map[i].set_next_lines(next.pair_map[opposite])

func attempt_item_place(_item_type: ItemType, point: Vector2) -> bool:
	var local_point: Vector2 = point - global_position
	
	var min_distance: float = 1000.0
	var closest_point: Vector2
	var closest_line: TransportLine
	
	for pair in get_children():
		for line in [pair.left_line, pair.right_line]:
			var p: Vector2 = line.get_curve().get_closest_point(local_point)
			var distance: float = local_point.distance_to(p)
			if distance < min_distance:
				min_distance = distance
				closest_point = p
				closest_line = line
	
	var offset: float = closest_line.get_curve().get_closest_offset(closest_point)
	closest_line.receive_item(Item.new_item(_item_type), offset)
	
	return true
