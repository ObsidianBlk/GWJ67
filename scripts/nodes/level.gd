extends Node2D
class_name Level

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal requested(action : StringName, payload : Dictionary)

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const GROUP_LEVEL_EXIT : StringName = &"LevelExit"

const REQUEST_NEXT_LEVEL : StringName = &"next_level"
const REQUEST_GAME_SUCCESS : StringName = &"game_success"
const REQUEST_GAME_FAILURE : StringName = &"game_failure"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Level")

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------

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
	_ConnectLevelExits()
	_ConnectPlayerController()

#func _enter_tree() -> void:
	#_ConnectLevelExits()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ConnectLevelExits() -> void:
	var actors : Array[Node] = get_tree().get_nodes_in_group(GROUP_LEVEL_EXIT)
	for actor : Node in actors:
		if actor is LevelExit:
			if not actor.level_exit_requested.is_connected(_on_level_exit_requested):
				actor.level_exit_requested.connect(_on_level_exit_requested)
			if not actor.final_exit_requested.is_connected(_on_final_level_requested):
				actor.final_exit_requested.connect(_on_final_level_requested)

func _ConnectPlayerController() -> void:
	var ctrls : Array[Node] = get_tree().get_nodes_in_group(Scheduler.CONTROL_GROUP_PLAYER)
	for ctrl : Node in ctrls:
		if ctrl is PlayerController:
			if not ctrl.dead.is_connected(_on_player_dead):
				ctrl.dead.connect(_on_player_dead)

func _Request(action : StringName, payload : Dictionary = {}) -> void:
	requested.emit(action, payload)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_level_exit_requested(level_src : String) -> void:
	_Request.call_deferred(REQUEST_NEXT_LEVEL, {"level_src":level_src})

func _on_final_level_requested() -> void:
	_Request.call_deferred(REQUEST_GAME_SUCCESS)

func _on_player_dead() -> void:
	_Request.call_deferred(REQUEST_GAME_FAILURE)
