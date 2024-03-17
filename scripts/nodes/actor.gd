extends Node2D
class_name Actor

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal move_started(direction : int)
signal move_ended()
signal facing_changed()

signal path_updated()
signal path_cleared()
signal path_completed()

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
enum DIRECTION {North=0, East=1, South=2, West=3, Max=4}
const WALK_DURATION : float = 0.5

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Actor")
@export var map : AStarTileMap = null
@export var initial_facing : DIRECTION = DIRECTION.North
@export var hidden_in_fow : bool = true
@export var blocking : bool = true
@export_subgroup("Sight Range")
@export_range(0, 10) var sight_foreward : int = 3
@export_range(0, 10) var sight_backward : int = 3
@export_range(0, 10) var sight_left : int = 3
@export_range(0, 10) var sight_right : int = 3

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _path : PackedVector2Array = []
var _tweening : bool = false

var _facing : DIRECTION = DIRECTION.North
var _sight : Array[Vector2i] = []

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func set_map(m : AStarTileMap) -> void:
	if m != map:
		_DisconnectMap()
		map = m
		_ConnectMap()
		_AlignToMap()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_facing = initial_facing
	_ConnectMap()
	_AlignToMap()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _DisconnectMap() -> void:
	if map == null: return
	if map.astar_changed.is_connected(_on_map_astar_changed):
		map.astar_changed.disconnect(_on_map_astar_changed)

func _ConnectMap() -> void:
	if map == null: return
	if not map.astar_changed.is_connected(_on_map_astar_changed):
		map.astar_changed.connect(_on_map_astar_changed)

func _GetSightFromCardinal(cardinal : ShadowQuadrent.Cardinal, only_facing : bool = false) -> int:
	var ranges : Array[int] = [sight_foreward, sight_right, sight_backward, sight_left]
	var foffset : int = _facing
	
	match cardinal:
		ShadowQuadrent.Cardinal.NORTH:
			match _facing:
				DIRECTION.North:
					return sight_foreward
				DIRECTION.East:
					return sight_left if not only_facing else 0
				DIRECTION.South:
					return sight_backward if not only_facing else 0
				DIRECTION.West:
					return sight_right if not only_facing else 0
		ShadowQuadrent.Cardinal.EAST:
			match _facing:
				DIRECTION.North:
					return sight_right if not only_facing else 0
				DIRECTION.East:
					return sight_foreward
				DIRECTION.South:
					return sight_left if not only_facing else 0
				DIRECTION.West:
					return sight_backward if not only_facing else 0
		ShadowQuadrent.Cardinal.SOUTH:
			match _facing:
				DIRECTION.North:
					return sight_backward if not only_facing else 0
				DIRECTION.East:
					return sight_left if not only_facing else 0
				DIRECTION.South:
					return sight_foreward
				DIRECTION.West:
					return sight_right if not only_facing else 0
		ShadowQuadrent.Cardinal.WEST:
			match _facing:
				DIRECTION.North:
					return sight_right if not only_facing else 0
				DIRECTION.East:
					return sight_backward if not only_facing else 0
				DIRECTION.South:
					return sight_left if not only_facing else 0
				DIRECTION.West:
					return sight_foreward
	
	return ranges[foffset]

func _DirectionToVector(dir : DIRECTION) -> Vector2i:
	match dir:
		DIRECTION.North:
			return Vector2i.UP
		DIRECTION.East:
			return Vector2i.RIGHT
		DIRECTION.South:
			return Vector2i.DOWN
		DIRECTION.West:
			return Vector2i.LEFT
	return Vector2i.ZERO

func _VectorToDirection(v : Vector2i) -> DIRECTION:
	if v.x == 0:
		if v.y > 0:
			return DIRECTION.South
		return DIRECTION.North
	elif v.y == 0:
		if v.x > 0:
			return DIRECTION.East
		return DIRECTION.West
	return DIRECTION.Max


func _AlignToMap() -> void:
	if map == null: return
	var map_position = map.local_to_map(global_position)
	global_position = map.map_to_local(map_position)

func _EmitMovementDirection(map_to : Vector2i) -> void:
	if map == null: return
	var map_from : Vector2i = map.local_to_map(global_position)
	var dir : Vector2i = map_to - map_from
	
	if dir.x < 0:
		move_started.emit(DIRECTION.West)
	elif dir.x > 0:
		move_started.emit(DIRECTION.East)
	elif dir.y < 0:
		move_started.emit(DIRECTION.North)
	elif dir.y > 0:
		move_started.emit(DIRECTION.South)

func _IsVisibleAt(cell : Vector2i) -> bool:
	var fow : FOWTileMap = FOWTileMap.Get().get_ref()
	if fow == null: return false
	return fow.cell_in_region(cell)

func _TweenTo(to : Vector2) -> void:
	if map == null or _tweening: return
	_tweening = true
	
	var map_cell : Vector2i = map.local_to_map(to)
	_EmitMovementDirection(map_cell)
	
	if hidden_in_fow:
		if not visible and _IsVisibleAt(map_cell):
			visible = true
	
	if visible:
		var tween : Tween = create_tween()
		tween.tween_property(self, "position", to, WALK_DURATION)
		
		await tween.finished
	else:
		global_position = to
	
	_tweening = false
	_AlignToMap()
	
	if hidden_in_fow:
		if visible and not _IsVisibleAt(map.local_to_map(global_position)):
			visible = false
	
	_MoveEnded()
	move_ended.emit()

