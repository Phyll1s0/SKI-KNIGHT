extends Node2D
class_name BossAttackTelegraph

const _BASE_COLOR := Color(1.0, 0.38, 0.22, 0.95)

var _line: Line2D = null
var _head: Polygon2D = null
var _label: Label = null
var _pulse_time: float = 0.0

func _ready() -> void:
	z_index = 40
	_line = Line2D.new()
	_line.width = 5.0
	_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	_line.default_color = _BASE_COLOR
	add_child(_line)

	_head = Polygon2D.new()
	_head.color = _BASE_COLOR
	add_child(_head)

	_label = Label.new()
	_label.size = Vector2(120.0, 20.0)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.add_theme_font_size_override("font_size", 14)
	_label.add_theme_constant_override("outline_size", 3)
	_label.add_theme_color_override("font_color", Color(1.0, 0.96, 0.9, 1.0))
	_label.add_theme_color_override("font_outline_color", Color(0.14, 0.06, 0.04, 0.95))
	add_child(_label)

	hide_warning()

func _process(delta: float) -> void:
	if not visible:
		return
	_pulse_time += delta * 8.0
	var alpha: float = 0.58 + 0.28 * absf(sin(_pulse_time))
	_line.modulate = Color(1.0, 1.0, 1.0, alpha)
	_head.modulate = Color(1.0, 1.0, 1.0, alpha)
	if _label.visible:
		_label.modulate = Color(1.0, 1.0, 1.0, min(alpha + 0.16, 1.0))

func show_forward(direction: float, length: float, text: String = "", vertical_offset: float = -20.0) -> void:
	var dir: float = signf(direction)
	if is_zero_approx(dir):
		dir = 1.0
	visible = true
	position = Vector2(0.0, vertical_offset)
	var start := Vector2(dir * 18.0, 0.0)
	var end := Vector2(dir * max(length, 28.0), 0.0)
	_line.points = PackedVector2Array([start, end])
	_head.visible = true
	_head.position = end
	_head.scale = Vector2(dir, 1.0)
	_head.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(-12.0, -7.0),
		Vector2(-12.0, 7.0),
	])
	_set_label(text, (start + end) * 0.5 + Vector2(-60.0, -30.0))
	_pulse_time = 0.0

func show_zone(width: float, text: String = "", vertical_offset: float = 0.0) -> void:
	visible = true
	position = Vector2(0.0, vertical_offset)
	var half_width: float = max(width * 0.5, 24.0)
	_line.points = PackedVector2Array([
		Vector2(-half_width, 0.0),
		Vector2(half_width, 0.0),
	])
	_head.visible = false
	_set_label(text, Vector2(-60.0, -30.0))
	_pulse_time = 0.0

func hide_warning() -> void:
	visible = false
	if _line != null:
		_line.points = PackedVector2Array()
	if _head != null:
		_head.visible = false
	if _label != null:
		_label.visible = false

func _set_label(text: String, pos: Vector2) -> void:
	if _label == null:
		return
	_label.text = text
	_label.position = pos
	_label.visible = not text.is_empty()