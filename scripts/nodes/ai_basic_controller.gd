extends ScheduledController
class_name AIBasicController

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const HIGHLIGHT_ALTERNATE_TILE_INDEX : int = 3

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("AI Basic Controller")
@export var patrol_group : StringName = &"":			set = set_patrol_group


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _target_point : PatrolPoint = null

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


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _DisconnectActor() -> void:
	if actor == null: return
		
	if actor.move_ended.is_connected(_on_actor_move_ended):
		actor.move_ended.disconnect(_on_actor_move_ended)

func _ConnectActor() -> void:
	if actor == null: return
	
	if not actor.move_ended.is_connected(_on_actor_move_ended):
		actor.move_ended.connect(_on_actor_move_ended)

func _FindFirstPatrolPoint() -> void:
	if actor == null: return
	_target_point = null
	actor.cancel_movement()
	
	if patrol_group == &"": return
	var dst_point : PatrolPoint = null
	var min_dist : float = 0.0
	
	var points : Array[Node] = get_tree().get_nodes_in_group(actor.patrol_group)
	for point : Node in points:
		if not point is PatrolPoint: continue
		var dist : float = point.global_position.distance_squared_to(actor.global_position)
		if dst_point == null or dist < min_dist:
			dst_point = point
			min_dist = dist
	
	_target_point = dst_point

func _EndAction() -> void:
	action_complete.emit()


# ------------------------------------------------------------------------------
# "Virtual" Public Methods
# ------------------------------------------------------------------------------
func action() -> void:
	pass


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_move_started(dir : int) -> void:
	pass
	#if [Actor.DIRECTION.North, Actor.DIRECTION.South, Actor.DIRECTION.East, Actor.DIRECTION.West].find(dir) >= 0:
		#_facing = dir

func _on_actor_move_ended() -> void:
	_EndAction.call_deferred()
