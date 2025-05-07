class_name ItemType extends Resource

@export var name: String
@export var entity_scene: PackedScene
@export var shape_scene: PackedScene
@export var recipe: Recipe

func _init(_name = "", _entity_scene = null, _shape_scene = null, _recipe = null): 
	name = _name 
	entity_scene = _entity_scene 
	shape_scene = _shape_scene 
	recipe = _recipe
