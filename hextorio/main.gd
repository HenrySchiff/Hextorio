extends Node2D

@onready var tilemap: TileMapLayer = $TileMap
@onready var camera: Camera2D = $Camera2D
@onready var hotbar: Hotbar = $CanvasLayer/Hotbar

var item_scene: PackedScene = preload("res://items/Item.tscn")

var transport_belt: ItemType = preload("res://items/TransportBelt/transport_belt.tres")
var inserter: ItemType = preload("res://items/Inserter/inserter.tres")
var assembling_machine: ItemType = preload("res://items/AssemblingMachine/assembling_machine.tres")
var iron_plate: ItemType = preload("res://items/IronPlate/iron_plate.tres")
var copper_plate: ItemType = preload("res://items/CopperPlate/copper_plate.tres")

var selected_item_type: ItemType
var selected_item_shape: Shape

func select_item(item_type: ItemType) -> void:
	selected_item_type = item_type

	if selected_item_shape: 
		selected_item_shape.queue_free()
	
	if !selected_item_type: 
		return
	
	selected_item_shape = selected_item_type.shape_scene.instantiate()
	selected_item_shape.modulate.a = 0.6
	self.add_child(selected_item_shape)

func _ready():
	select_item(transport_belt)
	
	hotbar.set_slot_item(0, transport_belt)
	hotbar.set_slot_item(1, inserter)
	hotbar.set_slot_item(2, assembling_machine)
	hotbar.set_slot_item(3, iron_plate)
	hotbar.set_slot_item(4, copper_plate)

func _process(delta):
	if !selected_item_type: 
		return
	
	var mouse: Vector2 = get_global_mouse_position()
	var tile: Vector2i = tilemap.local_to_map(get_global_mouse_position())
	
	if selected_item_type.entity_scene:
		var snapped: Vector2i = tilemap.map_to_local(tile)
		selected_item_shape.position = snapped
	else:
		selected_item_shape.position = mouse + Vector2(10, 10)
	
	if Input.is_action_just_pressed("rotate"):
		if Input.is_action_pressed("shift"):
			selected_item_shape._rotate_end(1)
			return
			
		selected_item_shape._rotate_whole(1)
		
	if Input.is_action_just_pressed("flip_horizontal"):
		selected_item_shape._flip_horizontal()
	
	if Input.is_action_pressed("place"):
		if tilemap.get_scene_tile(tile):
			return
		
		if !selected_item_type.entity_scene:
			return
		
		var has_item: bool = Input.is_action_pressed("shift")
		var entity: Entity = Entity.new_entity(selected_item_type)
		tilemap.set_scene_tile(tile, entity)
		
		entity._sync_shape(selected_item_shape, tile)
		entity._tile_update(tilemap)
		tilemap.update_neighbors(tile)
	
	if Input.is_action_pressed("remove"):
		tilemap.remove_scene_tile(tile)
		
	if Input.is_action_just_pressed("drop"):
		var entity = tilemap.get_scene_tile(tile)
		
		if !(entity is TransportBelt):
			return
		
		var belt = entity as TransportBelt
		belt.attempt_item_place(selected_item_type, mouse)
		
	if Input.is_action_just_pressed("pipette"):
		var entity: Entity = tilemap.get_scene_tile(tile)
		if !entity: return
		select_item(entity.item_type)
		#selected_item_shape._copy(entity.shape)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.keycode >= KEY_0 && event.keycode <= KEY_9:
		var number: int = event.keycode - 49 # KEY_0 is 48, offset index by 1
		hotbar.set_slot_selected(number)
		select_item(hotbar.get_slot_item(number))
