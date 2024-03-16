extends Actor
class_name Switch

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal state_changed(state : int)

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const LAYER_WALLS : int = 1
const CUSTOM_DATA_SWITCH : String = "switch"

const SWITCH_OFF : int = 0
const SWITCH_ON : int = 1

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Switch")

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _state = SWITCH_OFF

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _sprite_2d: Sprite2D = $Sprite2D


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	super._ready()
	if not Engine.is_editor_hint():
		_sprite_2d.queue_free()
		_sprite_2d = null
	_SetStateFromWall()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _SetStateFromWall() -> void:
	if map == null: return
	var cell : Vector2i = get_map_position()
	var tdata : TileData = map.get_cell_tile_data(LAYER_WALLS, cell)
	var old_state : int = _state
	_state = SWITCH_OFF
	if tdata != null:
		var switch_state : Variant = tdata.get_custom_data(CUSTOM_DATA_SWITCH)
		if typeof(switch_state) == TYPE_INT and switch_state == 1:
			_state = SWITCH_ON
	if old_state != _state:
		state_changed.emit(_state)

func _UpdateSwitchState(cell : Vector2i, wall_state : int) -> void:
	if map == null or wall_state == 0: return
	var sid : int = map.get_cell_source_id(LAYER_WALLS, cell)
	var alternate : int = map.get_cell_alternative_tile(LAYER_WALLS, cell)
	var atlas : Vector2i = map.get_cell_atlas_coords(LAYER_WALLS, cell)
	match wall_state:
		-1: # Switch is currently OFF
			atlas.x += 1
			_state = SWITCH_ON
		1: # Switch is currently ON
			atlas.x -= 1
			_state = SWITCH_OFF
	map.set_cell(LAYER_WALLS, cell, sid, atlas, alternate)
	state_changed.emit(_state)
	
# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func use() -> void:
	if map == null: return
	var cell : Vector2i = get_map_position()
	var tdata : TileData = map.get_cell_tile_data(LAYER_WALLS, cell)
	if tdata != null:
		var switch_state : Variant = tdata.get_custom_data(CUSTOM_DATA_SWITCH)
		if typeof(switch_state) == TYPE_INT:
			_UpdateSwitchState(cell, switch_state)

func is_on() -> bool:
	return _state == SWITCH_ON

func get_state() -> int:
	return _state

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------



