extends TileMap
class_name AStarTileMap

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal astar_changed()

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("A-Star TileMap")
@export var floor_layer_name : String = ""

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _astar : AStarGrid2D = AStarGrid2D.new()

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func set_floor_layer_name(fln : String) -> void:
	if floor_layer_name != fln:
		floor_layer_name = fln
		_BuildAStarGrid()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_BuildAStarGrid()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _BuildAStarGrid() -> void:
	var layer_index : int = get_layer_index_from_name(floor_layer_name)
	if layer_index < 0:
		return
	
	_astar.clear()
	var maprect : Rect2i = get_used_rect()
	_astar.region = maprect
	_astar.update()
	_astar.fill_solid_region(maprect, true)
	var cells :Array[Vector2i] = get_used_cells(layer_index)
	for cell in cells:
		# TODO: Actually check data layer to see if the cell is still solid.
		_astar.set_point_solid(cell, false)
	astar_changed.emit()

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func get_layer_index_from_name(layer_name : String) -> int:
	for i in range(get_layers_count()):
		if get_layer_name(i) == layer_name:
			return i
	return -1

func get_point_path(from : Vector2, to : Vector2) -> Array[Vector2i]:
	var map_from : Vector2i = local_to_map(from)
	var map_to : Vector2i = local_to_map(to)
	if map_from != map_to:
		var results = _astar.get_point_path(map_from, map_to)
		return results.slice(1)
	return []

func can_move_to(to : Vector2) -> bool:
	var map_to : Vector2i = local_to_map(to)
	if _astar.is_in_boundsv(map_to):
		return not _astar.is_point_solid(map_to)
	return false

func is_point_solid(id : Vector2i) -> bool:
	if _astar.is_in_boundsv(id):
		return _astar.is_point_solid(id)
	return true

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------



