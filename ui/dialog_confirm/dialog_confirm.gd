extends UIControl

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const DEFAULT_OPTION_YES : int = 1
const DEFAULT_OPTION_NO : int = 0
const DEFAULT_TITLEBAR_LABEL : String = "Dialog"
const DEFAULT_CONTENT_LABEL : String = "Are you sure?"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _yes_action : StringName = &""
var _yes_payload : Dictionary = {}

var _no_action : StringName = &""
var _no_payload : Dictionary = {}

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _btn_yes: Button = %BTN_Yes
@onready var _btn_no: Button = %BTN_No
@onready var _lbl_titlebar: Label = %LBL_Titlebar
@onready var _lbl_content: Label = %LBL_Content



# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _FocusDefaultOption(op : int) -> void:
	if [DEFAULT_OPTION_NO, DEFAULT_OPTION_YES].find(op) < 0: return
	match op:
		DEFAULT_OPTION_NO:
			_btn_no.grab_focus()
		DEFAULT_OPTION_YES:
			_btn_yes.grab_focus()

# ------------------------------------------------------------------------------
# "Virtual" Private Methods
# ------------------------------------------------------------------------------
func _visibility_updating(data : Dictionary) -> void:
	if not visible:
		var option : int = DEFAULT_OPTION_NO
		_yes_action = &""
		_yes_payload = {}
		_no_action = &""
		_no_payload = {}
		_lbl_titlebar.text = DEFAULT_TITLEBAR_LABEL
		_lbl_content.text = DEFAULT_CONTENT_LABEL
		
		if Util.Is_Dict_Property_Type(data, "yes_action", TYPE_STRING_NAME):
			_yes_action = data["yes_action"]
		if Util.Is_Dict_Property_Type(data, "yes_payload", TYPE_DICTIONARY):
			_yes_payload = data["yes_payload"]
		if Util.Is_Dict_Property_Type(data, "no_action", TYPE_STRING_NAME):
			_no_action = data["no_action"]
		if Util.Is_Dict_Property_Type(data, "no_payload", TYPE_DICTIONARY):
			_no_payload = data["no_payload"]
		if Util.Is_Dict_Property_Type(data, "title", TYPE_STRING):
			_lbl_titlebar.text = data["title"]
		if Util.Is_Dict_Property_Type(data, "content", TYPE_STRING):
			_lbl_content.text = data["content"]
		if Util.Is_Dict_Property_Type(data, "default_yes", TYPE_BOOL):
			option = DEFAULT_OPTION_YES if data["default_yes"] == true else DEFAULT_OPTION_NO
		_FocusDefaultOption.call_deferred(option)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------

func _on_btn_no_pressed() -> void:
	if _no_action == &"":
		request(UILayer.REQUEST_CLOSE_UI)
	else:
		request(_no_action, _no_payload)

func _on_btn_yes_pressed() -> void:
	if _yes_action == &"": return
	request(_yes_action, _yes_payload)
