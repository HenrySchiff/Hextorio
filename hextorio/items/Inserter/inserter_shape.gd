class_name InserterShape extends Shape

@onready var arm = $Arm

func _rotate_whole(direction: int):
	rotate(direction * PI / 3)

func _copy(other: Shape):
	super(other)
	var other_inserter: InserterShape = other as InserterShape
	self.rotation = other_inserter.rotation

func _process(_delta: float) -> void:
	pass
	#return
	#arm.rotate(delta * 2)
