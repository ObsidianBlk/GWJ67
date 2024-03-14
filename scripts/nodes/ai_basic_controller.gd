extends ScheduledController
class_name AIBasicController

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const HIGHLIGHT_ALTERNATE_TILE_INDEX : int = 3

enum State {PATROL=0, HUNT=1}

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("AI Basic Controller")
@export var patrol_group : StringName = &"":			set = set_patrol_group


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _state : State = State.PATROL

var _target_point : PatrolPoint = null
var _goto_point : Vector2 = Vector2.ZERO

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func set_patrol_group(pg : StringName) -> void:
	if pg == patrol_group: return
	patrol_group = pg
	_FindFirstPatrolPoint()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	super._ready()
	_FindFirstPatrolPoint()


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _DisconnectActor() -> void:
	if actor == null: return
	super._DisconnectActor()
	
	if actor.move_ended.is_connected(_on_actor_move_ended):
		actor.move_ended.disconnect(_on_actor_move_ended)
	if actor.facing_changed.is_connected(_on_actor_facing_changed):
		actor.facing_changed.disconnect(_on_actor_facing_changed)
	if actor.path_completed.is_connected(_on_actor_path_completed):
		actor.path_completed.disconnect(_on_actor_path_completed)
	if actor.path_cleared.is_connected(_on_actor_path_cleared):
		actor.path_cleared.disconnect(_on_actor_path_cleared)

func _ConnectActor() -> void:
	if actor == null: return
	super._ConnectActor()
	
	if not actor.move_ended.is_connected(_on_actor_move_ended):
		actor.move_ended.connect(_on_actor_move_ended)
	if not actor.facing_changed.is_connected(_on_actor_facing_changed):
		actor.facing_changed.connect(_on_actor_facing_changed)
	if not actor.path_completed.is_connected(_on_actor_path_completed):
		actor.path_completed.connect(_on_actor_path_completed)
	if not actor.path_cleared.is_connected(_on_actor_path_cleared):
		actor.path_cleared.connect(_on_actor_path_cleared)

func _FindFirstPatrolPoint() -> void:
	if actor == null: return
	_target_point = null
	actor.cancel_path()
	
	if patrol_group == &"": return
	var dst_point : PatrolPoint = null
	var min_dist : float = 0.0
	
	var points : Array[Node] = get_tree().get_nodes_in_group(patrol_group)
	for point : Node in points:
		if not point is PatrolPoint: continue
		var dist : float = point.global_position.distance_squared_to(actor.global_position)
		if dst_point == null or dist < min_dist:
			dst_point = point
			min_dist = dist
	
	_target_point = dst_point

func _FindEnemy() -> Actor:
	var actors : Array[Actor] = actor.get_visible_actors()
	for a : Actor in actors:
		if a == actor: continue
		if a is Parasite:
			return a
		elif a is Human and a.is_in_group(Settings.ACTOR_GROUP_PLAYER):
			return a
	return null

func _IsActorAlive() -> bool:
	if not actor is Human: return false
	return actor.is_alive()

func _EndAction() -> void:
	action_complete.emit()

# ------------------------------------------------------------------------------
# "Virtual" Public Methods
# ------------------------------------------------------------------------------
func action() -> void:
	if actor == null:
		_EndAction.call_deferred()
		return
	if not _IsActorAlive() or actor.is_in_group(Settings.ACTOR_GROUP_PLAYER):
		_EndAction.call_deferred()
		return
	
	if not actor.has_path() and _target_point != null:
		actor.set_path_to(_target_point.global_position)
	
	if actor.has_path():
		var dir : Actor.DIRECTION = actor.direction_to_path()
		if dir < Actor.DIRECTION.Max:
			actor.move(dir)
		else:
			actor.cancel_path()
	else:
		_EndAction.call_deferred()


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_move_started(dir : int) -> void:
	pass
	#if [Actor.DIRECTION.North, Actor.DIRECTION.South, Actor.DIRECTION.East, Actor.DIRECTION.West].find(dir) >= 0:
		#_facing = dir

func _on_actor_move_ended() -> void:
	if actor != null:
		var next : bool = true
		
		var enemy : Actor = _FindEnemy()
		if enemy != null:
			if enemy.has_method(&"attack"):
				enemy.attack()
				next = false
				
		if next and actor.has_path():
			actor.next_path_point()
	
	_EndAction.call_deferred()

func _on_actor_facing_changed() -> void:
	var enemy : Actor = _FindEnemy()
	if enemy != null:
		if enemy.has_method(&"attack"):
			enemy.attack()
	
	_EndAction.call_deferred()

func _on_actor_path_completed() -> void:
	if _target_point != null and _target_point.next_point != null:
		_target_point = _target_point.next_point

func _on_actor_path_cleared() -> void:
	_EndAction.call_deferred()
