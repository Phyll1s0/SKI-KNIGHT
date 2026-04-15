extends Node

# ── Player persistent data ──────────────────────────────────
var player_max_hp: int = 100
var player_hp: int = 100
var player_exp: int = 0
var player_level: int = 1
var player_attack: int = 20
# 最近激活的重生点（Vector2.ZERO 表示未指定）
var respawn_position: Vector2 = Vector2.ZERO
# Unlocked abilities（兼容旧存档）
var has_double_jump: bool = false
var has_ice_blade: bool = false

# ── 进化系统 ───────────────────────────────────────────────
# evolution_count: 0=初始  1=打败boss1  2=打败boss2  3=打败boss3
# 对应等级上限: 10 / 20 / 30 / 40
var evolution_count: int = 0
const LEVEL_CAPS: Array[int] = [10, 20, 30, 40]

# ── 金币 & 道具碎片 ─────────────────────────────────────────
var gold: int = 0
var has_suit_fragment: bool = false   # Boss1（冰川雪豹）掉落，合成高级雪服需要
var has_goggles_part: bool = false    # Boss2（冻结守卫）掉落，升级雪镜二级需要
var pending_equipment_drops: Array[Dictionary] = []
var death_retry_pending: bool = false

# ── Signals ────────────────────────────────────────────────
signal hp_changed(current: int, maximum: int)
signal exp_changed(current: int, needed: int)
signal level_up(new_level: int)
signal gold_changed(amount: int)
signal evolved(evolution_count: int)
signal game_completed

# ── EXP table: EXP_TABLE[level] = 升到下一级所需累计经验 ───
# 共 40 级，分四段（每10级一个进化门槛）
const EXP_TABLE: Array[int] = [
	0,
	# 1-10
	100, 250, 450, 700, 1000, 1400, 1900, 2500, 3200, 4100,
	# 11-20
	5200, 6500, 8000, 9800, 11800, 14100, 16700, 19600, 22800, 26400,
	# 21-30
	30400, 34800, 39700, 45100, 51000, 57500, 64600, 72400, 80900, 90100,
	# 31-40（上限，无下一级）
	99999999,
]

func _ready() -> void:
	# 注册方向键 / W 键作为备用输入（与 A/D/Space 并行生效）
	var ev_left := InputEventKey.new()
	ev_left.physical_keycode = KEY_LEFT
	InputMap.action_add_event("move_left", ev_left)

	var ev_right := InputEventKey.new()
	ev_right.physical_keycode = KEY_RIGHT
	InputMap.action_add_event("move_right", ev_right)

	var ev_up := InputEventKey.new()
	ev_up.physical_keycode = KEY_UP
	InputMap.action_add_event("jump", ev_up)

	var ev_w := InputEventKey.new()
	ev_w.physical_keycode = KEY_W
	InputMap.action_add_event("jump", ev_w)

	# F 键交互
	if not InputMap.has_action("interact"):
		InputMap.add_action("interact")
	var ev_f := InputEventKey.new()
	ev_f.physical_keycode = KEY_F
	InputMap.action_add_event("interact", ev_f)

# ── HP management ──────────────────────────────────────────
func heal(amount: int) -> void:
	player_hp = min(player_hp + amount, player_max_hp)
	hp_changed.emit(player_hp, player_max_hp)

func take_damage(amount: int) -> void:
	player_hp = max(player_hp - amount, 0)
	hp_changed.emit(player_hp, player_max_hp)

# ── EXP / Level ────────────────────────────────────────────
func _get_level_cap() -> int:
	return LEVEL_CAPS[min(evolution_count, LEVEL_CAPS.size() - 1)]

func gain_exp(amount: int) -> void:
	player_exp += amount
	var cap := _get_level_cap()
	while player_level < cap and player_level < EXP_TABLE.size() - 1 \
			and player_exp >= EXP_TABLE[player_level]:
		player_level += 1
		_apply_level_bonus()
		level_up.emit(player_level)
	# 升级循环结束后再发信号，确保 HUD 拿到最终等级
	exp_changed.emit(player_exp, exp_needed_for_next_level())

func exp_needed_for_next_level() -> int:
	var cap := _get_level_cap()
	if player_level >= cap:
		return 0   # 已达上限，HUD 显示锁定
	if player_level >= EXP_TABLE.size() - 1:
		return 0
	return EXP_TABLE[player_level]

func _apply_level_bonus() -> void:
	player_max_hp += 10
	player_attack  += 1
	# 升级恢复 30% 最大血量
	var restore := int(player_max_hp * 0.3)
	player_hp = min(player_hp + restore, player_max_hp)
	hp_changed.emit(player_hp, player_max_hp)

# ── 进化（击败 Boss 后调用）──────────────────────────────────
func evolve() -> void:
	if evolution_count >= 3:
		return
	evolution_count += 1
	# 自动根据进化次数解锁对应技能
	match evolution_count:
		1: SkillManager.unlock(SkillManager.Skill.PARALLEL_SKIING)
		2: SkillManager.unlock(SkillManager.Skill.BACK_FLIP)
		3: SkillManager.unlock(SkillManager.Skill.CARVING)
	evolved.emit(evolution_count)

# ── 击杀敌人回血 10% ──────────────────────────────────────
func on_enemy_killed() -> void:
	var restore := int(player_max_hp * 0.1)
	heal(restore)

# ── 游戏通关 ───────────────────────────────────────────────
func complete_game() -> void:
	game_completed.emit()

# ── 金币 ──────────────────────────────────────────────────
func add_gold(amount: int) -> void:
	gold = max(gold + amount, 0)
	gold_changed.emit(gold)

func add_pending_equipment_drop(scene_path: String, position: Vector2, slot: int, level: int, label_text: String) -> String:
	var drop_id := "%s:%d:%d:%d" % [scene_path, Time.get_ticks_msec(), slot, pending_equipment_drops.size()]
	pending_equipment_drops.append({
		"id": drop_id,
		"scene_path": scene_path,
		"x": position.x,
		"y": position.y,
		"slot": slot,
		"level": level,
		"label_text": label_text,
	})
	return drop_id

func get_pending_equipment_drops(scene_path: String) -> Array[Dictionary]:
	var matched: Array[Dictionary] = []
	for entry in pending_equipment_drops:
		if String(entry.get("scene_path", "")) == scene_path:
			matched.append(entry)
	return matched

func remove_pending_equipment_drop(drop_id: String) -> void:
	var remaining: Array[Dictionary] = []
	for entry in pending_equipment_drops:
		if String(entry.get("id", "")) != drop_id:
			remaining.append(entry)
	pending_equipment_drops = remaining

func begin_death_retry_state() -> void:
	death_retry_pending = true

func clear_death_retry_state() -> void:
	death_retry_pending = false

