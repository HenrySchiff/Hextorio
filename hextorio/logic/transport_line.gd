class_name TransportLine extends Path2D

var has_item = false
@onready var item_demo = $ItemDemo

# Called when the node enters the scene tree for the first time.
func _ready():
	item_demo.visible = false
	
func give_item():
	has_item = false
	item_demo.visible = false
	item_demo.progress_ratio = 0
	
func receive_item(progress = 0):
	has_item = true
	item_demo.visible = true
	item_demo.progress_ratio = progress
	
#func receive_item(item: Item, progress: float):
	#pass
