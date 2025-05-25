class_name TransportBelt extends Entity

@onready var belt_comp: BeltComponent = $BeltComponent

# given by resource on instantiaton
var belt_type: BeltType

func _ready() -> void:
	super()
	belt_type = item_type.subtype as BeltType
	belt_comp.set_belt_speed(belt_type.belt_speed)
	belt_comp.relative_position = Vector2i.ZERO
	belt_components.append(belt_comp)

func _sync_shape(_shape: Shape, _tile_pos: Vector2i) -> void:
	super(_shape, _tile_pos)
	
	var belt_shape: TransportBeltShape = _shape as TransportBeltShape
	var input = belt_shape.input_index
	var output = belt_shape.output_index
	
	belt_comp.set_lines(input, output)

func _tile_update(tilemap: HexTileMap) -> void:
	belt_comp.tile_update(tilemap)
