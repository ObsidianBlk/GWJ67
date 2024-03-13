extends Actor

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const IMMEDIATE_SIGHT_RANGE : int = 1
const HIGHLIGHT_ALTERNATE_TILE_INDEX : int = 3

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Human")
@export var patrol_group : StringName = &""
@export_range(1, 5) var sight_range : int = 3

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _target_point : PatrolPoint = null
var _facing : Actor.DIRECTION = Actor.DIRECTION.North

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
	cancel_movement()
	
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

func _FacingToCardinal() -> ShadowQuadrent.Cardinal:
	match _facing:
		Actor.DIRECTION.East:
			return ShadowQuadrent.Cardinal.EAST
		Actor.DIRECTION.South:
			return ShadowQuadrent.Cardinal.SOUTH
		Actor.DIRECTION.West:
			return ShadowQuadrent.Cardinal.WEST
	return ShadowQuadrent.Cardinal.NORTH

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_move_started(dir : int) -> void:
	if [Actor.DIRECTION.North, Actor.DIRECTION.South, Actor.DIRECTION.East, Actor.DIRECTION.West].find(dir) >= 0:
		_facing = dir

func _on_move_ended() -> void:
	var smap : Shadowmap = Shadowmap.Get().get_ref()
	if smap == null:
		return
	
	var cards : Array[ShadowQuadrent.Cardinal] = [
		ShadowQuadrent.Cardinal.NORTH,
		ShadowQuadrent.Cardinal.EAST,
		ShadowQuadrent.Cardinal.SOUTH,
		ShadowQuadrent.Cardinal.WEST
	]
	var origin : Vector2i = map.local_to_map(global_position)
	var viz : Array[Vector2i] = []
	for d : ShadowQuadrent.Cardinal in cards:
		var q : ShadowQuadrent = ShadowQuadrent.new(origin,d)
		var range : int = IMMEDIATE_SIGHT_RANGE if d != _FacingToCardinal() else sight_range
		viz = smap.compute_fov(q, range, viz)
	
	map.highlight_region(self.name, viz, HIGHLIGHT_ALTERNATE_TILE_INDEX)


