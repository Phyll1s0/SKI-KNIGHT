extends CanvasLayer

const HP_ICON_PATH := "res://assets/sprites/ui/hp_icon.png"
const EXP_ICON_PATH := "res://assets/sprites/ui/exp_icon.png"
const SKILL_ICON_PATH := "res://assets/sprites/ui/skill_cooldown_icon.png"
const SKILL_COOLDOWN: float = 0.8
const EQUIPMENT_ICON_PATHS := {
	EquipmentManager.Slot.HELMET: {
		1: "res://assets/sprites/equipment/helmet.png",
		"fallback": "盔",
		"name": "头盔"
	},
	EquipmentManager.Slot.GOGGLES: {
		1: "res://assets/sprites/equipment/goggles_1.png",
		2: "res://assets/sprites/equipment/goggles_2.png",
		"fallback": "镜",
		"name": "雪镜"
	},
	EquipmentManager.Slot.SNOWBOARD: {
		1: "res://assets/sprites/equipment/snowboard_upgrade.png",
		"fallback": "板",
		"name": "雪板"
	},
	EquipmentManager.Slot.SUIT: {
		1: "res://assets/sprites/equipment/suit.png",
		"fallback": "服",
		"name": "雪服"
	}
}

@onready var hp_bar: ProgressBar = $MarginContainer/VBox/HPRow/HPBarWrap/HPBar
@onready var hp_label: Label = $MarginContainer/VBox/HPRow/HPLabelWrap/HPLabel
@onready var hp_icon: TextureRect = $MarginContainer/VBox/HPRow/HPIcon/Texture
@onready var hp_icon_fallback: Label = $MarginContainer/VBox/HPRow/HPIcon/Fallback
@onready var exp_bar: ProgressBar = $MarginContainer/VBox/EXPRow/EXPBarWrap/EXPBar
@onready var level_label: Label = $MarginContainer/VBox/EXPRow/LevelLabelWrap/LevelLabel
@onready var exp_icon: TextureRect = $MarginContainer/VBox/EXPRow/EXPIcon/Texture
@onready var exp_icon_fallback: Label = $MarginContainer/VBox/EXPRow/EXPIcon/Fallback
@onready var skill_bar: ProgressBar = $MarginContainer/VBox/SkillRow/SkillBarWrap/SkillCooldownBar
@onready var skill_slot: PanelContainer = $MarginContainer/VBox/SkillRow/SkillSlot
@onready var skill_icon: TextureRect = $MarginContainer/VBox/SkillRow/SkillSlot/SkillIcon
@onready var skill_icon_fallback: Label = $MarginContainer/VBox/SkillRow/SkillSlot/Fallback
@onready var skill_label: Label = $MarginContainer/VBox/SkillRow/SkillLabel
@onready var gold_label: Label = $MarginContainer/VBox/GoldRow/GoldLabel
@onready var debug_label: Label = $DebugLabel
@onready var respawn_label: Label = $RespawnLabel

var _player: CharacterBody2D = null
var _equipment_ui: Dictionary = {}

func _ready() -> void:
	print("[HUD] _ready start")
	GameManager.hp_changed.connect(_on_hp_changed)
	GameManager.exp_changed.connect(_on_exp_changed)
	GameManager.level_up.connect(_on_level_up)
	GameManager.gold_changed.connect(_on_gold_changed)
	GameManager.evolved.connect(_on_evolved)
	EquipmentManager.equipment_changed.connect(_on_equipment_changed)
	KeybindManager.bindings_changed.connect(_refresh_action_labels)

	_setup_equipment_ui()
	_apply_static_icons()
	_refresh_equipment_ui()
	_refresh_action_labels()
	_refresh_skill_ui(0.0)
	_on_hp_changed(GameManager.player_hp, GameManager.player_max_hp)
	_on_exp_changed(GameManager.player_exp, GameManager.exp_needed_for_next_level())
	_refresh_level_label()
	gold_label.text = str(GameManager.gold)

	print("[HUD] ready done")
	call_deferred("_find_player")

