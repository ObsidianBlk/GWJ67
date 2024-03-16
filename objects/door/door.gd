@tool
extends Actor
class_name Door

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const FACING_NS : int = 0
const FACING_EW : int = 1

const STATE_CLOSED : int = 0
const STATE_OPEN : int = 1

const NS_PREFIX : String = "ns_"
const EW_PREFIX : String = "ew_"

const ANIM_IDLE_OPEN = "idle_open"
const ANIM_IDLE_CLOSED = "idle_closed"
const ANIM_OPENING = "opening"
const ANIM_CLOSING = "closing"

const SOURCE_ID_OBJECTS : int = 2
const LAYER_OBJECTS : int = 2
const BLOCKING_OBJECT_ATLAS : Vector2i = Vector2i.ZERO

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Door")
@export_enum("North-South:0", "East-West:1") var facing : int = 0:		set = set_facing
@export var switch : Switch = null:										set = set_switch

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _state : int = STATE_CLOSED

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _asprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _sprite: Sprite2D = $Sprite2D


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func set_facing(f : int) -> void:
	if f >= 0 and f < 2:
		facing = f
		_SetVisual()

func set_switch(s : Switch) -> void:
	_DisconnectSwitch()
	switch = s
	_ConnectSwitch()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	super._ready()
	if not Engine.is_editor_hint():
		_sprite.queue_free()
		_sprite = null
	_ConnectSwitch()
	_UpdateMapTile()
	

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ConnectSwitch() -> void:
	if Engine.is_editor_hint() or switch == null: return
	if not switch.state_changed.is_connected(_on_switch_state_changed):
		switch.state_changed.connect(_on_switch_state_changed)
	_on_switch_state_changed(switch.get_state())

func _DisconnectSwitch() -> void:
	if Engine.is_editor_hint() or switch == null: return
	if switch.state_changed.is_connected(_on_switch_state_changed):
		switch.state_changed.disconnect(_on_switch_state_changed)

func _SetVisual() -> void:
	if _asprite == null: return
	var anim : String = ""
	match facing:
		FACING_NS:
			if Engine.is_editor_hint():
				anim = "%s%s"%[
					NS_PREFIX,
					ANIM_IDLE_OPEN if _state == STATE_OPEN else ANIM_IDLE_CLOSED
				]
			else:
				anim = "%s%s"%[
					NS_PREFIX,
					ANIM_OPENING if _state == STATE_OPEN else ANIM_CLOSING
				]
		FACING_EW:
			if Engine.is_editor_hint():
				anim = "%s%s"%[
					EW_PREFIX,
					ANIM_IDLE_OPEN if _state == STATE_OPEN else ANIM_IDLE_CLOSED
				]
			else:
				anim = "%s%s"%[
					EW_PREFIX,
					ANIM_OPENING if _state == STATE_OPEN else ANIM_CLOSING
				]
	_asprite.play(anim)
	_UpdateMapTile()

func _UpdateMapTile() -> void:
	if Engine.is_editor_hint() or map == null: return
	var cell = get_map_position()
	
	match _state:
		STATE_OPEN:
			map.erase_cell(LAYER_OBJECTS, cell)
		STATE_CLOSED:
			map.set_cell(LAYER_OBJECTS, cell, SOURCE_ID_OBJECTS, BLOCKING_OBJECT_ATLAS)
	map.update_astar()

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_switch_state_changed(state : int) -> void:
	if state == Switch.SWITCH_ON:
		_state = STATE_OPEN
	elif state == Switch.SWITCH_OFF:
		_state = STATE_CLOSED
	_SetVisual()


