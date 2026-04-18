extends Node
# SceneManager — Autoload
# 处理地图间切换，黑屏淡入淡出过渡

signal scene_transition_started
signal scene_transition_finished

const FADE_DURATION := 0.35   # 每段淡化时长（秒）
const SAVE_RESPAWN_POINT := "__SAVE_RESPAWN__"
const STORY_QUOTE_DURATION := 5.0
const STORY_QUOTE_FADE_DURATION := 0.45
const STORY_QUOTE_FONT_SIZE := 34
const STORY_QUOTE_GLYPH_SPACING := 2

var _target_scene: String = ""
var _spawn_point_name: String = "DefaultSpawn"
var _is_transitioning: bool = false
var _is_showing_story_quote: bool = false

# 运行时创建的遮罩节点（避免依赖外部 .tscn）
var _overlay: ColorRect = null
var _canvas: CanvasLayer = null
var _story_label: Label = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_canvas = CanvasLayer.new()
	_canvas.layer = 100
	_canvas.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_canvas)

	_overlay = ColorRect.new()
	_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	_overlay.anchor_right  = 1.0
	_overlay.anchor_bottom = 1.0
	_overlay.mouse_filter  = Control.MOUSE_FILTER_IGNORE
	_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	_canvas.add_child(_overlay)

	_story_label = Label.new()
	_story_label.visible = false
	_story_label.anchor_left = 0.5
	_story_label.anchor_top = 0.5
	_story_label.anchor_right = 0.5
	_story_label.anchor_bottom = 0.5
	_story_label.offset_left = -460.0
	_story_label.offset_top = -72.0
	_story_label.offset_right = 460.0
	_story_label.offset_bottom = 72.0
	_story_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_story_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_story_label.autowrap_mode = 3
	_story_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_story_label.process_mode = Node.PROCESS_MODE_ALWAYS
	_story_label.add_theme_color_override("font_color", Color(0.95, 0.97, 1.0, 1.0))
	_story_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.92))
	_story_label.add_theme_constant_override("shadow_offset_x", 2)
	_story_label.add_theme_constant_override("shadow_offset_y", 2)
	_canvas.add_child(_story_label)

func go_to(scene_path: String, spawn_point: String = "DefaultSpawn") -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	_target_scene    = scene_path
	_spawn_point_name = spawn_point
	scene_transition_started.emit()
	await _fade(0.0, 1.0)                         # 淡出 → 黑屏
	get_tree().change_scene_to_file(_target_scene)
	await get_tree().process_frame               # 等新场景的 _ready 执行完
	await get_tree().process_frame
	await _fade(1.0, 0.0)                         # 淡入 → 正常
	_is_transitioning = false
	scene_transition_finished.emit()

# 在场景切换进行中时，可重定向目标（供死亡复活使用）
func redirect_to(scene_path: String, spawn_point: String) -> void:
	_target_scene    = scene_path
	_spawn_point_name = spawn_point

func get_spawn_point_name() -> String:
	return _spawn_point_name

func is_transitioning() -> bool:
	return _is_transitioning

func show_story_quote(text: String, total_duration: float = STORY_QUOTE_DURATION) -> void:
	if _is_transitioning or _is_showing_story_quote:
		return
	var quote_text: String = text.strip_edges()
	if quote_text.is_empty():
		return
	_is_showing_story_quote = true
	var did_pause_tree: bool = not get_tree().paused
	if did_pause_tree:
		get_tree().paused = true
	_story_label.text = quote_text
	_story_label.modulate.a = 0.0
	_story_label.visible = true
	_apply_story_quote_style()
	await _fade(_overlay.color.a, 1.0)
	await _fade_story_label(0.0, 1.0, STORY_QUOTE_FADE_DURATION)
	var hold_duration: float = max(total_duration - (STORY_QUOTE_FADE_DURATION * 2.0), 0.0)
	if hold_duration > 0.0:
		await get_tree().create_timer(hold_duration, true).timeout
	await _fade_story_label(1.0, 0.0, STORY_QUOTE_FADE_DURATION)
	_story_label.visible = false
	await _fade(1.0, 0.0)
	if did_pause_tree:
		get_tree().paused = false
	_is_showing_story_quote = false

# ── 内部 ────────────────────────────────────────────────────────────────

func _fade(from_alpha: float, to_alpha: float) -> void:
	_overlay.color.a = from_alpha
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_overlay, "color:a", to_alpha, FADE_DURATION)
	await tween.finished

func _fade_story_label(from_alpha: float, to_alpha: float, duration: float) -> void:
	_story_label.modulate.a = from_alpha
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_story_label, "modulate:a", to_alpha, duration)
	await tween.finished

func _apply_story_quote_style() -> void:
	_story_label.add_theme_font_size_override("font_size", STORY_QUOTE_FONT_SIZE)
	if ThemeDB.fallback_font == null:
		return
	var spaced_font := FontVariation.new()
	spaced_font.base_font = ThemeDB.fallback_font
	spaced_font.spacing_glyph = STORY_QUOTE_GLYPH_SPACING
	_story_label.add_theme_font_override("font", spaced_font)
