extends Node2D
class_name Actor

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal move_started(direction : int)
signal move_ended()

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
enum DIRECTION {North=0, East=1, South=2, West=3}
const WALK_DURATION : float = 0.5

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Actor")
@export var map : AStarTileMap = null
@export var hidden_in_fow : bool = true

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _path : PackedVector2Array = []
var _tweening : bool = false
#var _queue : Dictionary = {}

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
	
	move_ended.emit()
	#if not _queue.is_empty():
		#if typeof(_queue["move"]) == TYPE_VECTOR2:
			#move_to.call_deferred(_queue["move"])
			#_queue.clear()
		#else:
			#move.call_deferred(_queue["move"])
			#_queue.clear()
	#else:
		#_NextPathPoint()

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func move(d : DIRECTION) -> void:
	if map == null: return
	if _tweening:
		#_queue["move"] = d
		return
	
	var mappos : Vector2i = map.local_to_map(global_position)
	match d:
		DIRECTION.North:
			mappos += Vector2i.UP
		DIRECTION.South:
			mappos += Vector2i.DOWN
		DIRECTION.East:
			mappos += Vector2i.RIGHT
		DIRECTION.West:
			mappos += Vector2i.LEFT
	if not map.is_point_solid(mappos):
		_TweenTo(map.map_to_local(mappos))

func move_to(to : Vector2) -> void:
	if map == null: return
	if _tweening:
		#_queue["move"] = to
		return
	
	if map.can_move_to(to):
		_path = map.get_point_path(global_position, to)
		continue_move()

func continue_move() -> void:
	if map == null or _path.size() <= 0: return
	var target : Vector2i = _path[0]
	_path = _path.slice(1)
	_TweenTo(map.map_to_local(target))

func is_following_path() -> bool:
	return _path.size() > 0

func cancel_movement() -> void:
	_path.clear()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_map_astar_changed() -> void:
	cancel_movement()


