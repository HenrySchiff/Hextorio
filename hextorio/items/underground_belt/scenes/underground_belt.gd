class_name UndergroundBelt extends TransportBelt

static var belt_component_scene: PackedScene = preload("res://logic_components/belt/BeltComponent.tscn")

var related_underground: UndergroundBelt
var underground_belt_comp: BeltComponent

func _ready() -> void:
	super()
	
func _exit_tree() -> void:
	disconnect_underground_belts(self, related_underground)
	if related_underground:
		related_underground.related_underground = null
		related_underground = null
	
func _sync_shape(_shape: Shape, _tile_pos: Vector2i) -> void:
	super(_shape, _tile_pos)
	
	var belt_shape: UndergroundBeltShape = _shape as UndergroundBeltShape
	var input = belt_shape.input_index if belt_shape.is_entrance else -1
	var output = belt_shape.output_index if !belt_shape.is_entrance else -1
		
	belt_comp.set_lines(input, output)

func _tile_update(tilemap: HexTileMap) -> void:		
	super(tilemap)
	
	if shape.is_entrance || related_underground:
		return
		
	var current_tile: Vector2i = self.tile_position
	for i in range(belt_type.underground_distance + 1):
		current_tile = tilemap.get_neighbor_pos(current_tile, shape.input_index)
		var entity: Entity = tilemap.get_entity(current_tile)
		if !(entity is UndergroundBelt):
			continue
		if (entity.shape.output_index + 3) % 6 == shape.input_index && entity.shape.is_entrance:
			connect_underground_belts(entity, self)
			return

func connect_underground_belts(entrance_belt: UndergroundBelt, exit_belt: UndergroundBelt) -> void:
	entrance_belt.related_underground = exit_belt
	exit_belt.related_underground = entrance_belt
	
	underground_belt_comp = belt_component_scene.instantiate()
	add_child(underground_belt_comp)
	underground_belt_comp.set_belt_speed(belt_type.belt_speed)
	underground_belt_comp.visible = false
	
	var left_input: Vector2 = HexUtil.CENTER_VERTICES[(entrance_belt.shape.output_index - 2) % 6]
	var left_output: Vector2 = HexUtil.CENTER_VERTICES[(entrance_belt.shape.input_index + 1) % 6]
	var right_input: Vector2 = HexUtil.CENTER_VERTICES[(entrance_belt.shape.output_index + 1) % 6]
	var right_output: Vector2 = HexUtil.CENTER_VERTICES[(entrance_belt.shape.input_index - 2) % 6]
	
	# localize positions
	left_input -= exit_belt.position - entrance_belt.position
	right_input -= exit_belt.position - entrance_belt.position
	
	underground_belt_comp.left_line.curve.set_point_position(0, left_input)
	underground_belt_comp.left_line.curve.set_point_position(1, left_output)
	underground_belt_comp.right_line.curve.set_point_position(0, right_input)
	underground_belt_comp.right_line.curve.set_point_position(1, right_output)
	
	entrance_belt.belt_comp.set_next_belt(underground_belt_comp)
	underground_belt_comp.set_next_belt(exit_belt.belt_comp)

func disconnect_underground_belts(belt1: UndergroundBelt, belt2: UndergroundBelt) -> void:
	if !belt1 || !belt2:
		return
	
	var entrance_belt: UndergroundBelt = belt1 if belt1.shape.is_entrance else belt2
	var exit_belt: UndergroundBelt = belt1 if !belt1.shape.is_entrance else belt2
	
	entrance_belt.related_underground = null
	exit_belt.related_underground = null
	exit_belt.underground_belt_comp.queue_free()
