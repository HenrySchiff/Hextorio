class_name UndergroundBelt extends TransportBelt

@onready var transport_line_scene: PackedScene = preload("res://logic_components/TransportLine.tscn")

var underground_distance: int

func _ready() -> void:
	super()
	
	var belt_type: BeltType = item_type as BeltType
	underground_distance = belt_type.underground_distance

func _tile_update(tilemap: HexTileMap) -> void:
	if shape.is_entrance:
		return
		
	super(tilemap)
		
	var current_tile: Vector2i = self.tile_position
	for i in range(underground_distance + 1):
		current_tile = tilemap.get_neighbor_pos(current_tile, shape.input_index)
		var entity: Entity = tilemap.get_scene_tile(current_tile)
		if !(entity is UndergroundBelt):
			continue
		if (entity.shape.output_index + 3) % 6 == shape.input_index && entity.shape.is_entrance:
			print("found")
			connect_underground_belts(entity, self)
			return

# TODO: clean up this mess somehow
func connect_underground_belts(entrance_belt: UndergroundBelt, exit_belt: UndergroundBelt) -> void:
	#var local_left_input: Vector2 = entrance_belt.left_transport_line.curve.get_point_position(1)
	#var local_right_input: Vector2 = entrance_belt.right_transport_line.curve.get_point_position(1)
	#var left_input: Vector2 = local_left_input + entrance_belt.position - exit_belt.position
	#var right_input: Vector2 = local_right_input + entrance_belt.position - exit_belt.position
	#
	#exit_belt.left_transport_line.curve.set_point_position(0, left_input)
	#exit_belt.right_transport_line.curve.set_point_position(0, right_input)
	#
	#entrance_belt.left_transport_line.next_line = exit_belt.left_transport_line
	#entrance_belt.right_transport_line.next_line = exit_belt.right_transport_line
	
	var x = (entrance_belt.shape.output_index + 1) % 6
	var y = (entrance_belt.shape.output_index - 1) % 6
	var entrance_middle_left: Vector2 = Global.HEX_POINTS_LEGEND["SMALL"][x]
	var entrance_middle_right: Vector2 = Global.HEX_POINTS_LEGEND["SMALL"][y]
	
	entrance_belt.left_transport_line.curve.set_point_position(1, entrance_middle_left)
	entrance_belt.right_transport_line.curve.set_point_position(1, entrance_middle_right)
	
	var w = (exit_belt.shape.input_index - 1) % 6
	var z = (exit_belt.shape.input_index + 1) % 6
	var exit_middle_left: Vector2 = Global.HEX_POINTS_LEGEND["SMALL"][w]
	var exit_middle_right: Vector2 = Global.HEX_POINTS_LEGEND["SMALL"][z]
	
	exit_belt.left_transport_line.curve.set_point_position(0, exit_middle_left)
	exit_belt.right_transport_line.curve.set_point_position(0, exit_middle_right)
	
	var left_underground_line: TransportLine = transport_line_scene.instantiate()
	var right_underground_line: TransportLine = transport_line_scene.instantiate()
	left_underground_line.curve.set_point_position(0, entrance_middle_left - (exit_belt.position - entrance_belt.position))
	left_underground_line.curve.set_point_position(1, exit_middle_left)
	right_underground_line.curve.set_point_position(0, entrance_middle_right - (exit_belt.position - entrance_belt.position))
	right_underground_line.curve.set_point_position(1, exit_middle_right)
	
	entrance_belt.left_transport_line.next_line = left_underground_line
	entrance_belt.right_transport_line.next_line = right_underground_line
	left_underground_line.next_line = exit_belt.left_transport_line
	right_underground_line.next_line = exit_belt.right_transport_line
	
	left_underground_line.visible = false
	right_underground_line.visible = false
	left_underground_line.belt_speed = entrance_belt.belt_speed
	right_underground_line.belt_speed = entrance_belt.belt_speed
	
	add_child(left_underground_line)
	add_child(right_underground_line)
