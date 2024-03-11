extends RefCounted
class_name ShadowQuadrent

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
enum Cardinal {NORTH=0, EAST=1, SOUTH=2, WEST=3}

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _origin : Vector2 = Vector2.ZERO
var _cardinal : Cardinal = Cardinal.NORTH

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _init(origin : Vector2, cardinal : Cardinal) -> void:
	_origin = origin
	_cardinal = cardinal

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func transform(coord : Vector2i) -> Vector2i:
	match _cardinal:
		Cardinal.NORTH:
			return Vector2i(_origin.x + coord.y, _origin.y - coord.x)
		Cardinal.EAST:
			return Vector2i(_origin.x + coord.x, _origin.y + coord.y)
		Cardinal.SOUTH:
			return Vector2i(_origin.x + coord.y, _origin.y + coord.x)
		Cardinal.WEST:
			return Vector2i(_origin.x - coord.x, _origin.y + coord.y)
	return coord
