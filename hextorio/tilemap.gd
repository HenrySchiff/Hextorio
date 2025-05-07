extends TileMapLayer

# you can't retrieve scene tiles from the regular godot tilemap
var scene_tile_map: Dictionary = {}

func set_scene_tile(pos: Vector2i, item) -> void:
	self.add_child(item)
	item.tile_position = pos
	
	for relative_pos in item.shape.occupied_tiles:
		var tile: Vector2i = pos + relative_pos
		
		var prev_item = scene_tile_map.get(tile)
		if prev_item:
			remove_scene_tile(tile)
			
		#set_cell(tile, 0, Vector2i.ZERO)
		scene_tile_map[tile] = item

func remove_scene_tile(pos: Vector2i) -> bool:
	var item = scene_tile_map.get(pos)
	if !item: return false
	
	for relative_pos in item.shape.occupied_tiles:
		var tile: Vector2i = item.tile_position + relative_pos
		
		scene_tile_map.erase(tile)
		#set_cell(tile, 1, Vector2i.ZERO)
	
	item.queue_free()
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
