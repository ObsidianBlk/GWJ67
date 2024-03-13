extends Actor

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
@export_category("Human")
@export var patrol_group : StringName = &""

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
	move_started.connect(_on_move_started)
	move_ended.connect(_on_move_ended)
	_FindFirstPatrolPoint()

#func _physics_process(_delta: float) -> void:
	#if _target_point != null and _path.size() <= 0:
		#move_to(_target_point.global_position)
		#_target_point = _target_point.next_point

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _FindFirstPatrolPoint() -> void:
	_target_point = null
	cancel_path()
	
	if patrol_group == &"": return
	var dst_point : PatrolPoint = null
	var min_dist : float = 0.0
	
	var points : Array[Node] = get_tree().get_nodes_in_group(patrol_group)
	for point : Node in points:
		if not point is PatrolPoint: continue
		var dist : float = point.global_position.distance_squared_to(global_position)
		if dst_point == null or dist < min_dist:
			dst_point = point
			min_dist = dist
	
	_target_point = dst_point


# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func move(dir : Actor.DIRECTION) -> void:
	if map == null or _tweening: return
	var turns : int = get_turns_to_facing(dir)
	if turns != 0:
		# TODO: if turns == 2, then determine which direction to actually turn.
		if turns == 2:
			turns = -1 if randf() < 0.5 else 1
		turn(turns)
		return
	super.move(dir)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_move_started(dir : int) -> void:
	pass
	#if [Actor.DIRECTION.North, Actor.DIRECTION.South, Actor.DIRECTION.East, Actor.DIRECTION.West].find(dir) >= 0:
		#_facing = dir

func _on_move_ended() -> void:
	map.highlight_region(self.name, compute_sight(), HIGHLIGHT_ALTERNATE_TILE_INDEX)


