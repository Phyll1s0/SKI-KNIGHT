extends CanvasLayer
# Minimap — 右上角小地图（升级版）
# 按键由 KeybindManager 管理：显隐 / 放大 / 缩小
# 图标：S=存档  P=传送  E=装备拾取  K=技能拾取  ¥=商店  橙点=敌人

const MINIMAP_ICON_PATH := "res://assets/sprites/ui/minimap_icons.png"
const MINIMAP_ICON_SIZE := Vector2(8.0, 8.0)
const MAP_WIDTH := 180.0
const MAP_HEIGHT := 120.0
const SCALE_MIN := 0.04
const SCALE_MAX := 0.14
const SCALE_STEP := 0.01

var _minimap_scale: float = 0.06
var _player: Node2D = null
var _points: Array[Dictionary] = []
var _enemies: Array[Node2D] = []
var _area_name: String = ""
var _minimap_icon_sheet: Texture2D = null

@onready var panel: Panel = $Panel
@onready var draw_area: Control = $Panel/DrawArea

func _ready() -> void:
	_minimap_icon_sheet = _load_optional_texture(MINIMAP_ICON_PATH)
	draw_area.draw.connect(_on_draw)
	KeybindManager.bindings_changed.connect(_on_bindings_changed)
	call_deferred("_find_nodes")

func _load_optional_texture(path: String) -> Texture2D:
	if path.is_empty():
		return null
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	var absolute_path := ProjectSettings.globalize_path(path)
	if not FileAccess.file_exists(absolute_path):
		return null
	var image := Image.load_from_file(absolute_path)
	if image != null and not image.is_empty():
		return ImageTexture.create_from_image(image)
	return null

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_minimap"):
		panel.visible = not panel.visible
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("minimap_zoom_in"):
		_minimap_scale = minf(_minimap_scale + SCALE_STEP, SCALE_MAX)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("minimap_zoom_out"):
		_minimap_scale = maxf(_minimap_scale - SCALE_STEP, SCALE_MIN)
		get_viewport().set_input_as_handled()

func _find_nodes() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_player = players[0]
	_collect_map_points()
	_collect_enemies()
	_collect_area_name()

func _collect_area_name() -> void:
	var scene := get_tree().current_scene
	_area_name = scene.name if scene else ""

func _collect_enemies() -> void:
	_enemies.clear()
	for node in get_tree().get_nodes_in_group("enemy"):
		if node is Node2D:
			_enemies.append(node as Node2D)

func _collect_map_points() -> void:
	_points.clear()
	for node in get_tree().get_nodes_in_group("savepoint"):
		_points.append({"pos": node.global_position, "color": Color(0.3, 1.0, 0.5, 1.0), "symbol": "S", "icon": 1})
	for node in get_tree().get_nodes_in_group("portal"):
		_points.append({"pos": node.global_position, "color": Color(0.4, 0.6, 1.0, 1.0), "symbol": "P", "icon": 2})
	for node in get_tree().get_nodes_in_group("equipment_pickup"):
		_points.append({"pos": node.global_position, "color": Color(1.0, 0.9, 0.2, 1.0), "symbol": "E"})
	for node in get_tree().get_nodes_in_group("skill_pickup"):
		_points.append({"pos": node.global_position, "color": Color(0.4, 1.0, 1.0, 1.0), "symbol": "K"})
	for node in get_tree().get_nodes_in_group("shop"):
		_points.append({"pos": node.global_position, "color": Color(1.0, 0.78, 0.0, 1.0), "symbol": "¥"})

func _process(_delta: float) -> void:
	draw_area.queue_redraw()

