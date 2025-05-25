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


func set_entity(pos: Vector2i, entity: Entity) -> void:
	self.add_child(entity)
	entity.tile_position = pos

# This requires the entity to already have it's shape data, so it must be called after ._sync_shape()
func set_entity_tiles(entity: Entity) -> void:
	for relative_pos in entity.shape.occupied_tiles:
		var tile: Vector2i = entity.tile_position + relative_pos
		
		var prev_entity: Entity = entity_tile_map.get(tile)
		if prev_entity:
			remove_entity(tile)
		
		entity_tile_map[tile] = entity
	
	for belt_comp in entity.belt_components:
		var belt_pos: Vector2i = entity.tile_position + belt_comp.relative_position
		belt_tile_map[belt_pos] = belt_comp
		belt_comp.tile_position = belt_pos

func remove_entity(pos: Vector2i) -> bool:
	var entity: Entity = entity_tile_map.get(pos)
	if !entity: return false
	
	for relative_pos in entity.shape.occupied_tiles:
		var tile: Vector2i = entity.tile_position + relative_pos
		entity_tile_map.erase(tile)
	
	for belt_comp in entity.belt_components:
		belt_tile_map.erase(belt_comp.tile_position)
	
	entity.queue_free()
	return true
	
func get_entity(pos: Vector2i) -> Entity:
	return entity_tile_map.get(pos)
	
func get_belt_component(pos: Vector2i) -> BeltComponent:
	return belt_tile_map.get(pos)
	
func get_neighbor_pos(pos: Vector2i, n_index: int) -> Vector2i:
	return pos + HexUtil.NEIGHBORS[n_index]
	
func get_neighbor(pos: Vector2i, n_index: int) -> Entity:
	return entity_tile_map.get(get_neighbor_pos(pos, n_index))
	
func get_neighbor_belt(pos: Vector2i, n_index: int) -> BeltComponent:
	return belt_tile_map.get(get_neighbor_pos(pos, n_index))

# updates an entity's neighboring entities
func update_neighbors(pos: Vector2i) -> void:
	var entity: Entity = get_entity(pos)
	if !entity: return
	
	for n_pos in HexUtil.get_polyhex_neighbors(entity.shape.occupied_tiles):
		var neighbor: Entity = get_entity(pos + n_pos)
		if !neighbor: continue
		neighbor._tile_update(self)
