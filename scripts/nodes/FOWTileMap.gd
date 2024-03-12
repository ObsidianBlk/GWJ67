extends TileMap
class_name FOWTileMap

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("FOW Tile Map")
@export var parent_map : TileMap = null:			set = set_parent_map

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _region : Dictionary = {}

# ------------------------------------------------------------------------------
# Static Variables
# ------------------------------------------------------------------------------
static var _Instance : FOWTileMap = null

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func set_parent_map(pm : TileMap) -> void:
	if pm == self: return # Can't set to self
	if pm == null:
		_DisconnectParentMap()
		parent_map == null
	elif pm.tile_set == tile_set: # Must connect to a tilemap that's using the same tileset!!
		_DisconnectParentMap()
		parent_map = pm
		_ConnectParentMap()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_ConnectParentMap()

func _enter_tree() -> void:
	if _Instance == null:
		_Instance = self

func _exit_tree() -> void:
	if _Instance == self:
		_Instance = null

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _DisconnectParentMap() -> void:
	if parent_map == null: return
	clear()
	if parent_map.changed.is_connected(_on_parent_map_changed):
		parent_map.changed.disconnect(_on_parent_map_changed)

func _ConnectParentMap() -> void:
	if parent_map == null: return
	if not parent_map.changed.is_connected(_on_parent_map_changed):
		parent_map.changed.connect(_on_parent_map_changed)

func _UpdateCell(layer : int, cell : Vector2i, alt : int) -> void:
	if parent_map == null: return
	var cell_id : int = parent_map.get_cell_source_id(layer, cell)
	if cell_id < 0: return
	var cell_atlas : Vector2i = parent_map.get_cell_atlas_coords(layer, cell)
	set_cell(layer, cell, cell_id, cell_atlas, alt)

func _UpdateRegions() -> void:
	if parent_map == null: return
	var parent_layer_count : int = parent_map.get_layers_count()
	var layer_count : int = get_layers_count()
	
	clear()
	for region_name in _region.keys():
		for cell in _region[region_name].cells:
			for layer in range(parent_layer_count):
				if not (layer >= 0 and layer < layer_count): continue
				_UpdateCell(layer, cell, _region[region_name].alt)
					

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func clear_regions() -> void:
	clear()
	_region.clear()

func clear_region(region_name : String) -> void:
	if region_name in _region:
		_region.erase(region_name)
		_UpdateRegions()

func set_region(region_name : String, region : Array[Vector2i], alternate : int) -> void:
	if parent_map == null: return
	if region_name in _region:
		_region.erase(region_name)
	if region.size() > 0:
		_region[region_name] = {"cells":region, "alt":alternate}
	_UpdateRegions()

# ------------------------------------------------------------------------------
# Static Public Methods
# ------------------------------------------------------------------------------
static func Get() -> WeakRef:
	return weakref(_Instance)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_parent_map_changed() -> void:
	if parent_map.tile_set != tile_set:
		_DisconnectParentMap()
		parent_map = null
		clear_regions()
