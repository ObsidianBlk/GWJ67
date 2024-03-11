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

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Patrol Point")
@export var color : Color = Color.BLUE:					set = set_color
@export var next_point : PatrolPoint = null:			set = set_next_point

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _last_dst_position : Vector2 = Vector2.ZERO

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
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

func _draw() -> void:
	if not Engine.is_editor_hint(): return
	draw_circle(Vector2.ZERO, DRAW_RADIUS, color)
	if next_point != null:
		var dir : Vector2 = global_position.direction_to(next_point.global_position)
		var dist : float = global_position.distance_to(next_point.global_position)
		draw_line(Vector2.ZERO, dir * dist, Color.WHITE, 1, true)

func _process(_delta: float) -> void:
	if next_point == null: return
	if not next_point.global_position.is_equal_approx(_last_dst_position):
		_last_dst_position = next_point.global_position
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



