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
var _highlight_region : Dictionary = {}

var _occupied_cells : Dictionary = {}
var _occupying_actors : Dictionary = {}

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
	child_entered_tree.connect(_on_child_entered_tree)
	child_exiting_tree.connect(_on_child_exiting_tree)
	_BuildAStarGrid()
	_RegisterActors()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _RegisterActors() -> void:
	for child : Node in get_children():
		_on_child_entered_tree(child)

func _BuildAStarGrid() -> void:
	var layer_index : int = get_layer_index_from_name(floor_layer_name)
	if layer_index < 0:
		return
	
	_astar.clear()
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	var maprect : Rect2i = get_used_rect()
	_astar.region = maprect
	_astar.update()
	_astar.fill_solid_region(maprect, true)
	var cells :Array[Vector2i] = get_used_cells(layer_index)
	for cell in cells:
		# TODO: Actually check data layer to see if the cell is still solid.
		_astar.set_point_solid(cell, false)
	astar_changed.emit()

func _RemoveRegion(region_name : StringName) -> void:
	if not region_name in _highlight_region: return
	for coord : Vector2i in _highlight_region[region_name]:
		_SetCellAlternate(0, coord, 0)
	_highlight_region.erase(region_name)

func _SetCellAlternate(layer : int, coord : Vector2i, alternate : int) -> void:
	var cell_source_id : int = get_cell_source_id(layer, coord)
	if cell_source_id < 0: return
	
	var cell_atlas_coord : Vector2i = get_cell_atlas_coords(layer, coord)
	set_cell(layer, coord, cell_source_id, cell_atlas_coord, alternate)

func _ClearActorCells(actor : Actor) -> void:
	if actor == null: return
	if not actor.name in _occupying_actors: return
	var cell : Vector2i = _occupying_actors[actor.name]
	if cell in _occupied_cells:
		_occupied_cells.erase(cell)
	_occupying_actors.erase(actor.name)
	
func _OccupyCell(actor : Actor, cell : Vector2i) -> void:
	if actor == null: return
	if actor.name in _occupying_actors:
		var old_cell : Vector2i = _occupying_actors[actor.name]
		if old_cell in _occupied_cells:
			_occupied_cells.erase(old_cell)
	_occupying_actors[actor.name] = cell
	_occupied_cells[cell] = actor

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------ 
func get_layer_index_from_name(layer_name : String) -> int:
	for i in range(get_layers_count()):
		if get_layer_name(i) == layer_name:
			return i
	return -1

func get_point_path(from : Vector2, to : Vector2) -> PackedVector2Array:
	var map_from : Vector2i = local_to_map(from)
	var map_to : Vector2i = local_to_map(to)
	if map_from != map_to:
		var results : PackedVector2Array = _astar.get_point_path(map_from, map_to)
		return results.slice(1)
	return []

func can_move_to(to : Vector2) -> bool:
	var map_to : Vector2i = local_to_map(to)
	if _astar.is_in_boundsv(map_to):
		if not _astar.is_point_solid(map_to):
			return not (map_to in _occupied_cells)
	return false

func is_point_solid(id : Vector2i) -> bool:
	if _astar.is_in_boundsv(id):
		if not _astar.is_point_solid(id):
			return id in _occupied_cells
	return true

func get_actors_in_region(region : Array[Vector2i]) -> Array[Actor]:
	var actors : Array[Actor] = []
	for cell : Vector2i in region:
		if cell in _occupied_cells:
			actors.append(_occupied_cells[cell])
	return actors

func highlight_region(region_name : StringName, region : Array[Vector2i], alternate : int) -> void:
	_RemoveRegion(region_name)
	if region.size() <= 0: return
	
	_highlight_region[region_name] = region
	for coord : Vector2i in _highlight_region[region_name]:
		_SetCellAlternate(0, coord, alternate)
	

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_child_entered_tree(child : Node) -> void:
	if not child is Actor: return
	if not child.move_ended.is_connected(_on_actor_move_ended.bind(child)):
		child.move_ended.connect(_on_actor_move_ended.bind(child))
	_on_actor_move_ended(child) # Because we need to ADD occupied status

func _on_child_exiting_tree(child : Node) -> void:
	if not child is Actor: return
	if child.move_ended.is_connected(_on_actor_move_ended.bind(child)):
		child.move_ended.disconnect(_on_actor_move_ended.bind(child))
	_ClearActorCells(child)

func _on_actor_move_ended(actor : Actor) -> void:
	var coord : Vector2i = local_to_map(actor.global_position)
	_OccupyCell(actor, coord)
