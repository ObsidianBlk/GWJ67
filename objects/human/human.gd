extends Actor
class_name Human

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal attack_animation_complete()
signal dead()

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const HIGHLIGHT_ALTERNATE_TILE_INDEX : int = 3

const NW_PREFIX : String = "nw_"
const ES_PREFIX : String = "es_"

const ANIM_IDLE : String = "idle"
const ANIM_BREATH : String = "breath"
const ANIM_WALK : String = "walk"
const ANIM_ATTACK : String = "attack"

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
func _GetFacingPrefix() -> String:
	match _facing:
		Actor.DIRECTION.North, Actor.DIRECTION.West:
			return NW_PREFIX
		Actor.DIRECTION.South, Actor.DIRECTION.East:
			return ES_PREFIX
	return ""

func _UpdateFlipState() -> void:
	match _facing:
		Actor.DIRECTION.North, Actor.DIRECTION.East:
			_asprite_2d.flip_h = false
		Actor.DIRECTION.South, Actor.DIRECTION.West:
			_asprite_2d.flip_h = true

func _UpdateVisionArea() -> void:
	if map == null: return
	var is_player : bool = is_in_group(Settings.ACTOR_GROUP_PLAYER)
	var sight : Array[Vector2i] = []
	
	if not is_player:
		if is_alive():
			sight = compute_sight(true)
		map.highlight_region(self.name, sight, HIGHLIGHT_ALTERNATE_TILE_INDEX)

	if is_player:
		map.highlight_region(self.name, [], HIGHLIGHT_ALTERNATE_TILE_INDEX)
		if sight.size() <= 0:
			sight = compute_sight()
		var fow : FOWTileMap = FOWTileMap.Get().get_ref()
		if fow == null: return
		fow.set_region(Settings.FOW_REGION_NAME, sight, 1)

func _UpdateAnimation() -> void:
	if life <= death_threshold:
		_asprite_2d.play(ANIM_DEAD)
	else:
		var anim : String = "%s%s"%[_GetFacingPrefix(), ANIM_IDLE]
		var probability : float = randf() * 1000.0
		if probability < 100:
			anim = "%s%s"%[_GetFacingPrefix(), ANIM_BREATH]
		_asprite_2d.play(anim)
		_UpdateFlipState()

func _PlayMoving() -> void:
	_asprite_2d.play("%s%s"%[_GetFacingPrefix(), ANIM_WALK])
	_UpdateFlipState()

func _PlayAttack() -> void:
	_asprite_2d.play("%s%s"%[_GetFacingPrefix(), ANIM_ATTACK])
	_UpdateFlipState()

# ------------------------------------------------------------------------------
# "Virtual" Private Methods
# ------------------------------------------------------------------------------
func _MoveEnded() -> void:
	_selection_arrow.visible = false
	_UpdateAnimation()
	_UpdateVisionArea()

func _TurnEnded() -> void:
	_selection_arrow.visible = false
	_UpdateAnimation()
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
	_PlayMoving()
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

func play_attack_animation() -> void:
	_PlayAttack()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_map_astar_changed() -> void:
	super._on_map_astar_changed()
	_UpdateVisionArea()

func _on_animated_sprite_2d_animation_finished() -> void:
	if _asprite_2d.animation.ends_with(ANIM_ATTACK):
		attack_animation_complete.emit()
