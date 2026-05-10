class_name Main extends Node2D

@onready var tilemap: HexTileMap = $HexTileMap
@onready var camera: Camera2D = $Camera2D
@onready var hotbar: Hotbar = $CanvasLayer/Hotbar
@onready var entity_placer: EntityPlacer = $EntityPlacer

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

func _ready():
	entity_placer.select_item(transport_belt)
	
	hotbar.set_slot_selected_function = entity_placer.select_item
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
