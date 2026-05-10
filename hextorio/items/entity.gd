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

func sync_shape(_shape: Shape) -> void:
	self.shape._copy(_shape)
	self.position = _shape.position
	self._apply_shape(_shape)

# applies the configuration of a shape to an entity; for example, in TransportBelt,
# this method will set the belt's lines based on the given shape's orientation
func _apply_shape(_shape: Shape) -> void:
	pass

func _tile_update(_tilemap: HexTileMap) -> void:
	pass

func _inspect() -> void:
	print("\n###### INSPECT ######")
	pass