func _on_draw() -> void:
	if not is_instance_valid(_player):
		return

	var origin := _player.global_position
	var cx := MAP_WIDTH * 0.5
	var cy := MAP_HEIGHT * 0.5
	var font: Font = ThemeDB.fallback_font

	draw_area.draw_rect(Rect2(Vector2.ZERO, Vector2(MAP_WIDTH, MAP_HEIGHT)), Color(0.04, 0.05, 0.14, 0.88))

	for enemy: Node2D in _enemies:
		if not is_instance_valid(enemy):
			continue
		var enemy_pos := Vector2(cx, cy) + (enemy.global_position - origin) * _minimap_scale
		if _in_bounds(enemy_pos):
			draw_area.draw_circle(enemy_pos, 2.5, Color(1.0, 0.45, 0.1, 0.75))

	for point: Dictionary in _points:
		var point_pos: Vector2 = Vector2(cx, cy) + (point["pos"] - origin) * _minimap_scale
		if not _in_bounds(point_pos):
			continue
		var tint: Color = point["color"]
		draw_area.draw_circle(point_pos, 6.0, Color(tint.r, tint.g, tint.b, 0.2))
		if point.has("icon") and _minimap_icon_sheet != null:
			_draw_minimap_icon(int(point["icon"]), point_pos)
		else:
			draw_area.draw_circle(point_pos, 4.5, tint)
			var symbol: String = point["symbol"]
			var text_width := font.get_string_size(symbol, HORIZONTAL_ALIGNMENT_LEFT, -1, 9).x
			draw_area.draw_string(font, Vector2(point_pos.x - text_width * 0.5, point_pos.y + 3.5), symbol, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color.BLACK)

	draw_area.draw_circle(Vector2(cx, cy), 5.5, Color(1.0, 1.0, 1.0, 0.25))
	if _minimap_icon_sheet != null:
		_draw_minimap_icon(0, Vector2(cx, cy))
		var facing_tip := 7.0 * _get_player_facing()
		draw_area.draw_colored_polygon(
			PackedVector2Array([
				Vector2(cx + facing_tip, cy),
				Vector2(cx + facing_tip - 4.0 * _get_player_facing(), cy - 3.0),
				Vector2(cx + facing_tip - 4.0 * _get_player_facing(), cy + 3.0)
			]),
			Color(1.0, 1.0, 1.0, 0.85)
		)
	else:
		draw_area.draw_circle(Vector2(cx, cy), 4.5, Color(1.0, 0.25, 0.25, 1.0))
		var facing_x := 8.0 * _get_player_facing()
		draw_area.draw_colored_polygon(
			PackedVector2Array([
				Vector2(cx + facing_x, cy),
				Vector2(cx, cy - 4.0),
				Vector2(cx, cy + 4.0)
			]),
			Color(1.0, 0.6, 0.6, 1.0)
		)

	if _area_name.length() > 0:
		draw_area.draw_string(font, Vector2(5.0, MAP_HEIGHT - 14.0), _area_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.65, 0.85, 1.0, 0.85))

	draw_area.draw_string(font, Vector2(5.0, MAP_HEIGHT - 4.0), _get_help_text(), HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(0.55, 0.55, 0.55, 0.6))
	draw_area.draw_rect(Rect2(Vector2.ZERO, Vector2(MAP_WIDTH, MAP_HEIGHT)), Color(0.5, 0.7, 1.0, 0.7), false, 1.5)

func _draw_minimap_icon(icon_index: int, center: Vector2) -> void:
	var source_rect := Rect2(Vector2(icon_index * MINIMAP_ICON_SIZE.x, 0.0), MINIMAP_ICON_SIZE)
	var target_rect := Rect2(center - MINIMAP_ICON_SIZE * 0.5, MINIMAP_ICON_SIZE)
	draw_area.draw_texture_rect_region(_minimap_icon_sheet, target_rect, source_rect)

func _in_bounds(pos: Vector2) -> bool:
	return pos.x >= 0.0 and pos.x <= MAP_WIDTH and pos.y >= 0.0 and pos.y <= MAP_HEIGHT

func _get_player_facing() -> float:
	if _player and _player.has_method("get"):
		var facing: Variant = _player.get("_facing")
		if facing != null:
			return float(facing)
	return 1.0

func refresh() -> void:
	call_deferred("_find_nodes")

func _get_help_text() -> String:
	return "%s:显隐  %s/%s:缩放" % [
		KeybindManager.get_display_text("toggle_minimap"),
		KeybindManager.get_display_text("minimap_zoom_in"),
		KeybindManager.get_display_text("minimap_zoom_out")
	]

func _on_bindings_changed() -> void:
	draw_area.queue_redraw()
