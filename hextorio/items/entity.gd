class_name Entity extends Node2D

@export var item_type: ItemType
var shape: Shape
var tile_position: Vector2i

static func new_entity(_item_type: ItemType) -> Entity:
	var entity = _item_type.entity_scene.instantiate()
	entity.item_type = _item_type
	return entity

func _sync_shape(shape: Shape, tile_pos: Vector2i) -> void:
	self.shape._copy(shape)
	self.position = shape.position
	self.tile_position = tile_pos

func _tile_update(tilemap: TileMapLayer) -> void:
	pass
