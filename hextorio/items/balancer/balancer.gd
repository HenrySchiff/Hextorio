class_name Balancer extends Entity

@onready var belt_comp: BeltComponent = $BeltComponent

func _apply_shape(_shape: Shape) -> void:
	super(_shape)
	belt_comp.set_pair()
