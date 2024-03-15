extends Node2D

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const INITIAL_LEVEL : String = "res://scenes/level_test/level_test.tscn"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Game World")
@export var ui : UILayer = null:					set = set_ui

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _active_level : Node2D = null

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

func _UnloadActiveLevel() -> void:
	if _active_level == null: return
	remove_child(_active_level)
	_active_level.queue_free()
	_active_level = null

func _LoadLevel(level_src : String) -> int:
	# Load level's PackedScene
	var level_scene : Resource = load(level_src)
	if level_scene == null or not level_scene is PackedScene:
		printerr("Failed to load scene, ", level_src)
		return ERR_FILE_CANT_OPEN
	
	# Instantiate the level scene.
	var level_node : Node2D = level_scene.instantiate()
	if level_node == null or not level_node is Level:
		printerr("Failed to instantiate node or node is not Level type.")
		return ERR_CANT_CREATE
	
	# Unload any current level that may be loaded.
	_UnloadActiveLevel()
	
	# Add the new level node to the scene. We should be off to the races now!
	_active_level = level_node
	_active_level.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(_active_level)
	
	return OK

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
		UILayer.REQUEST_START_GAME:
			if _active_level != null: return # Don't start a new game if we're running one.
			_LoadLevel(INITIAL_LEVEL)
			ui.close_all()
		UILayer.REQUEST_QUIT_APPLICATION:
			_Quit()
		UILayer.REQUEST_QUIT_TO_MAIN:
			pass


