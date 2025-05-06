class_name Item extends Node2D

var shape: Shape
var tile_position: Vector2i


func _sync_shape(shape: Shape, tile_pos: Vector2i) -> void:
	self.shape._copy(shape)
	self.position = shape.position
	self.tile_position = tile_pos

func _tile_update(tilemap: TileMapLayer) -> void:
	pass
