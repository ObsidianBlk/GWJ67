@tool
extends Control

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const PARTICLE_EDGE_BUFFER : float = 0.1

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Blood Bar")
@export var min_value : float = 0.0:			set = set_min_value
@export var max_value : float = 100.0:			set = set_max_value
@export var value : float = 100.0:				set = set_value

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _sub_viewport_container : SubViewportContainer = $SubViewportContainer
@onready var _sub_viewport : SubViewport = $SubViewportContainer/SubViewport
@onready var _particles : GPUParticles2D = $SubViewportContainer/SubViewport/GPUParticles2D


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func set_min_value(v : float) -> void:
	if v <= max_value:
		min_value = v
		if value < min_value:
			value = min_value
		_UpdatePercentage()

func set_max_value(v : float) -> void:
	if v >= min_value:
		max_value = v
		if value > max_value:
			value = max_value
		_UpdatePercentage()

func set_value(v : float) -> void:
	if v < min_value or v > max_value: return
	value = v
	_UpdatePercentage()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_on_viewport_size_changed()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdatePercentage() -> void:
	var diff : float = max_value - min_value
	var percentage : float = 0.0
	if diff > 0.0:
		percentage = (value - min_value) / diff
	_sub_viewport_container.material.set_shader_parameter("percent", percentage)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_viewport_size_changed() -> void:
	if _particles == null or _sub_viewport == null: return
	_particles.process_material.emission_shape_offset = Vector3(
		float(_sub_viewport.size.x) * PARTICLE_EDGE_BUFFER, 0.0, 0.0
	)
	_particles.process_material.emission_box_extents = Vector3(
		float(_sub_viewport.size.x) * (1.0 - (PARTICLE_EDGE_BUFFER * 2)),
		1.0,
		1.0
	)
	_particles.position.y = _sub_viewport.size.y
	_particles.restart()