func _setup_equipment_ui() -> void:
	_equipment_ui = {
		EquipmentManager.Slot.HELMET: {
			"panel": $MarginContainer/VBox/EquipmentRow/HelmetSlot,
			"icon": $MarginContainer/VBox/EquipmentRow/HelmetSlot/Icon,
			"fallback": $MarginContainer/VBox/EquipmentRow/HelmetSlot/Fallback,
			"level": $MarginContainer/VBox/EquipmentRow/HelmetSlot/LevelLabel
		},
		EquipmentManager.Slot.GOGGLES: {
			"panel": $MarginContainer/VBox/EquipmentRow/GogglesSlot,
			"icon": $MarginContainer/VBox/EquipmentRow/GogglesSlot/Icon,
			"fallback": $MarginContainer/VBox/EquipmentRow/GogglesSlot/Fallback,
			"level": $MarginContainer/VBox/EquipmentRow/GogglesSlot/LevelLabel
		},
		EquipmentManager.Slot.SNOWBOARD: {
			"panel": $MarginContainer/VBox/EquipmentRow/SnowboardSlot,
			"icon": $MarginContainer/VBox/EquipmentRow/SnowboardSlot/Icon,
			"fallback": $MarginContainer/VBox/EquipmentRow/SnowboardSlot/Fallback,
			"level": $MarginContainer/VBox/EquipmentRow/SnowboardSlot/LevelLabel
		},
		EquipmentManager.Slot.SUIT: {
			"panel": $MarginContainer/VBox/EquipmentRow/SuitSlot,
			"icon": $MarginContainer/VBox/EquipmentRow/SuitSlot/Icon,
			"fallback": $MarginContainer/VBox/EquipmentRow/SuitSlot/Fallback,
			"level": $MarginContainer/VBox/EquipmentRow/SuitSlot/LevelLabel
		}
	}

func _apply_static_icons() -> void:
	_set_optional_icon(hp_icon, hp_icon_fallback, HP_ICON_PATH, "HP")
	_set_optional_icon(exp_icon, exp_icon_fallback, EXP_ICON_PATH, "XP")
	_set_optional_icon(skill_icon, skill_icon_fallback, SKILL_ICON_PATH, "K")

func _set_optional_icon(target: TextureRect, fallback: Label, path: String, fallback_text: String) -> void:
	fallback.text = fallback_text
	var texture := _load_optional_texture(path)
	target.texture = texture
	fallback.visible = texture == null

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

func _refresh_equipment_ui() -> void:
	for slot: int in _equipment_ui.keys():
		var node_set: Dictionary = _equipment_ui[slot]
		var panel: PanelContainer = node_set["panel"]
		var icon: TextureRect = node_set["icon"]
		var fallback: Label = node_set["fallback"]
		var level_label: Label = node_set["level"]
		var level: int = EquipmentManager.equipment_level.get(slot, 0)
		var icon_path := _get_equipment_icon_path(slot, level)
		var meta: Dictionary = EQUIPMENT_ICON_PATHS.get(slot, {})
		var texture := _load_optional_texture(icon_path)
		icon.texture = texture
		fallback.text = meta.get("fallback", "?")
		fallback.visible = texture == null
		level_label.visible = level > 1
		level_label.text = str(level)
		var is_active := level > 0
		panel.modulate = Color(1.0, 1.0, 1.0, 1.0) if is_active else Color(0.78, 0.84, 0.94, 0.74)
		icon.modulate = Color(1.0, 1.0, 1.0, 1.0) if is_active else Color(0.86, 0.9, 0.98, 0.72)
		fallback.modulate = Color(1.0, 1.0, 1.0, 1.0) if is_active else Color(0.8, 0.86, 0.96, 0.82)
		var item_name: String = meta.get("name", "装备")
		panel.tooltip_text = "%s Lv.%d" % [item_name, level] if is_active else "%s 未获得" % item_name

func _refresh_skill_ui(skill_timer: float) -> void:
	skill_bar.value = clampf(1.0 - skill_timer / SKILL_COOLDOWN, 0.0, 1.0)
	var unlocked := GameManager.has_ice_blade
	skill_slot.modulate = Color(1.0, 1.0, 1.0, 1.0) if unlocked else Color(0.82, 0.88, 0.97, 0.76)
	skill_icon.modulate = Color(1.0, 1.0, 1.0, 1.0) if unlocked else Color(0.9, 0.94, 1.0, 0.8)
	skill_icon_fallback.modulate = Color(1.0, 1.0, 1.0, 1.0) if unlocked else Color(0.82, 0.88, 1.0, 0.82)
	skill_label.modulate = Color(0.5, 0.85, 1.0, 1.0) if unlocked else Color(0.72, 0.8, 0.92, 0.9)
	skill_bar.modulate = Color(1.0, 1.0, 1.0, 1.0) if unlocked else Color(0.74, 0.82, 0.94, 0.72)

