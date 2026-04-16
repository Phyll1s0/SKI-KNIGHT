extends Control

const CHEAT_KEYWORD := "cheat"
const CHEAT_PASSWORD := "123456"
const CHEAT_BUFFER_LIMIT := 12

@onready var panel: Panel = $Panel
@onready var title_label: Label = $Panel/VBox/Title
@onready var status_label: Label = $Panel/VBox/Status
@onready var input_label: Label = $Panel/VBox/InputLabel
@onready var help_label: Label = $Panel/VBox/Help

var _cheat_buffer: String = ""
var _password_input: String = ""
var _awaiting_password: bool = false
var _developer_enabled: bool = false
var _status_message: String = "在游戏中输入 cheat 以开启开发者模式"
var _undo_snapshot: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_refresh_ui()

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return
	if _awaiting_password:
		_handle_password_input(key_event)
		get_viewport().set_input_as_handled()
		return
	if _developer_enabled and _handle_dev_shortcuts(key_event):
		get_viewport().set_input_as_handled()
		return
	_track_cheat_keyword(key_event)

func _track_cheat_keyword(event: InputEventKey) -> void:
	if event.unicode <= 0:
		return
	var character := String.chr(event.unicode)
	if character.is_empty() or not character.is_valid_identifier():
		return
	_cheat_buffer += character.to_lower()
	if _cheat_buffer.length() > CHEAT_BUFFER_LIMIT:
		_cheat_buffer = _cheat_buffer.right(CHEAT_BUFFER_LIMIT)
	if _cheat_buffer.ends_with(CHEAT_KEYWORD):
		_awaiting_password = true
		_password_input = ""
		_status_message = "请输入密码 123456"
		_refresh_ui()

func _handle_password_input(event: InputEventKey) -> void:
	if event.keycode == KEY_ESCAPE:
		_awaiting_password = false
		_password_input = ""
		_status_message = "已取消开发者模式验证"
		_refresh_ui()
		return
	if event.keycode == KEY_BACKSPACE:
		if not _password_input.is_empty():
			_password_input = _password_input.left(_password_input.length() - 1)
			_refresh_ui()
		return
	if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
		if _password_input == CHEAT_PASSWORD:
			_developer_enabled = true
			_awaiting_password = false
			_status_message = "开发者模式已开启"
		else:
			_awaiting_password = false
			_password_input = ""
			_status_message = "密码错误，重新输入 cheat 可再次验证"
		_refresh_ui()
		return
	if event.unicode <= 0:
		return
	var character := String.chr(event.unicode)
	if character.is_valid_int():
		_password_input += character
		_refresh_ui()

func _handle_dev_shortcuts(event: InputEventKey) -> bool:
	var keycode: int = event.keycode
	if keycode == KEY_F1 or keycode == KEY_T:
		_save_snapshot()
		_teleport_player_to_mouse()
		return true
	if keycode == KEY_F2 or keycode == KEY_G:
		_save_snapshot()
		GameManager.add_gold(500)
		_status_message = "开发者模式：金币 +500"
		_refresh_ui()
		return true
	if keycode == KEY_F3 or keycode == KEY_L:
		_save_snapshot()
		_grant_level_up()
		return true
	if keycode == KEY_F4 or keycode == KEY_U:
		_save_snapshot()
		_apply_full_upgrade()
		return true
	if keycode == KEY_F5 or keycode == KEY_Z:
		_restore_snapshot()
		return true
	return false

func _teleport_player_to_mouse() -> void:
	var player: CharacterBody2D = _get_player()
	if player == null:
		_status_message = "开发者模式：当前场景没有玩家"
		_refresh_ui()
		return
	var camera: Camera2D = get_viewport().get_camera_2d()
	var target_position: Vector2 = camera.get_global_mouse_position() if camera != null else player.get_global_mouse_position()
	player.global_position = target_position
	player.velocity = Vector2.ZERO
	# 不修改 respawn_position/respawn_scene（传送不应该污染复活点数据）
	_status_message = "开发者模式：已传送到 (%.0f, %.0f)" % [target_position.x, target_position.y]
	_refresh_ui()

func _grant_level_up() -> void:
	if GameManager.player_level >= GameManager._get_level_cap() and GameManager.evolution_count < 3:
		GameManager.evolve()
	var next_threshold: int = GameManager.exp_needed_for_next_level()
	if next_threshold <= 0:
		_status_message = "开发者模式：当前已满级"
		_refresh_ui()
		return
	var needed_delta: int = max(next_threshold - GameManager.player_exp, 0)
	GameManager.gain_exp(needed_delta)
	_status_message = "开发者模式：提升到 Lv.%d" % GameManager.player_level
	_refresh_ui()

