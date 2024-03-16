extends Actor
class_name Human

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal dead()

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const HIGHLIGHT_ALTERNATE_TILE_INDEX : int = 3

const ANIM_IDLE : StringName = &"idle"
const ANIM_DEAD : StringName = &"dead"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Human")
@export_range(0, 20) var life : int = 20
@export_range(0, 20) var death_threshold : int = 10

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _asprite_2d : AnimatedSprite2D = $AnimatedSprite2D
@onready var _selection_arrow: Node2D = %SelectionArrow


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	super._ready()
	_UpdateVisionArea()
	_UpdateAnimation()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateVisionArea() -> void:
	if map == null: return
	var sight : Array[Vector2i] = []
	if is_alive():
		sight = compute_sight()
	map.highlight_region(self.name, sight, HIGHLIGHT_ALTERNATE_TILE_INDEX)

	if is_in_group(Settings.ACTOR_GROUP_PLAYER):
		if sight.size() <= 0:
			sight = compute_sight()
		var fow : FOWTileMap = FOWTileMap.Get().get_ref()
		if fow == null: return
		fow.set_region(Settings.FOW_REGION_NAME, sight, 1)

func _UpdateAnimation() -> void:
	if life <= death_threshold:
		_asprite_2d.play(ANIM_DEAD)
	else:
		_asprite_2d.play(ANIM_IDLE)

# ------------------------------------------------------------------------------
# "Virtual" Private Methods
# ------------------------------------------------------------------------------
func _MoveEnded() -> void:
	_selection_arrow.visible = false
	_UpdateVisionArea()

func _TurnEnded() -> void:
	_selection_arrow.visible = false
	_UpdateVisionArea()

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func show_selection() -> void:
	if is_alive():
		_selection_arrow.visible = true

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

func is_alive() -> bool:
	return life > death_threshold

func update_vision() -> void:
	_UpdateVisionArea()

func attack(amount : int = 1) -> int:
	amount = amount if amount <= life else life
	life -= amount
	_selection_arrow.visible = false
	_UpdateAnimation()
	_UpdateVisionArea()
	return amount

func kill() -> void:
	life = 0
	_selection_arrow.visible = false
	_UpdateAnimation()
	_UpdateVisionArea()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------


