extends Node2D

var dot_scene = preload("res://Dot.tscn")

# maps tile positions -> hexagon centers
var hex_tile_map: Dictionary[Vector2i, Vector2]

func _ready():
	hex_tile_map = Global.generate_hex_grid(30, 20)
		
func _draw():
	var points = Global.get_hex_points(Global.HEX_SIZE, 1.0/6.0 * PI)
	for tile in hex_tile_map:
		var center = hex_tile_map[tile]
		for i in range(6):
			var point = center + points[i]
			var next_point = center + points[(i + 1) % 6]
			draw_line(point, next_point, Color.DIM_GRAY, 2)

# you can't retrieve scene tiles from the regular godot tilemap
var scene_tile_map: Dictionary = {}

func set_scene_tile(pos: Vector2i, entity: Entity) -> void:
	self.add_child(entity)
	entity.tile_position = pos
	
	for relative_pos in entity.shape.occupied_tiles:
		var tile: Vector2i = pos + relative_pos
		
		var prev_entity = scene_tile_map.get(tile)
		if prev_entity:
			remove_scene_tile(tile)
			
		scene_tile_map[tile] = entity

func remove_scene_tile(pos: Vector2i) -> bool:
	var entity: Entity = scene_tile_map.get(pos)
	if !entity: return false
	
	for relative_pos in entity.shape.occupied_tiles:
		var tile: Vector2i = entity.tile_position + relative_pos
		scene_tile_map.erase(tile)
	
	entity.queue_free()
	return true
	
func get_scene_tile(pos: Vector2i) :
	return scene_tile_map.get(pos)
	
func get_neighbor(pos: Vector2i, n_index: int) :
	return scene_tile_map.get(pos + Global.NEIGHBORS[n_index])
	
func update_neighbors(pos: Vector2i):
	for i in range(Global.NEIGHBORS.size()):
		var item = get_neighbor(pos, i)
		if !item: continue
		item._tile_update(self)
