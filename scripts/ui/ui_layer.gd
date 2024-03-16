extends CanvasLayer
class_name UILayer


# --------------------------------------------------------------------------------------------------
# Signals
# --------------------------------------------------------------------------------------------------
signal requested(action : StringName, payload : Dictionary)
signal active_ui_changed(ui_name : StringName)

# --------------------------------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------------------------------
const REQUEST_SHOW_UI : StringName = &"show_ui"
const REQUEST_CLOSE_UI : StringName = &"close_ui"
const REQUEST_CLOSE_ALL_UI : StringName = &"close_all"

const REQUEST_START_GAME : StringName = &"start_game"
const REQUEST_TOGGLE_PAUSE : StringName = &"toggle_pause"
const REQUEST_QUIT_APPLICATION : StringName = &"quit_application"
const REQUEST_QUIT_TO_MAIN : StringName = &"quit_to_main"

# --------------------------------------------------------------------------------------------------
# Export Variables
# --------------------------------------------------------------------------------------------------
@export_category("UI Layer")
@export var initial_ui : StringName = &""

# --------------------------------------------------------------------------------------------------
# Variables
# --------------------------------------------------------------------------------------------------
var _ui : Dictionary = {}
var _breadcrumbs : Array = []

# --------------------------------------------------------------------------------------------------
# Override Methods
# --------------------------------------------------------------------------------------------------
func _ready() -> void:
	child_entered_tree.connect(_on_child_entered_tree)
	child_exiting_tree.connect(_on_child_exited_tree)
	_ConnectAllChildren()
	show_ui.call_deferred(initial_ui)

# --------------------------------------------------------------------------------------------------
# Private Methods
# --------------------------------------------------------------------------------------------------
func _ConnectAllChildren() -> void:
	for child in get_children():
		_on_child_entered_tree(child)

#func _PropIsType(obj : Dictionary, prop : String, type : int) -> bool:
	#if not obj.is_empty() and prop in obj:
		#return typeof(obj[prop]) == type
	#return false

# --------------------------------------------------------------------------------------------------
# Public Methods
# --------------------------------------------------------------------------------------------------
func has(ui_name : StringName) -> bool:
	for child in get_children():
		if is_instance_of(child, UIControl):
			if child.name == ui_name:
				return true
	return false

func is_showing(ui_name : StringName) -> bool:
	if not ui_name in _ui: return false
	if _breadcrumbs.size() <= 0: return false
	return _breadcrumbs[0] == ui_name

func get_active_ui() -> StringName:
	return &"" if _breadcrumbs.size() <= 0 else _breadcrumbs[0]

func show_ui(ui_name : StringName, data : Dictionary = {}) -> void:
	if not ui_name in _ui: return
	var active : StringName = get_active_ui()
	if ui_name == active: return
	
	_breadcrumbs.push_front(ui_name)
	if active != &"":
		_ui[active].close_ui()
	_ui[ui_name].show_ui(data)
	active_ui_changed.emit(ui_name)

func close_ui() -> void:
	var active : StringName = get_active_ui()
	if active == &"": return
	_ui[active].close_ui()
	_breadcrumbs.pop_front()
	if _breadcrumbs.size() > 0:
		_ui[_breadcrumbs[0]].show_ui()
	active_ui_changed.emit(get_active_ui())
	

func close_all() -> void:
	var active : StringName = get_active_ui()
	if active != &"":
		_ui[active].close_ui()
		_breadcrumbs.clear()
		active_ui_changed.emit(&"")

func open_confirm_dialog(title : String, content : String, action_options : Dictionary = {}) -> void:
	var ui_data : Dictionary = {
		"title":title,
		"content":content
	}
	if Util.Is_Dict_Property_Type(action_options, "yes_action", TYPE_STRING_NAME):
		ui_data["yes_action"] = action_options["yes_action"]
	if Util.Is_Dict_Property_Type(action_options, "yes_payload", TYPE_DICTIONARY):
		ui_data["yes_payload"] = action_options["yes_payload"]
	if Util.Is_Dict_Property_Type(action_options, "no_action", TYPE_STRING_NAME):
		ui_data["no_action"] = action_options["no_action"]
	if Util.Is_Dict_Property_Type(action_options, "no_payload", TYPE_DICTIONARY):
		ui_data["no_payload"] = action_options["no_payload"]
		
	show_ui(&"DialogConfirm", ui_data)


func open_notify_dialog(title : String, content : String, action : StringName, payload : Dictionary = {}) -> void:
	var ui_data : Dictionary = {
		"title":title,
		"content":content,
		"ok_action":action,
		"ok_payload":payload
	}
	show_ui(&"DialogNotify", ui_data)

# --------------------------------------------------------------------------------------------------
# Handler Methods
# --------------------------------------------------------------------------------------------------
func _on_child_entered_tree(child : Node) -> void:
	if is_instance_of(child, UIControl):
		if not child.name in _ui:
			_ui[child.name] = child
			
		if not child.requested.is_connected(_on_requested):
			child.requested.connect(_on_requested)

func _on_child_exited_tree(child : Node) -> void:
	if is_instance_of(child, UIControl):
		if child.name in _ui:
			_ui.erase(child.name)
		var active : StringName = get_active_ui()
		if active != &"":
			_breadcrumbs = _breadcrumbs.filter(func(item): return item != child.name)
			if _breadcrumbs.size() > 0:
				if _breadcrumbs[0] != active:
					_ui[_breadcrumbs[0]].show_ui()
		
		if child.requested.is_connected(_on_requested):
			child.requested.disconnect(_on_requested)

func _on_requested(action : StringName, payload : Dictionary):
	match action:
		REQUEST_SHOW_UI:
			#if _PropIsType(payload, "ui_name", TYPE_STRING_NAME):
			if Util.Is_Dict_Property_Type(payload, "ui_name", TYPE_STRING_NAME):
				var data : Dictionary = {}
				#if _PropIsType(payload, "ui_data", TYPE_DICTIONARY):
				if Util.Is_Dict_Property_Type(payload, "ui_data", TYPE_DICTIONARY):
					data = payload["ui_data"]
				show_ui(payload["ui_name"], data)
		REQUEST_CLOSE_UI:
			close_ui()
		REQUEST_CLOSE_ALL_UI:
			close_all()
		_:
			requested.emit(action, payload)
