class_name EntityPlacer extends Node2D

@onready var build_audio = $BuildAudioPlayer
@onready var deconstruct_audio = $DeconstructAudioPlayer

@onready var hotbar: Hotbar = get_node("../../CanvasLayer/Hotbar")
@onready var tilemap: HexTileMap = get_node("../HexTileMap")

var selected_item_type: ItemType
var selected_item_shape: Shape

var mouse_pos: Vector2
var current_tile: Vector2i
var last_tile: Vector2i
var entity: Entity

func select_item(item_type: ItemType) -> void:
	selected_item_type = item_type
	
	if selected_item_shape: 
		selected_item_shape.queue_free()
	
	if !selected_item_type: 
		return
	
	selected_item_shape = Shape.new_shape(selected_item_type)
	selected_item_shape.modulate.a = 0.6
	self.add_child(selected_item_shape)

func _process(_delta: float) -> void:
	mouse_pos = get_global_mouse_position()
	last_tile = current_tile
	current_tile = HexUtil.screen_to_hex(mouse_pos)
	entity = tilemap.get_entity(current_tile)
	
	if Input.is_action_just_pressed("pipette"):
		if entity:
			select_item(entity.item_type)
			selected_item_shape._copy(entity.shape)
		else:
			select_item(null)
	
	if Input.is_action_pressed("remove"):
		if tilemap.remove_entity(current_tile):
			deconstruct_audio.position = mouse_pos
			deconstruct_audio.play()
			
	if Input.is_action_just_pressed("rotate"):
		var direction = -1 if Input.is_action_pressed("shift") else 1
		var rotating_shape = entity.shape if entity else selected_item_shape
		
		if !selected_item_type && !entity:
			return
		
		if Input.is_action_pressed("control"):
			rotating_shape._rotate_end(direction)
			return
			
		rotating_shape._rotate_whole(direction)
	
	
	if !selected_item_type: 
		return
	
	if selected_item_type.entity_scene:
		selected_item_shape.position = HexUtil.hex_to_screen(current_tile)
	else:
		selected_item_shape.position = mouse_pos + Vector2(10, 10)
	
	var shift: bool = Input.is_action_pressed("shift")
	if selected_item_shape is UndergroundBeltShape:
		selected_item_shape.set_entrance(!shift)
	
	if Input.is_action_just_pressed("flip_horizontal"):
		selected_item_shape._flip_horizontal()
	
	if Input.is_action_pressed("place"):
		if tilemap.get_entity(current_tile):
			return
		
		if !selected_item_type.entity_scene:
			return
		
		var new_entity: Entity = Entity.new_entity(selected_item_type)
		tilemap.set_entity(current_tile, new_entity)
		new_entity._sync_shape(selected_item_shape, current_tile)
		tilemap.set_entity_tiles(new_entity)
		
		new_entity._tile_update(tilemap)
		tilemap.update_neighbors(current_tile)
		
		build_audio.position = selected_item_shape.position
		build_audio.play()
	
	if Input.is_action_just_pressed("drop"):
		var belt_comp: BeltComponent = tilemap.get_belt_component(current_tile)
		if belt_comp:
			belt_comp.attempt_item_place(selected_item_type, mouse_pos)
	
	if Input.is_action_just_pressed("inspect"):
		if entity:
			entity._inspect()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.keycode >= KEY_0 && event.keycode <= KEY_9:
		var number: int = event.keycode - 49 # KEY_0 is 48, offset index by 1
		hotbar.set_slot_selected(number)
		select_item(hotbar.get_slot_item(number))
