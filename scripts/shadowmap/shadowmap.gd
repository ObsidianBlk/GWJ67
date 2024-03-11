extends Node
class_name Shadowmap

# Adaptation of code found...
# https://www.albertford.com/shadowcasting/


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Shadow Map")
@export var map : TileMap = null
@export var layer : int = 0

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Static Variables
# ------------------------------------------------------------------------------
static var _Instance : Shadowmap = null

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	pass

func _enter_tree() -> void:
	if _Instance == null:
		_Instance = self

func _exit_tree() -> void:
	if _Instance == self:
		_Instance = null

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _IsWall(q : ShadowQuadrent, coord : Variant) -> bool:
	if map != null and typeof(coord) == TYPE_VECTOR2I:
		var map_coord : Vector2i = q.transform(coord)
		var tdata : TileData = map.get_cell_tile_data(layer, map_coord)
		if tdata == null:
			return true # A non-cell is considered a wall for this project.
		# TODO: Check tdata for a custom "wall" data, but otherwise assume it's a floor.
	return false

func _IsFloor(q : ShadowQuadrent, coord : Variant) -> bool:
	if map != null and typeof(coord) == TYPE_VECTOR2I:
		var map_coord : Vector2i = q.transform(coord)
		var tdata : TileData = map.get_cell_tile_data(layer, map_coord)
		if tdata != null:
			# TODO: Check to see if there's a custom "wall" data, but otherwise assume this is a floor.
			return true
	return false

# ------------------------------------------------------------------------------
# Public Static Methods
# ------------------------------------------------------------------------------
static func Get() -> WeakRef:
	return weakref(_Instance)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func compute_fov() -> void:
	pass

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
