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

func _apply_shape(_shape: Shape) -> void:
	var belt_shape: TransportBeltShape = _shape as TransportBeltShape
	var input = belt_shape.input_index
	var output = belt_shape.output_index
	
	belt_comp.reset_pairs()
	belt_comp.set_pair(input, output)

func _tile_update(tilemap: HexTileMap) -> void:
	print("update")
	belt_comp.tile_update(tilemap)

func _inspect() -> void:
	super()
	print("TRANSPORT_BELT")
	prints("pair_map:", belt_comp.pair_map)
	#for pair in belt_comp.pair_map:
	for i in range(6):
		var pair: TransportLinePair = belt_comp.pair_map[i]
		if !pair || pair.output_dir != i: continue
		prints("direction:", HexUtil.HexDirection.keys()[i])
		prints("left_next:", pair.left_line.next_line)
		prints("right_next:", pair.right_line.next_line)
