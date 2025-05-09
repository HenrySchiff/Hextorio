class_name Item extends Node2D

static var item_scene: PackedScene = preload("res://items/Item.tscn")

@export var item_type: ItemType
var shape: Shape

static func new_item(_item_type: ItemType) -> Item:
	var item = item_scene.instantiate()
	item.item_type = _item_type
	return item

func _ready() -> void:
	shape = Shape.new_shape(item_type)
	shape.scale = shape.item_scale
	add_child(shape)
