extends Node

# Hexagons use the axial coordinate system, pointy top orientation, and other conventions defined here:
# https://www.redblobgames.com/grids/hexagons/

const INNER_RADIUS: float = 32.0
const OUTER_RADIUS: float = (2.0 / sqrt(3.0)) * INNER_RADIUS

# The side length of each hexagon on the grid
const HEX_SIZE: float = OUTER_RADIUS

# Width and height of a hexagon
const HEX_WIDTH: float = sqrt(3.0) * HEX_SIZE
const HEX_HEIGHT: float = 2.0 * HEX_SIZE

# Horizontal and vertical distance between two hexagon's centers
const HORIZ: float = HEX_WIDTH
const VERT: float = 0.75 * HEX_HEIGHT

const NEIGHBORS: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 1), 
	Vector2i(-1, 0), Vector2i(0, -1), Vector2i(1, -1), 
]

# Polyhexes:
const MONOHEX: Array[Vector2i] = [Vector2i.ZERO]
const HEPTAHEX: Array[Vector2i] = [
	Vector2i(0, 0), Vector2i(0, -1), Vector2i(1, -1), Vector2i(1, 0), 
	Vector2i(0, 1), Vector2i(-1, 1), Vector2i(-1, 0)
]


func hex_to_screen(hex_pos: Vector2i) -> Vector2:
	var x_offset: float = (HORIZ / 2.0) * hex_pos.y
	var y_offset: float = 0
	
	return Vector2(x_offset + hex_pos.x * HORIZ, y_offset + hex_pos.y * VERT)
	
func screen_to_hex(screen_pos: Vector2) -> Vector2i:
	var q = (sqrt(3.0)/3.0 * screen_pos.x - 1.0/3.0 * screen_pos.y) / HEX_SIZE
	var r = (2.0/3.0 * screen_pos.y) / HEX_SIZE
	return axial_round(Vector2(q, r))
	
func axial_round(frac: Vector2) -> Vector2i:
	var grid = frac.round()
	var remainder = frac - grid
	
	if abs(remainder.x) >= abs(remainder.y):
		return Vector2i(grid.x + round(remainder.x + 0.5 * remainder.y), grid.y)
	else:
		return Vector2i(grid.x, grid.y + round(remainder.y + 0.5 * remainder.x))


func generate_hex_grid(width: int, height: int) ->  Dictionary[Vector2i, Vector2]:
	var grid: Dictionary[Vector2i, Vector2] = {}
	var x_offset = 0
	
	for y: int in range(height):
		for x: int in range(width):
			var tile := Vector2i(x + x_offset, y)
			var center = hex_to_screen(tile)
			grid[tile] = center
		if y % 2 == 1:
			x_offset -= 1
	
	return grid


func get_hex_points(radius, angle_offset=0) -> Array[Vector2]:
	var hex_points: Array[Vector2] = []
	for i in range(6.0):
		var angle: float = i / 3.0 * PI + angle_offset
		hex_points.append(Vector2(cos(angle), sin(angle)) * radius)

	return hex_points

func get_quarter_hex_points(radius):
	var quarter_hex_points = []
	var hex_points: Array[Vector2] = get_hex_points(radius)
	
	for i in range(6.0):
		var offset: Vector2 = Vector2(0, HEX_SIZE / 4.0).rotated(i / 3.0 * PI)
		var pair: Array[Vector2]
		quarter_hex_points.append([hex_points[i] - offset, hex_points[i] + offset])
	
	return quarter_hex_points


# Defines a set of points around a hexagon at (0, 0)
var HEX_POINTS_LEGEND = {
	"SIDE_CENTER": get_hex_points(INNER_RADIUS),
	"SIDE_QUARTER_PAIRS": get_quarter_hex_points(INNER_RADIUS),
	"MIDDLE_CENTER": get_hex_points(OUTER_RADIUS / 2.0, PI / 6.0),
	"SMALL": get_hex_points(OUTER_RADIUS * (sqrt(3) / 6))
}
