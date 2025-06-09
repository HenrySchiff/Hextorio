class_name Balancer extends Entity

@onready var belt_comp: BeltComponent = $BeltComponent

func _sync_shape(_shape: Shape, _tile_pos: Vector2i) -> void:
	super(_shape, _tile_pos)
	belt_comp.set_pair()
