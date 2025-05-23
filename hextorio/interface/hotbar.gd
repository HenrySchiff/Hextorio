class_name Hotbar extends Control

@export var num_slots: int = 9
@export var selected_index: int = 0

@onready var hotbar_button_scene: PackedScene = preload("res://interface/HotbarButton.tscn")
@onready var buttons: HBoxContainer = $MarginContainer/HBoxContainer

var set_slot_selected_function: Callable

func _ready():
	for i in range(num_slots):
		var button = hotbar_button_scene.instantiate()
		buttons.add_child(button)
	
	set_slot_selected(0)
	
func get_slot_item(index: int) -> ItemType:
	return buttons.get_child(index).held_item

func set_slot_item(index: int, item_type: ItemType) -> void:
	buttons.get_child(index).set_item(item_type)

func set_slot_selected(index: int) -> void:
	if index < 0 || index >= num_slots:
		return
		
	buttons.get_child(selected_index).set_selected(false)
	buttons.get_child(index).set_selected(true)
	selected_index = index
	
	if !set_slot_selected_function:
		return
	
	var selected_item: ItemType = get_slot_item(selected_index)
	set_slot_selected_function.call(selected_item)
