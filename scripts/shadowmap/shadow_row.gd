extends RefCounted
class_name ShadowRow

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _depth : int = 0
var _start_slope : float = 0.0
var _end_slope : float = 0.0

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _init(depth : int, start_slope : float, end_slope : float) -> void:
	_depth = depth
	_start_slope = start_slope
	_end_slope = end_slope

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _RoundTiesUp(val : float) -> float:
	return floorf(val + 0.5)

func _RoundTiesDown(val : float) -> float:
	return ceilf(val - 0.5)


# ------------------------------------------------------------------------------
# Static Public Methods
# ------------------------------------------------------------------------------
static func CalcSlope(coord : Vector2i) -> float:
	var row : float = float(coord.x)
	var col : float = float(coord.y)
	return ((2 * col) - 1) / (2 * row)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func set_start_slope(slope : float) -> void:
	_start_slope = slope

func set_end_slope(slope : float) -> void:
	_end_slope = slope

func is_symmetric(coord : Vector2i) -> bool:
	var col : float = float(coord.y)
	return (col >= _depth * _start_slope) and (col <= _depth * _end_slope)

func get_coords() -> Array[Vector2i]:
	var coords : Array[Vector2i] = []
	var min_col : int = int(_RoundTiesUp(_depth * _start_slope))
	var max_col : int = int(_RoundTiesDown(_depth * _end_slope))
	for col in range(min_col, max_col + 1):
		coords.append(Vector2i(_depth, col))
	return coords

func next() -> ShadowRow:
	return ShadowRow.new(_depth + 1, _start_slope, _end_slope)


