extends Node

# Hexagons use the axial coordinate system, pointy top orientation, and other conventions defined here:
# https://www.redblobgames.com/grids/hexagons/

const INNER_RADIUS: float = 32.0
const OUTER_RADIUS: float = (2 / sqrt(3)) * INNER_RADIUS

# The side length of each hexagon on the grid
const HEX_SIZE = OUTER_RADIUS

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
	return Vector2.ZERO
	
func screen_to_hex(screen_pos: Vector2) -> Vector2i:
	return Vector2i.ZERO


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
