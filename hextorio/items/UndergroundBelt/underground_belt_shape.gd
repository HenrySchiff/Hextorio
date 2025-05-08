class_name UndergroundBeltShape extends TransportBeltShape

@onready var roof = $Roof

func _rotate_whole(direction: int):
	super(direction)
	roof.rotate(direction * PI / 3.0)

# underground belts shouldn't turn: override to do nothing
func _rotate_end(direction: int):
	pass

func _copy(other: Shape):
	super(other)
	roof.rotation = other.roof.rotation