func _refresh_action_labels() -> void:
	skill_label.text = "[%s]冰刃" % KeybindManager.get_display_text("skill")

func _get_equipment_icon_path(slot: int, level: int) -> String:
	var meta: Dictionary = EQUIPMENT_ICON_PATHS.get(slot, {})
	if slot == EquipmentManager.Slot.GOGGLES and level >= 2:
		return meta.get(2, meta.get(1, ""))
	return meta.get(1, "")

func _process(_delta: float) -> void:
	_update_debug()

func _find_player() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_player = players[0]
		debug_label.text = "坐标调试已开启"
		_player.respawn_countdown.connect(_on_respawn_countdown)
		_player.respawned.connect(_on_respawned)
	else:
		debug_label.text = "坐标调试: 未找到玩家"

func _update_debug() -> void:
	if not is_instance_valid(_player):
		debug_label.text = "坐标调试: 未找到玩家"
		return
	var scene: Node = get_tree().current_scene
	var scene_name: String = scene.name if scene != null else "Unknown"
	var pos: Vector2 = _player.global_position
	var msg: String = "场景=%s  玩家=(%d, %d)  vx=%d  floor=%s" % [
		scene_name,
		int(round(pos.x)),
		int(round(pos.y)),
		int(round(_player.velocity.x)),
		str(_player.is_on_floor())
	]
	if scene_name == "GlacierMaze":
		msg += "\n右下存档=(3086,836)  商人=(3040,860)  坡起点=(3080,840)"
		msg += "\n中转台=(3240,550)  上层存档=(3320,140)"
		msg += "\n从右下补给点往右上爬第一段，再沿第二段往左上"
	debug_label.text = msg
	var raw: Variant = _player.get("_skill_timer")
	var st: float = float(raw) if raw != null else 0.0
	_refresh_skill_ui(st)

func _on_hp_changed(current: int, maximum: int) -> void:
	hp_bar.max_value = maximum
	hp_bar.value = current
	hp_label.text = "%d / %d" % [current, maximum]

func _on_exp_changed(current: int, _needed: int) -> void:
	var cap := GameManager._get_level_cap()
	if GameManager.player_level >= cap:
		exp_bar.max_value = 1
		exp_bar.value = 1
		exp_bar.modulate = Color(0.5, 0.5, 0.6, 1.0)
	else:
		var lv := GameManager.player_level
		var prev: int = GameManager.EXP_TABLE[max(lv - 1, 0)]
		var next: int = GameManager.EXP_TABLE[lv]
		exp_bar.max_value = max(next - prev, 1)
		exp_bar.value = current - prev
		exp_bar.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _refresh_level_label() -> void:
	var cap := GameManager._get_level_cap()
	if GameManager.player_level >= cap:
		level_label.text = "Lv.%d" % GameManager.player_level
		level_label.modulate = Color(1.0, 0.8, 0.2, 1.0)
	else:
		level_label.text = "Lv.%d" % GameManager.player_level
		level_label.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _on_level_up(_new_level: int) -> void:
	_refresh_level_label()
	var tween := create_tween()
	tween.tween_property(level_label, "modulate", Color(1, 1, 0), 0.15)
	tween.tween_interval(0.2)
	tween.tween_callback(_refresh_level_label)

func _on_evolved(_evo_count: int) -> void:
	_refresh_level_label()
	_on_exp_changed(GameManager.player_exp, GameManager.exp_needed_for_next_level())
	var tween := create_tween()
	tween.tween_property(level_label, "modulate", Color(0.4, 0.8, 1.0), 0.2)
	tween.tween_interval(0.3)
	tween.tween_callback(_refresh_level_label)

func _on_respawn_countdown(seconds_left: int) -> void:
	respawn_label.text = "死亡— %d 秒后复活" % seconds_left

func _on_respawned() -> void:
	respawn_label.text = ""

func _on_gold_changed(amount: int) -> void:
	gold_label.text = str(amount)
	var tween := create_tween()
	tween.tween_property(gold_label, "modulate", Color(1.5, 1.3, 0.2, 1.0), 0.1)
	tween.tween_property(gold_label, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.3)

func _on_equipment_changed(_slot: int, _level: int) -> void:
	_refresh_equipment_ui()
