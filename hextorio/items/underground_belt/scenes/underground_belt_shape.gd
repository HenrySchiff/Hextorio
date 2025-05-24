class_name UndergroundBeltShape extends TransportBeltShape

@onready var roof = $Roof

var is_entrance: bool = true

func _ready() -> void:
	super()

func _rotate_whole(direction: int):
	super(direction)
	roof.rotate(direction * PI / 3.0)

# underground belts shouldn't turn: override to do nothing
func _rotate_end(_direction: int):
	set_entrance(!is_entrance)
	pass

func _copy(other: Shape):
	super(other)
	var other_belt: UndergroundBeltShape = other as UndergroundBeltShape
	roof.rotation = other_belt.roof.rotation
	set_entrance(other_belt.is_entrance)
	
func set_entrance(entrance: bool) -> void:
	is_entrance = entrance
	roof.position = Vector2.ZERO if entrance else Vector2.RIGHT.rotated(roof.rotation) * -16
