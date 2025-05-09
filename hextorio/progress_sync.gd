extends Node

var progress := 0.0
var speed := 50

func _process(delta):
	progress += speed * delta
	progress = fmod(progress, 96.0)
