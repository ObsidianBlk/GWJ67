@tool
extends Node2D
class_name PatrolPoint

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const DRAW_RADIUS : float = 3.0
const NONGROUPED_COLOR : Color = Color.RED
const NEXT_GROUP_MISMATCH_COLOR : Color = Color.TOMATO
const NEXT_GROUP_MATCH_COLOR : Color = Color.WHEAT

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Patrol Point")
@export var group_name : StringName = &"":				set = set_group_name
@export var color : Color = Color.BLUE:					set = set_color
@export var next_point : PatrolPoint = null:			set = set_next_point

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _last_dst_position : Vector2 = Vector2.ZERO
var _groups_match : bool = false

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func set_group_name(gn : StringName) -> void:
	if group_name != &"":
		remove_from_group(group_name)
	group_name = gn
	if group_name != &"":
		add_to_group(group_name)
	queue_redraw()

func set_color(c : Color) -> void:
	if c != color:
		color = c
		queue_redraw()

func set_next_point(p : PatrolPoint) -> void:
	if p == self: return
	if p == next_point: return
	next_point = p
	if next_point != null:
		_last_dst_position = next_point.global_position
	queue_redraw()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	if not Engine.is_editor_hint():
		set_process(false)
		if group_name != &"" and not is_in_group(group_name):
			add_to_group(group_name)

func _draw() -> void:
	if not Engine.is_editor_hint(): return
	if next_point != null:
		var dir : Vector2 = global_position.direction_to(next_point.global_position)
		var dist : float = global_position.distance_to(next_point.global_position)
		if next_point.group_name != group_name:
			draw_line(Vector2.ZERO, dir * dist, NEXT_GROUP_MISMATCH_COLOR, 1, true)
		else:
			draw_line(Vector2.ZERO, dir * dist, NEXT_GROUP_MATCH_COLOR, 1, true)
	draw_circle(Vector2.ZERO, DRAW_RADIUS, color)
	if group_name == &"":
		draw_arc(Vector2.ZERO, DRAW_RADIUS, 0.0, 2*PI, 12, NONGROUPED_COLOR, 1.0)

func _process(_delta: float) -> void:
	if next_point == null: return
	if not next_point.global_position.is_equal_approx(_last_dst_position):
		_last_dst_position = next_point.global_position
		queue_redraw()
	if next_point.group_name != group_name and _groups_match:
		_groups_match = false
		queue_redraw()
	elif next_point.group_name == group_name and not _groups_match:
		_groups_match = true
		queue_redraw()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------