# ------------------------------------------------------------------------------
# "Virtual" Private Methods
# ------------------------------------------------------------------------------
func _MoveEnded() -> void:
	pass

func _TurnEnded() -> void:
	pass

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func is_facing_position(pos : Vector2) -> bool:
	if map == null: return false
	var from : Vector2i = map.local_to_map(global_position)
	var to : Vector2i = map.local_to_map(pos)
	var dir : DIRECTION = _VectorToDirection(from - to)
	if dir != DIRECTION.Max:
		return dir == _facing
	return false

func get_turns_to_facing(facing : DIRECTION) -> int:
	var cfv : Vector2i = _DirectionToVector(_facing)
	var tfv : Vector2i = _DirectionToVector(facing)
	if cfv != tfv:
		if cfv + tfv == Vector2i.ZERO:
			return 2
		if cfv.x != 0:
			if cfv.x < 0:
				return 1 if tfv.y < 0 else -1
			return -1 if tfv.y < 0 else 1
		else:
			if cfv.y < 0:
				return 1 if tfv.x > 0 else -1
			return -1 if tfv.x > 0 else 1
	return 0

func turn(dir : int) -> void:
	# <0 = Left | >0 = Right
	if dir == 0: return
	
	match _facing:
		DIRECTION.North:
			_facing = DIRECTION.West if dir < 0 else DIRECTION.East
		DIRECTION.South:
			_facing = DIRECTION.East if dir < 0 else DIRECTION.West
		DIRECTION.East:
			_facing = DIRECTION.North if dir < 0 else DIRECTION.South
		DIRECTION.West:
			_facing = DIRECTION.South if dir < 0 else DIRECTION.North
	
	_TurnEnded()
	facing_changed.emit()

func can_move(d : DIRECTION) -> bool:
	if map != null:
		var mappos : Vector2i = map.local_to_map(global_position) + _DirectionToVector(d)
		return not map.is_point_solid(mappos)
	return false

func move(d : DIRECTION) -> void:
	if map == null: return
	if _tweening:
		#_queue["move"] = d
		return
	
	var mappos : Vector2i = map.local_to_map(global_position) + _DirectionToVector(d)
	if not map.is_point_solid(mappos):
		_TweenTo(map.map_to_local(mappos))
	else:
		_MoveEnded()
		move_ended.emit()

func set_path_to(to : Vector2) -> void:
	if map == null: return
	if map.can_move_to(to):
		_path = map.get_point_path(global_position, to)
		path_updated.emit()

func has_path() -> bool:
	return _path.size() > 0

func peek_path() -> Vector2i:
	if _path.size() <= 0: return Vector2i.ZERO
	return _path[0]

func next_path_point() -> void:
	if _path.size() > 0:
		_path = _path.slice(1)
		if _path.size() <= 0:
			path_completed.emit()

func direction_to_path() -> DIRECTION:
	if map == null or _path.size() <= 0: return DIRECTION.Max
	var from : Vector2i = map.local_to_map(global_position)
	var to : Vector2i = _path[0]
	return _VectorToDirection(to - from)

func cancel_path() -> void:
	_path.clear()
	path_cleared.emit()

func compute_sight(only_facing : bool = false) -> Array[Vector2i]:
	if map == null: return []
	
	var smap : Shadowmap = Shadowmap.Get().get_ref()
	if smap == null: return []
	
	_sight.clear()
	var cards : Array[ShadowQuadrent.Cardinal] = [
		ShadowQuadrent.Cardinal.NORTH,
		ShadowQuadrent.Cardinal.EAST,
		ShadowQuadrent.Cardinal.SOUTH,
		ShadowQuadrent.Cardinal.WEST
	]
	var origin : Vector2i = map.local_to_map(global_position)
	for d : ShadowQuadrent.Cardinal in cards:
		var q : ShadowQuadrent = ShadowQuadrent.new(origin,d)
		var sight_range : int = _GetSightFromCardinal(d, only_facing)
		_sight = smap.compute_fov(q, sight_range, _sight)
	return _sight.slice(0)

func get_sight_map() -> Array[Vector2i]:
	return _sight.slice(0)

func get_visible_actors() -> Array[Actor]:
	if map == null or _sight.size() <= 0: return []
	return map.get_actors_in_region(_sight)

func get_adjacent_actor(dir : DIRECTION) -> Actor:
	if map == null: return null
	var mpos : Vector2i = map.local_to_map(global_position)
	
	match dir:
		DIRECTION.North:
			return map.get_actor_in_cell(mpos + Vector2i.UP)
		DIRECTION.East:
			return map.get_actor_in_cell(mpos + Vector2i.RIGHT)
		DIRECTION.South:
			return map.get_actor_in_cell(mpos + Vector2i.DOWN)
		DIRECTION.West:
			return map.get_actor_in_cell(mpos + Vector2i.LEFT)
	
	return null

func get_nb_actors() -> Array[Actor]:
	if map == null: return []
	var mpos : Vector2i = map.local_to_map(global_position)
	return map.get_nb_actors_in_cell(mpos)

func get_map_position() -> Vector2i:
	if map == null: return Vector2i.ZERO
	return map.local_to_map(global_position)


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_map_astar_changed() -> void:
	cancel_path()


