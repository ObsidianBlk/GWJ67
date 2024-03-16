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
@export var blocking_data_name : String = ""
@export var floor_layer : int = 0
@export var object_layer : int = 2

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
func _IsBlocking(tdata : TileData) -> bool:
	if tdata != null and not blocking_data_name.is_empty():
		var blocking : Variant = tdata.get_custom_data(blocking_data_name)
		if typeof(blocking) == TYPE_BOOL:
			return blocking
	return false

func _IsWall(q : ShadowQuadrent, coord : Variant) -> bool:
	if map != null and typeof(coord) == TYPE_VECTOR2I:
		var map_coord : Vector2i = q.transform(coord)
		var tdata : TileData = map.get_cell_tile_data(floor_layer, map_coord)
		if tdata == null:
			return true # A non-cell is considered a wall for this project.
		
		# Check if the floor tile is blocking...
		if _IsBlocking(tdata):
			return true
		
		# Ok, it's a valid floor, let's check if there's a sight blocking object...
		tdata = map.get_cell_tile_data(object_layer, map_coord)
		if _IsBlocking(tdata):
			return true
	
	return false

func _IsFloor(q : ShadowQuadrent, coord : Variant) -> bool:
	if map != null and typeof(coord) == TYPE_VECTOR2I:
		var map_coord : Vector2i = q.transform(coord)
		var tdata : TileData = map.get_cell_tile_data(floor_layer, map_coord)
		if tdata != null:
			if _IsBlocking(tdata):
				return false # The floor tile is directly sight blocking
			tdata = map.get_cell_tile_data(object_layer, map_coord)
			if _IsBlocking(tdata):
				return false
	return true

func _Scan(viz : Array[Vector2i], q : ShadowQuadrent, row : ShadowRow, depth : int) -> void:
	if depth <= 0: return
	
	var prev_coord : Variant = null
	for coord : Vector2i in row.get_coords():
		if _IsWall(q, coord) or row.is_symmetric(coord):
			viz.append(q.transform(coord))
		if _IsWall(q, prev_coord) and _IsFloor(q, coord):
			row.set_start_slope(row.CalcSlope(coord))
		if _IsFloor(q, prev_coord) and _IsWall(q, coord):
			var nrow : ShadowRow = row.next()
			nrow.set_end_slope(row.CalcSlope(coord))
			_Scan(viz, q, nrow, depth - 1)
		prev_coord = coord
	if _IsFloor(q, prev_coord):
		_Scan(viz, q, row.next(), depth - 1)

# ------------------------------------------------------------------------------
# Public Static Methods
# ------------------------------------------------------------------------------
static func Get() -> WeakRef:
	return weakref(_Instance)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func compute_fov(q : ShadowQuadrent, depth : int, base_viz : Array[Vector2i] = []) -> Array[Vector2i]:
	if map == null or q == null or depth <= 0: return base_viz.slice(0)
	var viz : Array[Vector2i] = base_viz.slice(0)
	if viz.find(q.get_origin()) < 0:
		viz.append(q.get_origin())
	var row : ShadowRow = ShadowRow.new(1, -1, 1)
	_Scan(viz, q, row, depth)
	return viz

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
