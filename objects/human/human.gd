extends Actor
class_name Human

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

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------

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
	_UpdateVisionArea()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateVisionArea() -> void:
	if map == null: return
	map.highlight_region(self.name, compute_sight(), HIGHLIGHT_ALTERNATE_TILE_INDEX)

# ------------------------------------------------------------------------------
# "Virtual" Private Methods
# ------------------------------------------------------------------------------
func _MoveEnded() -> void:
	_UpdateVisionArea()

func _TurnEnded() -> void:
	_UpdateVisionArea()

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
#func _on_move_started(dir : int) -> void:
	#pass
	##if [Actor.DIRECTION.North, Actor.DIRECTION.South, Actor.DIRECTION.East, Actor.DIRECTION.West].find(dir) >= 0:
		##_facing = dir
#
#func _on_move_ended() -> void:
	#_UpdateVisionArea()
#
#func _on_facing_changed() -> void:
	#_UpdateVisionArea()

