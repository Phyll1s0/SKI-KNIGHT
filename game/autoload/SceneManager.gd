extends Node
# SceneManager — Autoload
# 处理地图间切换，黑屏淡入淡出过渡

signal scene_transition_started
signal scene_transition_finished

const FADE_DURATION := 0.35   # 每段淡化时长（秒）

var _target_scene: String = ""
var _spawn_point_name: String = "DefaultSpawn"

# 运行时创建的遮罩节点（避免依赖外部 .tscn）
var _overlay: ColorRect = null
var _canvas: CanvasLayer = null

func _ready() -> void:
	_canvas = CanvasLayer.new()
	_canvas.layer = 100
	add_child(_canvas)

	_overlay = ColorRect.new()
	_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	_overlay.anchor_right  = 1.0
	_overlay.anchor_bottom = 1.0
	_overlay.mouse_filter  = Control.MOUSE_FILTER_IGNORE
	_canvas.add_child(_overlay)

func go_to(scene_path: String, spawn_point: String = "DefaultSpawn") -> void:
	_target_scene    = scene_path
	_spawn_point_name = spawn_point
	scene_transition_started.emit()
	await _fade(0.0, 1.0)                         # 淡出 → 黑屏
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame               # 等新场景的 _ready 执行完
	await get_tree().process_frame
	await _fade(1.0, 0.0)                         # 淡入 → 正常
	scene_transition_finished.emit()

func get_spawn_point_name() -> String:
	return _spawn_point_name

# ── 内部 ────────────────────────────────────────────────────────────────

func _fade(from_alpha: float, to_alpha: float) -> void:
	_overlay.color.a = from_alpha
	var tween := create_tween()
	tween.tween_property(_overlay, "color:a", to_alpha, FADE_DURATION)
	await tween.finished
