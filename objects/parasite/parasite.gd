extends Actor

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const ANIM_IDLE_1 : StringName = &"idle"
const ANIM_IDLE_2 : StringName = &"idle_bounce"
const ANIM_IDLE_3 : StringName = &"idle_look"

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
	move_ended.connect(_on_move_ended)
	_on_move_ended.call_deferred()

func _process(delta: float) -> void:
	if not _tweening:
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
				if possibility < 50.0:
					anim = ANIM_IDLE_2
			_asprite_2d.play(anim)
				
	else:
		_asprite_2d.play(ANIM_IDLE_1)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------


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

func _on_move_ended() -> void:
	var fow : FOWTileMap = FOWTileMap.Get().get_ref()
	if fow == null: return
	fow.set_region(self.name, compute_sight(), 1)

