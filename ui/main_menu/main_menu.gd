extends UIControl

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Main Menu")
@export var options_menu_name : StringName = &""

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


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------

func _on_btn_start_pressed() -> void:
	request(UILayer.REQUEST_START_GAME)

func _on_btn_options_pressed() -> void:
	if options_menu_name == &"": return
	request(UILayer.REQUEST_SHOW_UI, {"ui_name":options_menu_name})

func _on_btn_quit_pressed() -> void:
	request(UILayer.REQUEST_SHOW_UI, {
		"ui_name":&"DialogConfirm",
		"ui_data":{
			"yes_action": UILayer.REQUEST_QUIT_APPLICATION,
			"title": "Quit Game",
			"content": "Are you sure you want to quit the game?"
		}
	})
	#request(UILayer.REQUEST_QUIT_APPLICATION)
