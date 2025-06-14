class_name Main extends Node2D

@onready var tilemap: HexTileMap = $HexTileMap
@onready var camera: Camera2D = $Camera2D
@onready var hotbar: Hotbar = $CanvasLayer/Hotbar
@onready var build_audio: AudioStreamPlayer2D = $BuildAudioPlayer
@onready var deconstruct_audio: AudioStreamPlayer2D = $DeconstructAudioPlayer

var transport_belt: ItemType = preload("res://items/transport_belt/transport_belt.tres")
var inserter: ItemType = preload("res://items/inserter/inserter.tres")
var assembling_machine: ItemType = preload("res://items/assembling_machine/assembling_machine.tres")
var iron_plate: ItemType = preload("res://items/iron_plate/iron_plate.tres")
var copper_plate: ItemType = preload("res://items/copper_plate/copper_plate.tres")
var underground_belt: ItemType = preload("res://items/underground_belt/underground_belt.tres")
var fast_underground_belt: ItemType = preload("res://items/underground_belt/fast_underground_belt.tres")
var fast_transport_belt: ItemType = preload("res://items/transport_belt/fast_transport_belt.tres")
var express_transport_belt: ItemType = preload("res://items/transport_belt/express_transport_belt.tres")
var splitter: ItemType = preload("res://items/splitter/splitter.tres")
var balancer: ItemType = preload("res://items/balancer/balancer.tres")

var selected_item_type: ItemType
var selected_item_shape: Shape


func select_item(item_type: ItemType) -> void:
	selected_item_type = item_type
	
	if selected_item_shape: 
		selected_item_shape.queue_free()
	
	if !selected_item_type: 
		return
	
	selected_item_shape = Shape.new_shape(selected_item_type)
	selected_item_shape.modulate.a = 0.6
	self.add_child(selected_item_shape)

func _ready():
	select_item(transport_belt)
	
	hotbar.set_slot_selected_function = select_item
	hotbar.set_slot_item(0, transport_belt)
	hotbar.set_slot_item(1, underground_belt)
	hotbar.set_slot_item(2, fast_transport_belt)
	hotbar.set_slot_item(3, fast_underground_belt)
	hotbar.set_slot_item(4, express_transport_belt)
	hotbar.set_slot_item(5, iron_plate)
	hotbar.set_slot_item(6, copper_plate)
	hotbar.set_slot_item(7, splitter)
	hotbar.set_slot_item(8, assembling_machine)
	hotbar.set_slot_item(9, balancer)

func _process(_delta: float) -> void:
	var mouse: Vector2 = get_global_mouse_position()
	var tile: Vector2i = HexUtil.screen_to_hex(get_global_mouse_position())
	var entity: Entity = tilemap.get_entity(tile)
	
	if Input.is_action_just_pressed("pipette"):
		if entity:
			select_item(entity.item_type)
			selected_item_shape._copy(entity.shape)
		else:
			select_item(null)
	
	if Input.is_action_pressed("remove"):
		if tilemap.remove_entity(tile):
			deconstruct_audio.position = mouse
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
		selected_item_shape.position = HexUtil.hex_to_screen(tile)
	else:
		selected_item_shape.position = mouse + Vector2(10, 10)
	
	var shift: bool = Input.is_action_pressed("shift")
	if selected_item_shape is UndergroundBeltShape:
		selected_item_shape.set_entrance(!shift)
	
	if Input.is_action_just_pressed("flip_horizontal"):
		selected_item_shape._flip_horizontal()
	
	if Input.is_action_pressed("place"):
		if tilemap.get_entity(tile):
			return
		
		if !selected_item_type.entity_scene:
			return
		
		var new_entity: Entity = Entity.new_entity(selected_item_type)
		tilemap.set_entity(tile, new_entity)
		new_entity._sync_shape(selected_item_shape, tile)
		tilemap.set_entity_tiles(new_entity)
		
		new_entity._tile_update(tilemap)
		tilemap.update_neighbors(tile)
		
		build_audio.position = selected_item_shape.position
		build_audio.play()
	
	if Input.is_action_just_pressed("drop"):
		var belt_comp: BeltComponent = tilemap.get_belt_component(tile)
		if belt_comp:
			belt_comp.attempt_item_place(selected_item_type, mouse)
	
	if Input.is_action_just_pressed("inspect"):
		if entity:
			entity._inspect()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.keycode >= KEY_0 && event.keycode <= KEY_9:
		var number: int = event.keycode - 49 # KEY_0 is 48, offset index by 1
		hotbar.set_slot_selected(number)
		select_item(hotbar.get_slot_item(number))
