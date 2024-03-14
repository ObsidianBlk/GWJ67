extends Node
class_name ScheduledController

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal action_complete()

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Scheduled Controller")
@export var actor : Actor = null:						set = set_actor
@export_range(1, 10) var action_points : int = 2

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func set_actor(a : Actor) -> void:
	if a != actor:
		_DisconnectActor()
		actor = a
		_ConnectActor()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_ConnectActor()
	Scheduler.Register_Controller(self)
	#_RegisterToScheduler.call_deferred()

# ------------------------------------------------------------------------------
# "Virtual" Private Methods
# ------------------------------------------------------------------------------
func _DisconnectActor() -> void:
	if actor == null: return
	if actor.tree_exiting.is_connected(_on_actor_tree_exiting):
		actor.tree_exiting.disconnect(_on_actor_tree_exiting)

func _ConnectActor() -> void:
	if actor == null: return
	if not actor.tree_exiting.is_connected(_on_actor_tree_exiting):
		actor.tree_exiting.connect(_on_actor_tree_exiting)


# ------------------------------------------------------------------------------
# "virtual" Public Methods
# ------------------------------------------------------------------------------
func action() -> void:
	pass


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_actor_tree_exiting() -> void:
	actor = null


