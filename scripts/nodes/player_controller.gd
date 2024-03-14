extends ScheduledController
class_name PlayerController

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const PARASITE_SCENE : PackedScene = preload("res://objects/parasite/parasite.tscn")

const ATTACK_ENTER_AMOUNT : int = 5
const ATTACK_EXIT_AMOUNT : int = 5
const ATTACK_EAT_AMOUNT : int = 10

enum Mode {MOVE=0, EXIT=1}

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Player Controller")

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _mode : Mode = Mode.MOVE

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
		_HandleAction(Actor.DIRECTION.North)
	elif event.is_action_pressed("down"):
		_HandleAction(Actor.DIRECTION.South)
	elif event.is_action_pressed("left"):
		_HandleAction(Actor.DIRECTION.West)
	elif event.is_action_pressed("right"):
		_HandleAction(Actor.DIRECTION.East)
	
	if actor is Human and event.is_action_pressed("toggle_mode"):
		match _mode:
			Mode.MOVE:
				_mode = Mode.EXIT
			Mode.EXIT:
				_mode = Mode.MOVE

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
		#Scheduler.Unregister_Controller(self)

func _ConnectActor() -> void:
	if actor == null: return
	super._ConnectActor()
	
	if not actor.move_ended.is_connected(_on_actor_move_ended):
		actor.move_ended.connect(_on_actor_move_ended)
	
	if not actor.is_in_group(Settings.ACTOR_GROUP_PLAYER):
		actor.add_to_group(Settings.ACTOR_GROUP_PLAYER)

func _HandleAction(direction : Actor.DIRECTION) -> void:
	if actor is Parasite:
		var target : Actor = actor.get_adjacent_actor(direction)
		if target is Human:
			if target.is_alive():
				var life : int = target.attack(ATTACK_ENTER_AMOUNT)
				print("ENTERING! Got ", life, " life!")
				actor.queue_free()
				actor = target
				return
			else:
				var life : int = target.attack(ATTACK_EAT_AMOUNT)
				print("EATING! Got ", life, " life!")
				target.queue_free()
	elif actor is Human and _mode == Mode.EXIT:
		var parasite : Actor = PARASITE_SCENE.instantiate()
		parasite.map = AStarTileMap.Get().get_ref()
		if AStarTileMap.Add_Actor(parasite, actor.global_position, direction):
			var life : int = actor.attack(ATTACK_EXIT_AMOUNT)
			print("EXITING! Got ", life, " life!")
			actor = parasite
			return

	actor.move(direction)

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


