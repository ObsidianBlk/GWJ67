extends UIControl

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const DEFAULT_TITLEBAR_LABEL : String = "Dialog"
const DEFAULT_CONTENT_LABEL : String = "You have been notified"
const DEFAULT_OK_ACTION : StringName = UILayer.REQUEST_CLOSE_UI

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _ok_action : StringName = &""
var _ok_payload : Dictionary = {}

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _lbl_titlebar: Label = %LBL_Titlebar
@onready var _lbl_content: Label = %LBL_Content
@onready var _btn_ok: Button = %BTN_OK


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _FocusControl() -> void:
	_btn_ok.grab_focus()

# ------------------------------------------------------------------------------
# "Virtual" Private Methods
# ------------------------------------------------------------------------------
func _visibility_updating(data : Dictionary) -> void:
	if not visible:
		_lbl_titlebar.text = DEFAULT_TITLEBAR_LABEL
		_lbl_content.text = DEFAULT_CONTENT_LABEL
		_ok_action = &""
		_ok_payload = {}
		
		if Util.Is_Dict_Property_Type(data, "ok_action", TYPE_STRING_NAME):
			_ok_action = data["ok_action"]
		if Util.Is_Dict_Property_Type(data, "ok_payload", TYPE_DICTIONARY):
			_ok_payload = data["ok_payload"]
		if Util.Is_Dict_Property_Type(data, "title", TYPE_STRING):
			_lbl_titlebar.text = data["title"]
		if Util.Is_Dict_Property_Type(data, "content", TYPE_STRING):
			_lbl_content.text = data["content"]
		
		_FocusControl.call_deferred()

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_btn_ok_pressed() -> void:
	if _ok_action == &"":
		request(DEFAULT_OK_ACTION)
	else:
		request(_ok_action, _ok_payload)
