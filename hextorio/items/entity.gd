class_name Entity extends Node2D

var item_type: ItemType
var shape: Shape
var tile_position: Vector2i # global tile position
var belt_components: Array[BeltComponent]

static func new_entity(_item_type: ItemType) -> Entity:
	var entity = _item_type.entity_scene.instantiate()
	entity.item_type = _item_type
	return entity

func _ready() -> void:
	shape = Shape.new_shape(item_type)
	add_child(shape)

func _sync_shape(_shape: Shape, _tile_pos: Vector2i) -> void:
	self.shape._copy(_shape)
	self.position = _shape.position
	self.tile_position = _tile_pos

func _tile_update(_tilemap: HexTileMap) -> void:
	pass

func _inspect() -> void:
	pass
