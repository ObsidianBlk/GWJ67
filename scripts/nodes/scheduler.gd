extends Node
class_name Scheduler

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const CONTROL_GROUP_PLAYER : StringName = &"PlayerCTRL"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Static Variables
# ------------------------------------------------------------------------------
static var _Instance : Scheduler = null

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _ctrls : Dictionary = {}
var _order : Array[StringName] = []
var _idx : int = 0
var _actions_remaining : int = 0

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _enter_tree() -> void:
	if _Instance == null:
		_Instance = self

func _exit_tree() -> void:
	if _Instance == self:
		_Instance = null

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _NextAction() -> void:
	pass

# ------------------------------------------------------------------------------
# Static Public Methods
# ------------------------------------------------------------------------------
static func Get() -> WeakRef:
	return weakref(_Instance)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func register_controller(ctrl : ScheduledController) -> void:
	if ctrl == null: return
	if not ctrl.name in _ctrls:
		_ctrls[ctrl.name] = weakref(ctrl)
		if ctrl.is_in_group(CONTROL_GROUP_PLAYER):
			_order.push_front(ctrl.name)
		else:
			_order.append(ctrl.name)
		
		if not ctrl.action_complete.is_connected(_on_action_complete):
			ctrl.action_complete.connect(_on_action_complete)

func unregister_controller(ctrl : ScheduledController) -> void:
	if ctrl.name in _ctrls:
		if ctrl.action_complete.is_connected(_on_action_complete):
			ctrl.action_complete.disconnect(_on_action_complete)
			
		_ctrls.erase(ctrl.name)
		var idx : int = _order.find(ctrl.name)
		if idx >= 0:
			if idx < _idx:
				_idx -= 1
			_order.remove_at(idx)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_action_complete() -> void:
	_actions_remaining -= 1


