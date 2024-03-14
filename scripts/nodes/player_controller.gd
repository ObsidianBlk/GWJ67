extends ScheduledController
class_name PlayerController

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Player Controller")

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
	super._ready()
	if not is_in_group(Scheduler.CONTROL_GROUP_PLAYER):
		add_to_group(Scheduler.CONTROL_GROUP_PLAYER)
	set_process_unhandled_input(false)

func _unhandled_input(event: InputEvent) -> void:
	if actor == null: return
	
	if event.is_action_pressed("up"):
		# TODO: Check if "Human" is in the direction I'm attempting to move...
		#  If so, take control of that Actor and remove Parasite Actor from the board.
		actor.move(Actor.DIRECTION.North)
	elif event.is_action_pressed("down"):
		actor.move(Actor.DIRECTION.South)
	elif event.is_action_pressed("left"):
		actor.move(Actor.DIRECTION.West)
	elif event.is_action_pressed("right"):
		actor.move(Actor.DIRECTION.East)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _DisconnectActor() -> void:
	if actor == null: return
	super._DisconnectActor()
	
	if actor.is_in_group(Settings.ACTOR_GROUP_PLAYER):
		actor.remove_from_group(Settings.ACTOR_GROUP_PLAYER)
		
	if actor.move_ended.is_connected(_on_actor_move_ended):
		actor.move_ended.disconnect(_on_actor_move_ended)
	
	if is_processing_unhandled_input():
		set_process_unhandled_input(false)
		_EndAction.call_deferred()
		Scheduler.Unregister_Controller(self)

func _ConnectActor() -> void:
	if actor == null: return
	super._ConnectActor()
	
	if not actor.move_ended.is_connected(_on_actor_move_ended):
		actor.move_ended.connect(_on_actor_move_ended)
	
	if not actor.is_in_group(Settings.ACTOR_GROUP_PLAYER):
		actor.add_to_group(Settings.ACTOR_GROUP_PLAYER)

func _EndAction() -> void:
	action_complete.emit()

# ------------------------------------------------------------------------------
# "Virtual" Public Methods
# ------------------------------------------------------------------------------
func action() -> void:
	if actor == null:
		_EndAction.call_deferred()
	else:
		set_process_unhandled_input(true)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_actor_move_ended() -> void:
	set_process_unhandled_input(false)
	_EndAction.call_deferred()