func _apply_full_upgrade() -> void:
	while GameManager.evolution_count < 3:
		GameManager.evolve()
	while GameManager.exp_needed_for_next_level() > 0:
		var needed_delta: int = max(GameManager.exp_needed_for_next_level() - GameManager.player_exp, 0)
		if needed_delta <= 0:
			break
		GameManager.gain_exp(needed_delta)
	SkillManager.unlock(SkillManager.Skill.ICE_BLADE)
	EquipmentManager.equip(EquipmentManager.Slot.HELMET, 1)
	EquipmentManager.equip(EquipmentManager.Slot.GOGGLES, 2)
	EquipmentManager.equip(EquipmentManager.Slot.SNOWBOARD, 1)
	EquipmentManager.equip(EquipmentManager.Slot.SUIT, 1)
	GameManager.add_gold(2000)
	GameManager.player_hp = GameManager.player_max_hp
	GameManager.hp_changed.emit(GameManager.player_hp, GameManager.player_max_hp)
	_status_message = "开发者模式：已满级、满装、全技能、金币补齐"
	_refresh_ui()

func _save_snapshot() -> void:
	var player: CharacterBody2D = _get_player()
	_undo_snapshot = {
		"player_level":     GameManager.player_level,
		"player_exp":       GameManager.player_exp,
		"player_hp":        GameManager.player_hp,
		"player_max_hp":    GameManager.player_max_hp,
		"evolution_count":  GameManager.evolution_count,
		"gold":             GameManager.gold,
		"has_suit_fragment":GameManager.has_suit_fragment,
		"has_goggles_part": GameManager.has_goggles_part,
		"respawn_position": GameManager.respawn_position,
		"equipment_level":  EquipmentManager.equipment_level.duplicate(),
		"unlocked_level":   EquipmentManager.unlocked_level.duplicate(),
		"unlocked_skills":  SkillManager.unlocked_skills.duplicate(),
		"player_position":  player.global_position if player != null else Vector2.ZERO,
	}

func _restore_snapshot() -> void:
	if _undo_snapshot.is_empty():
		_status_message = "开发者模式：没有可撤销的操作"
		_refresh_ui()
		return
	# GameManager 状态
	GameManager.player_level    = _undo_snapshot["player_level"]
	GameManager.player_exp      = _undo_snapshot["player_exp"]
	GameManager.player_hp       = _undo_snapshot["player_hp"]
	GameManager.player_max_hp   = _undo_snapshot["player_max_hp"]
	GameManager.evolution_count = _undo_snapshot["evolution_count"]
	GameManager.gold            = _undo_snapshot["gold"]
	GameManager.has_suit_fragment = _undo_snapshot["has_suit_fragment"]
	GameManager.has_goggles_part  = _undo_snapshot["has_goggles_part"]
	GameManager.respawn_position  = _undo_snapshot["respawn_position"]
	GameManager.hp_changed.emit(GameManager.player_hp, GameManager.player_max_hp)
	GameManager.exp_changed.emit(GameManager.player_exp, GameManager.exp_needed_for_next_level())
	GameManager.level_up.emit(GameManager.player_level)
	GameManager.gold_changed.emit(GameManager.gold)
	GameManager.evolved.emit(GameManager.evolution_count)
	# 装备状态
	for slot: int in _undo_snapshot["equipment_level"]:
		EquipmentManager.equipment_level[slot] = _undo_snapshot["equipment_level"][slot]
		EquipmentManager.unlocked_level[slot]  = _undo_snapshot["unlocked_level"][slot]
		EquipmentManager.equipment_changed.emit(slot, EquipmentManager.equipment_level[slot])
	# 技能状态
	SkillManager.unlocked_skills = _undo_snapshot["unlocked_skills"].duplicate()
	# 玩家位置
	var player: CharacterBody2D = _get_player()
	if player != null:
		player.global_position = _undo_snapshot["player_position"]
		player.velocity = Vector2.ZERO
	_undo_snapshot = {}
	_status_message = "开发者模式：已撤销上一次操作"
	_refresh_ui()

func _get_player() -> CharacterBody2D:
	var players: Array = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return null
	return players[0] as CharacterBody2D

func _refresh_ui() -> void:
	panel.visible = _developer_enabled or _awaiting_password
	if not panel.visible:
		return
	if _awaiting_password:
		title_label.text = "开发者模式验证"
		status_label.text = _status_message
		input_label.visible = true
		input_label.text = "密码: %s" % "*".repeat(_password_input.length())
		help_label.text = "回车确认，Esc 取消"
		return
	title_label.text = "开发者模式"
	status_label.text = _status_message
	input_label.visible = false
	help_label.text = "F1/T 传送到鼠标位置\nF2/G +500 金币\nF3/L 升 1 级\nF4/U 满级/满装/全技能\nF5/Z 撤销上一次操作"