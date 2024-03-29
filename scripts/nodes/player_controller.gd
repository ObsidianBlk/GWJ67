extends ScheduledController
class_name PlayerController

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal dead()

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
	if not PlayerData.blood_level_changed.is_connected(_on_player_blood_changed):
		PlayerData.blood_level_changed.connect(_on_player_blood_changed)
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
	elif event.is_action_pressed("wait"):
		_EndAction.call_deferred()
	
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
	
	if actor is Human:
		if actor.facing_changed.is_connected(_on_factor_facing_changed):
			actor.facing_changed.disconnect(_on_factor_facing_changed)
	
	if actor is Parasite or actor is Human:
		if actor.dead.is_connected(_on_actor_dead):
			actor.dead.disconnect(_on_actor_dead)
	
	if is_processing_unhandled_input():
		set_process_unhandled_input(false)
		_EndAction.call_deferred()
		#Scheduler.Unregister_Controller(self)

func _ConnectActor() -> void:
	if actor == null: return
	super._ConnectActor()
	
	if not actor.move_ended.is_connected(_on_actor_move_ended):
		actor.move_ended.connect(_on_actor_move_ended)
	
	if actor is Human:
		if not actor.facing_changed.is_connected(_on_factor_facing_changed):
			actor.facing_changed.connect(_on_factor_facing_changed)
	
	if actor is Parasite or actor is Human:
		if not actor.dead.is_connected(_on_actor_dead):
			actor.dead.connect(_on_actor_dead)
	
	if not actor.is_in_group(Settings.ACTOR_GROUP_PLAYER):
		actor.add_to_group(Settings.ACTOR_GROUP_PLAYER)

func _AttackHuman(a : Human, amount : int) -> void:
	var blood : int = a.attack(amount)
	PlayerData.add_blood(blood)

func _HandleAction(direction : Actor.DIRECTION) -> void:
	if actor is Parasite:
		var target : Actor = actor.get_adjacent_actor(direction)
		if target is Human:
			if target.is_alive():
				_AttackHuman(target, ATTACK_ENTER_AMOUNT)
				actor.queue_free()
				actor = target
				actor.update_vision()
				_EndAction.call_deferred()
				return
			else:
				_AttackHuman(target, ATTACK_EAT_AMOUNT)
				target.queue_free()
		elif target is LevelExit:
			target.use()
			_EndAction.call_deferred()
	elif actor is Human:
		match _mode:
			Mode.EXIT:
				var parasite : Actor = PARASITE_SCENE.instantiate()
				parasite.map = AStarTileMap.Get().get_ref()
				if AStarTileMap.Add_Actor(parasite, actor.global_position, direction):
					_AttackHuman(actor, ATTACK_EXIT_AMOUNT)
					actor = parasite
					_EndAction.call_deferred()
					return
			Mode.MOVE:
				if not actor.can_move(direction):
					var actors : Array[Actor] = actor.get_nb_actors()
					for sub_actor : Actor in actors:
						if sub_actor is Switch:
							sub_actor.use()
							_EndAction.call_deferred()
							return

	if actor.can_move(direction):
		actor.move(direction)

func _IsAlive() -> bool:
	if actor == null or not actor.has_method("is_alive"): return false
	return actor.is_alive()

func _EndAction() -> void:
	set_process_unhandled_input(false)
	action_complete.emit()

# ------------------------------------------------------------------------------
# "Virtual" Public Methods
# ------------------------------------------------------------------------------
func action() -> void:
	if not _IsAlive() or PlayerData.get_blood_level() <= 0:
		_EndAction.call_deferred()
	else:
		actor.show_selection()
		if actor is Parasite:
			PlayerData.start_of_action()
		set_process_unhandled_input(true)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_actor_dead() -> void:
	dead.emit()

func _on_actor_move_ended() -> void:
	_EndAction.call_deferred()

func _on_factor_facing_changed() -> void:
	_EndAction.call_deferred()

func _on_player_blood_changed(blood_level : int) -> void:
	if actor != null and blood_level <= 0:
		actor.kill()
		_EndAction.call_deferred()

