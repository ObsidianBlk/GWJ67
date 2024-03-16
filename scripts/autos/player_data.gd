extends Node

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal blood_level_changed(blood_level)

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const MAX_BLOOD_LEVEL : int = 20


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _blood_level : int = MAX_BLOOD_LEVEL
var _bl_snapshot : int = MAX_BLOOD_LEVEL

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func reset() -> void:
	_blood_level = MAX_BLOOD_LEVEL
	blood_level_changed.emit(_blood_level)

func reset_snapshot() -> void:
	_blood_level = _bl_snapshot
	blood_level_changed.emit(_blood_level)

func start_of_level() -> void:
	_bl_snapshot = _blood_level

func start_of_action() -> void:
	if _blood_level <= 0: return
	_blood_level -= 1
	blood_level_changed.emit(_blood_level)

func add_blood(amount : int) -> void:
	if amount <= 0: return
	_blood_level = min(MAX_BLOOD_LEVEL, _blood_level + amount)
	blood_level_changed.emit(_blood_level)

func get_blood_level() -> int:
	return _blood_level

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
