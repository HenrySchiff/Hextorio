class_name Hotbar extends Control

@export var num_slots: int = 9
@export var selected_index: int = 0

@onready var hotbar_button_scene: PackedScene = preload("res://interface/HotbarButton.tscn")
@onready var buttons: HBoxContainer = $MarginContainer/HBoxContainer

func _ready():
	for i in range(num_slots):
		var button = hotbar_button_scene.instantiate()
		buttons.add_child(button)
	
	set_slot_selected(0)
	
func get_slot_item(index: int) -> PackedScene:
	return buttons.get_child(index).held_item

func set_slot_item(index: int, item_scene: PackedScene, shape_scene: PackedScene) -> void:
	buttons.get_child(index).set_item(item_scene, shape_scene)

func set_slot_selected(index: int) -> void:
	if index < 0 || index >= num_slots:
		return
		
	buttons.get_child(selected_index).set_selected(false)
	buttons.get_child(index).set_selected(true)
	selected_index = index
