extends Control

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Backdrop 001")
@export var shake_speed : float = 30.0
@export var shake_strength : float = 60.0
@export var decay_rate : float = 5.0

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _noise_i : float = 0.0
var _strength : float = 0.0
var _para_origin : Vector2 = Vector2.ZERO

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _background: TextureRect = $Background
@onready var _parasite: TextureRect = $Parasite

@onready var rng : RandomNumberGenerator = RandomNumberGenerator.new()
@onready var noise : FastNoiseLite = FastNoiseLite.new()

# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.seed = rng.randi()
	_para_origin = _parasite.position

func _process(delta: float) -> void:
	if _strength <= 0.01:
		_strength = shake_strength
	else:
		_strength = lerp(_strength, 0.0, decay_rate * delta)

	_parasite.position = _para_origin + _GetNoiseOffset(delta)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _GetNoiseOffset(delta : float) -> Vector2:
	_noise_i += delta * shake_speed
	return Vector2(
		noise.get_noise_2d(1, _noise_i) * _strength,
		noise.get_noise_2d(100, _noise_i) * _strength
	)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------



