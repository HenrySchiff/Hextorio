class_name HexTileMap extends Node2D

var dot_scene = preload("res://Dot.tscn")

# maps tile positions -> hexagon centers
var hex_tile_map: Dictionary[Vector2i, Vector2]

# maps tile positions -> entities
var entity_tile_map: Dictionary[Vector2i, Entity]

# maps tile positions -> belt components
var belt_tile_map: Dictionary[Vector2i, BeltComponent]


func _ready():
	hex_tile_map = HexUtil.generate_hex_grid(30, 20)
		
func _draw():
	var points = HexUtil.VERTICES
	for tile in hex_tile_map:
		var center = hex_tile_map[tile]
		for i in range(6):
			var point = center + points[i]
			var next_point = center + points[(i + 1) % 6]
			draw_line(point, next_point, Color.DIM_GRAY, 2)
		
		#for v in HexUtil.CENTER_VERTICES:
			#var dot = dot_scene.instantiate()
			#dot.position = center + v
			#add_child(dot)

func set_entity(pos: Vector2i, entity: Entity, occupied_tiles: Array[Vector2i]) -> void:
	self.add_child(entity)
	entity.tile_position = pos
	
	for relative_pos in occupied_tiles:
		var tile: Vector2i = pos + relative_pos
		
		var prev_entity: Entity = entity_tile_map.get(tile)
		if prev_entity:
			remove_entity(tile)
			
		entity_tile_map[tile] = entity

func remove_entity(pos: Vector2i) -> bool:
	var entity: Entity = entity_tile_map.get(pos)
	if !entity: return false
	
	for relative_pos in entity.shape.occupied_tiles:
		var tile: Vector2i = entity.tile_position + relative_pos
		entity_tile_map.erase(tile)
	
	entity.queue_free()
	return true
	
func get_entity(pos: Vector2i) -> Entity:
	return entity_tile_map.get(pos)
	
func get_neighbor_pos(pos: Vector2i, n_index: int) -> Vector2i:
	return pos + HexUtil.NEIGHBORS[n_index]
	
func get_neighbor(pos: Vector2i, n_index: int) -> Entity:
	return entity_tile_map.get(get_neighbor_pos(pos, n_index))
	
func update_neighbors(pos: Vector2i) -> void:
	for i in range(HexUtil.NEIGHBORS.size()):
		var entity: Entity = get_neighbor(pos, i)
		if !entity: continue
		entity._tile_update(self)
