class_name Splitter extends Entity

@onready var left_belt_comp: BeltComponent = $LeftBeltComponent
@onready var right_belt_comp: BeltComponent = $RightBeltComponent

func _ready() -> void:
	super()
	
	var belt_type: BeltType = item_type.subtype as BeltType
	left_belt_comp.set_belt_speed(belt_type.belt_speed)
	right_belt_comp.set_belt_speed(belt_type.belt_speed)
	left_belt_comp.relative_position = Vector2i.ZERO
	belt_components.append_array([left_belt_comp, right_belt_comp])

func _sync_shape(_shape: Shape, _tile_pos: Vector2i) -> void:
	super(_shape, _tile_pos)
	var splitter_shape: SplitterShape = _shape as SplitterShape
	
	right_belt_comp.position = splitter_shape.right_belt_shape.position
	right_belt_comp.relative_position = splitter_shape.occupied_tiles[1]
	
	var left_input = splitter_shape.left_belt_shape.input_index
	var left_output = splitter_shape.left_belt_shape.output_index
	var right_input = splitter_shape.right_belt_shape.input_index
	var right_output = splitter_shape.right_belt_shape.output_index
	
	left_belt_comp.set_lines_two_pair(left_input, left_output)
	right_belt_comp.set_lines_two_pair(right_input, right_output)
	
	left_belt_comp.set_internal_next_belt(right_belt_comp)
	right_belt_comp.set_internal_next_belt(left_belt_comp)


func _tile_update(tilemap: HexTileMap) -> void:
	left_belt_comp.tile_update(tilemap)
	right_belt_comp.tile_update(tilemap)
