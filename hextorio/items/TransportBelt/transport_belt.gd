class_name TransportBelt extends Item

@onready var left_transport_line: TransportLine = $LeftTransportLine
@onready var right_transport_line: TransportLine = $RightTransportLine

var next_belt: TransportBelt = null

var dot_scene = preload("res://Dot.tscn")

func _ready():
	shape = $TransportBeltShape
	
	return
	for point in Global.HEX_POINTS_LEGEND["SIDE_CENTER"]:
		var dot = dot_scene.instantiate()
		dot.position = point
		add_child(dot)
		
	for pair in Global.HEX_POINTS_LEGEND["SIDE_QUARTER_PAIRS"]:
		for point in pair:
			var dot = dot_scene.instantiate()
			dot.position = point
			dot.color = Color.SADDLE_BROWN
			add_child(dot)
		
	for point in Global.HEX_POINTS_LEGEND["MIDDLE_CENTER"]:
		var dot = dot_scene.instantiate()
		dot.position = point
		dot.color = Color.LAWN_GREEN
		add_child(dot)
		
	for point in Global.HEX_POINTS_LEGEND["SMALL"]:
		var dot = dot_scene.instantiate()
		dot.position = point
		dot.color = Color.WEB_MAROON
		add_child(dot)
		
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

func _tile_update(tilemap: TileMapLayer) -> void:
	var next: Item = tilemap.get_neighbor(tile_position, shape.output_index)
	if !next: return
	next_belt = next

func _process(delta: float) -> void:
	update_transport_line(left_transport_line, true, delta)
	update_transport_line(right_transport_line, false, delta)
		
func update_transport_line(line: TransportLine, left: bool, delta):
	if !line.has_item:
		return 
		
	line.item_demo.progress += 47 * delta
	if line.item_demo.progress_ratio >= 1:
		if !next_belt:
			return
		line.give_item()
		if left:
			next_belt.left_transport_line.receive_item(line.item_demo.progress_ratio - 1)
		else:
			next_belt.right_transport_line.receive_item(line.item_demo.progress_ratio - 1)
