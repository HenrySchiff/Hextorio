extends Node2D

@onready var tilemap: TileMapLayer = $TileMap
@onready var camera: Camera2D = $Camera2D
@onready var hotbar: Hotbar = $CanvasLayer/Hotbar

var initial_cam_pos: Vector2

var belt_scene: PackedScene = preload("res://items/TransportBelt/TransportBelt.tscn")
var inserter_scene: PackedScene = preload("res://items/Inserter/Inserter.tscn")
var assembling_machine_scene: PackedScene = preload("res://items/AssemblingMachine/AssemblingMachine.tscn")

var belt_shape_scene: PackedScene = preload("res://items/TransportBelt/TransportBeltShape.tscn")
var inserter_shape_scene: PackedScene = preload("res://items/Inserter/InserterShape.tscn")
var assembling_machine_shape_scene: PackedScene = preload("res://items/AssemblingMachine/AssemblingMachineShape.tscn")

var selected_item_scene: PackedScene
var selected_item_shape: Shape

var item_shape_scenes: Dictionary = {
	belt_scene: belt_shape_scene,
	inserter_scene: inserter_shape_scene,
	assembling_machine_scene: assembling_machine_shape_scene
}


func _ready():
	initial_cam_pos = camera.position
	
	selected_item_scene = belt_scene
	selected_item_shape = item_shape_scenes[selected_item_scene].instantiate()
	
	selected_item_shape.modulate.a = 0.5
	self.add_child(selected_item_shape)
	
	hotbar.set_slot_item(0, belt_scene, belt_shape_scene)
	hotbar.set_slot_item(1, inserter_scene, inserter_shape_scene)
	hotbar.set_slot_item(2, assembling_machine_scene, assembling_machine_shape_scene)

func _process(delta):
	var mouse: Vector2 = get_global_mouse_position()
	var tile: Vector2i = tilemap.local_to_map(get_global_mouse_position())
	var snapped: Vector2i = tilemap.map_to_local(tile)
	selected_item_shape.position = snapped
	
	if Input.is_action_just_pressed("rotate"):
		if Input.is_action_pressed("shift"):
			selected_item_shape._rotate_end(1)
			return
			
		selected_item_shape._rotate_whole(1)
		
	if Input.is_action_just_pressed("flip_horizontal"):
		selected_item_shape._flip_horizontal()
	
	if Input.is_action_pressed("place"):
		var has_item: bool = Input.is_action_pressed("shift")
		var item: Item = selected_item_scene.instantiate()
		tilemap.set_scene_tile(tile, item)
		
		#item.shape._copy(selected_item_shape)
		item._sync_shape(selected_item_shape, tile)
		item._tile_update(tilemap)
		tilemap.update_neighbors(tile)
		if item is TransportBelt && has_item:
			item.left_transport_line.receive_item()
			item.right_transport_line.receive_item()
	
	if Input.is_action_pressed("remove"):
		tilemap.remove_scene_tile(tile)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.keycode >= KEY_0 && event.keycode <= KEY_9:
		var number: int = event.keycode - 49 # KEY_0 is 48, offset index by 1
		hotbar.set_slot_selected(number)
		
		var item_scene: PackedScene = hotbar.get_slot_item(number)
		if (!item_scene): return
		selected_item_shape.queue_free()
		selected_item_scene = item_scene
		selected_item_shape = item_shape_scenes[item_scene].instantiate()
		selected_item_shape.modulate.a = 0.5
		self.add_child(selected_item_shape)
