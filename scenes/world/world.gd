extends Node2D

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const MAIN_MENU : StringName = &"MainMenu"
const PAUSE_MENU : StringName = &"PauseMenu"

const INITIAL_LEVEL : String = "res://scenes/level_001/level_001.tscn"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Game World")
@export var ui : UILayer = null:					set = set_ui

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _active_level_src : String = ""
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
		if _active_level != null:
			if get_tree().paused:
				get_tree().paused = false
				ui.close_all()
			else:
				get_tree().paused = true
				ui.show_ui(PAUSE_MENU)
		else:
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
	
	if _active_level.requested.is_connected(_on_requested):
		_active_level.requested.disconnect(_on_requested)
	
	remove_child(_active_level)
	_active_level.queue_free()
	_active_level = null
	_active_level_src = ""

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
	_active_level_src = level_src
	_active_level.process_mode = Node.PROCESS_MODE_PAUSABLE
	if not _active_level.requested.is_connected(_on_requested):
		_active_level.requested.connect(_on_requested)
	
	add_child(_active_level)
	
	return OK

func _ReloadLevel() -> int:
	if _active_level_src.is_empty():
		return ERR_UNCONFIGURED
	return _LoadLevel(_active_level_src)

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
		UILayer.REQUEST_TOGGLE_PAUSE:
			get_tree().paused = not get_tree().paused
		UILayer.REQUEST_START_GAME:
			if _active_level != null: return # Don't start a new game if we're running one.
			if _LoadLevel(INITIAL_LEVEL) != OK:
				ui.open_notify_dialog(
					"Level Load Failure",
					"Failed to load the initial level. This is a serious issue.\nHAVE FUN!!",
					UILayer.REQUEST_CLOSE_UI
				)
			else:
				ui.close_all()
				PlayerData.reset()
		UILayer.REQUEST_QUIT_APPLICATION:
			_Quit()
		UILayer.REQUEST_QUIT_TO_MAIN:
			_UnloadActiveLevel()
			ui.close_all()
			ui.show_ui(MAIN_MENU)
		Level.REQUEST_NEXT_LEVEL:
			if Util.Is_Dict_Property_Type(payload, "level_src", TYPE_STRING):
				if _LoadLevel(payload["level_src"]) != OK:
					ui.open_notify_dialog(
						"Level Load Failure",
						"Failed to load the next level.\nNot much to be done now.\nExit to Main Menu and abandon all hope of finishing this game.",
						UILayer.REQUEST_CLOSE_UI
					)
				else:
					PlayerData.start_of_level()
		Level.REQUEST_RESTART_LEVEL:
			var res : int = _ReloadLevel()
			match res:
				OK:
					ui.close_all()
					if get_tree().paused:
						get_tree().paused = false
					PlayerData.reset_snapshot()
				ERR_UNCONFIGURED:
					printerr("Somewhere there is an attempt to reload an unloaded level... ?")
				_:
					ui.open_notify_dialog(
						"Level Load Failure",
						"Failed to load the next level.\nNot much to be done now.\nExit to Main Menu and abandon all hope of finishing this game.",
						UILayer.REQUEST_CLOSE_UI
					)
		Level.REQUEST_GAME_SUCCESS:
			ui.open_notify_dialog(
				"You Succeeded",
				"Nice! You found a way out!\n*Gives a nice pat on the back*",
				UILayer.REQUEST_QUIT_TO_MAIN
			)
		Level.REQUEST_GAME_FAILURE:
			ui.open_notify_dialog(
				"You Failed",
				"Well... You suck...\nBetter luck next time!",
				UILayer.REQUEST_QUIT_TO_MAIN
			)


