extends Node2D

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Game World")
@export var ui : UILayer = null:					set = set_ui

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func set_ui(u : UILayer) -> void:
	if u == ui: return
	_DisconnectUI()
	ui = u
	_ConnectUI()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_ConnectUI()
	if Settings.load() != OK:
		Settings.request_reset()
		Settings.save()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_Quit()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _DisconnectUI() -> void:
	if ui == null: return
	if ui.requested.is_connected(_on_requested):
		ui.requested.disconnect(_on_requested)

func _ConnectUI() -> void:
	if ui == null: return
	if not ui.requested.is_connected(_on_requested):
		ui.requested.connect(_on_requested)

func _Quit() -> void:
	if Settings.is_dirty():
		Settings.save()
	get_tree().quit()

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_requested(action : StringName, payload : Dictionary) -> void:
	if ui == null:
		return
	match action:
		UILayer.REQUEST_QUIT_APPLICATION:
			_Quit()
		UILayer.REQUEST_QUIT_TO_MAIN:
			pass


