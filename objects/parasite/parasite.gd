extends Actor
class_name Parasite

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal dead()

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const ANIM_IDLE_1 : StringName = &"idle"
const ANIM_IDLE_2 : StringName = &"idle_bounce"
const ANIM_IDLE_3 : StringName = &"idle_look"
const ANIM_IDLE_4 : StringName = &"idle_blink"

const ANIM_DEAD : StringName = &"dead"

const ANIM_NORTH : StringName = &"north"
const ANIM_SOUTH : StringName = &"south"
const ANIM_EAST : StringName = &"east"
const ANIM_WEST : StringName = &"west"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _alive : bool = true

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _asprite_2d: AnimatedSprite2D = $ASprite2D


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	super._ready()
	move_started.connect(_on_move_started)

func _enter_tree() -> void:
	_MoveEnded.call_deferred()

func _process(delta: float) -> void:
	if not _tweening and _alive:
		_PlayIdle()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _PlayIdle() -> void:
	if _asprite_2d.animation.begins_with("idle"):
		if not _asprite_2d.is_playing():
			var anim : StringName = ANIM_IDLE_1
			var possibility = randf_range(0.0, 1000.0)
			if possibility < 100.0:
				anim = ANIM_IDLE_3
			if possibility < 75.0:
				anim = ANIM_IDLE_4
			if possibility < 50.0:
				anim = ANIM_IDLE_2
			_asprite_2d.play(anim)
				
	else:
		_asprite_2d.play(ANIM_IDLE_1)

# ------------------------------------------------------------------------------
# "Virtual" Private Methods
# ------------------------------------------------------------------------------
func _MoveEnded() -> void:
	var fow : FOWTileMap = FOWTileMap.Get().get_ref()
	if fow == null: return
	fow.set_region(Settings.FOW_REGION_NAME, compute_sight(), 1)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func attack(_amount : int = 1) -> int:
	kill()
	return 1

func kill() -> void:
	_alive = false
	_asprite_2d.play(ANIM_DEAD)
	#queue_free()

func is_alive() -> bool:
	return _alive

func is_dead(fully : bool = false) -> bool:
	if not _alive and fully:
		return not _asprite_2d.is_playing() and _asprite_2d.animation == ANIM_DEAD
	return not _alive

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_move_started(dir : int) -> void:
	match dir:
		Actor.DIRECTION.North:
			_asprite_2d.play(ANIM_NORTH)
		Actor.DIRECTION.South:
			_asprite_2d.play(ANIM_SOUTH)
		Actor.DIRECTION.East:
			_asprite_2d.play(ANIM_EAST)
		Actor.DIRECTION.West:
			_asprite_2d.play(ANIM_WEST)

func _on_a_sprite_2d_animation_finished() -> void:
	if _asprite_2d.animation == ANIM_DEAD:
		dead.emit()
