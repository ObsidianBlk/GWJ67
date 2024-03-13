extends ScheduledController
class_name PlayerController

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
const PLAYER_GROUP : StringName = &"Player"

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
	
	if actor.is_in_group(PLAYER_GROUP):
		actor.remove_from_group(PLAYER_GROUP)
		
	if actor.move_ended.is_connected(_on_actor_move_ended):
		actor.move_ended.disconnect(_on_actor_move_ended)

func _ConnectActor() -> void:
	if actor == null: return
	
	if not actor.move_ended.is_connected(_on_actor_move_ended):
		actor.move_ended.connect(_on_actor_move_ended)
	
	if not actor.is_in_group(PLAYER_GROUP):
		actor.add_to_group(PLAYER_GROUP)

func _EndAction() -> void:
	action_complete.emit()
#func _GetPlayerActor() -> Actor:
	#var actors : Array = get_tree().get_nodes_in_group(PLAYER_GROUP)
	#for actor in actors:
		#if actor is Actor:
			#return actor
	#return null

# ------------------------------------------------------------------------------
# "Virtual" Public Methods
# ------------------------------------------------------------------------------
func action() -> void:
	set_process_unhandled_input(true)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_actor_move_ended() -> void:
	set_process_unhandled_input(false)
	_EndAction.call_deferred()


