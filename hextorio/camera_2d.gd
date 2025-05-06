extends Camera2D

#func _input(event):

func _process(delta):
	position += Input.get_vector("move_left", "move_right", "move_up", "move_down") * 500 * delta
	
	if Input.is_action_just_pressed("camera_zoom_in"):
		self.zoom *= 1.25

	if Input.is_action_just_pressed("camera_zoom_out"):
		self.zoom /= 1.25
