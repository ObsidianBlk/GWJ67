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
static var _Prereg : Array[ScheduledController] = []

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _ctrls : Dictionary = {}
var _order : Array[StringName] = []
var _idx : int = 0
var _actions_remaining : int = 0

var _running : bool = false

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
	execute.call_deferred()

func _enter_tree() -> void:
	if _Instance == null:
		_Instance = self
		if _Prereg.size() > 0:
			for ctrl : ScheduledController in _Prereg:
				# TODO: Is <ctrl> actually IN the tree?
				_Instance.Register_Controller(ctrl)
			_Prereg.clear()

func _exit_tree() -> void:
	if _Instance == self:
		_Instance = null
		_Prereg.clear()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Static Public Methods
# ------------------------------------------------------------------------------
static func Get() -> WeakRef:
	return weakref(_Instance)

static func Register_Controller(ctrl : ScheduledController) -> void:
	if _Instance == null:
		_Prereg.append(ctrl)
	else:
		_Instance.register_controller(ctrl)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func register_controller(ctrl : ScheduledController) -> void:
	if ctrl == null: return
	if not ctrl.name in _ctrls:
		_ctrls[ctrl.name] = weakref(ctrl)
		print("Registering Controller: ", ctrl.name)
		if ctrl.is_in_group(CONTROL_GROUP_PLAYER):
			_order.push_front(ctrl.name)
			if _running:
				_idx = (_idx + 1) % _order.size()
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

func execute() -> void:
	_running = true
	var ctrl : ScheduledController = null
	
	if _idx >= 0 and _idx < _order.size():
		if not _order[_idx] in _ctrls: return
		ctrl = _ctrls[_order[_idx]].get_ref()
	
	if ctrl != null:
		_actions_remaining = ctrl.action_points
	
	if _actions_remaining <= 0 or ctrl == null:
		_on_action_complete.call_deferred()
	else:
		ctrl.action.call_deferred()

func stop() -> void:
	_running = false

func is_running() -> bool:
	return _running

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_action_complete() -> void:
	_actions_remaining -= 1
	if _actions_remaining <= 0 and _order.size() > 0:
		_idx = (_idx + 1) % _order.size()
	if _running:
		execute()


