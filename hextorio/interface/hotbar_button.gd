extends Button

@onready var viewport: SubViewport = $SubViewport
@onready var hotbar: Hotbar = get_node("../../../")

var held_item: PackedScene = null

const ICON_SIZE: Vector2i = Vector2i(64, 64)
const WHITE: Color = Color(0.9, 0.9, 0.9)
const GRAY: Color = Color(0.5, 0.5, 0.5)

func set_selected(selected: bool) -> void:
	var stylebox = get_theme_stylebox("normal").duplicate()
	stylebox.border_color = WHITE if selected else GRAY
	add_theme_stylebox_override("normal", stylebox)
	add_theme_stylebox_override("pressed", stylebox)
	add_theme_stylebox_override("hover_pressed", stylebox)
	add_theme_stylebox_override("hover", stylebox)

func set_item(item_scene: PackedScene, shape_scene: PackedScene) -> void:
	for n in viewport.get_children():
		remove_child(n)
	
	var shape: Shape = shape_scene.instantiate()
	shape.position = ICON_SIZE / 2
	viewport.add_child(shape)
	var texture: ViewportTexture = viewport.get_texture()
	self.icon = texture
	
	held_item = item_scene

func _on_pressed():
	hotbar.set_slot_selected(get_index())
