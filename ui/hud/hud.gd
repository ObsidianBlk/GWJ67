extends CanvasLayer

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("HUD")

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _blood_bar = %BloodBar


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	PlayerData.blood_level_changed.connect(_on_blood_level_changed)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_blood_level_changed(blood_level : int) -> void:
	_blood_bar.value = (float(blood_level) / float(PlayerData.MAX_BLOOD_LEVEL)) * 100.0
