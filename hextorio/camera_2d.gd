extends Camera2D

const zoom_factor: float = 1.25
const min_zoom: Vector2 = Vector2(zoom_factor ** -2, zoom_factor ** -2)
const max_zoom: Vector2 = Vector2(zoom_factor ** 8, zoom_factor ** 8)

func _process(delta):
	position += Input.get_vector("move_left", "move_right", "move_up", "move_down") * 500 * delta
	
	if Input.is_action_just_pressed("camera_zoom_in"):
		self.zoom *= zoom_factor

	if Input.is_action_just_pressed("camera_zoom_out"):
		self.zoom /= zoom_factor

	self.zoom = clamp(self.zoom, min_zoom, max_zoom)
