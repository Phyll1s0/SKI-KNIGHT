extends Node

const _GOLD_PICKUP_SCENE := preload("res://scenes/systems/GoldPickup.tscn")
const _GOLD_STACK_SIZE: int = 40
const _MAX_GOLD_STACKS: int = 5
const BASE_PLAYER_MAX_HP: int = 100
const BASE_PLAYER_ATTACK: int = 15
const HP_PER_LEVEL: int = 5
const PREVIOUS_HP_PER_LEVEL: int = 10
const LEGACY_BASE_PLAYER_ATTACK: int = 24
const LEGACY_BASE_PLAYER_MAX_HP: int = 120
const LEGACY_HP_PER_LEVEL: int = 12
const BOSS_HIT_HEAL_RATIO: float = 0.03
const LEVEL_UP_HEAL_RATIO: float = 0.10

# ── Player persistent data ──────────────────────────────────
var player_max_hp: int = BASE_PLAYER_MAX_HP
var player_hp: int = BASE_PLAYER_MAX_HP
var player_exp: int = 0
var player_level: int = 1
var player_attack: int = BASE_PLAYER_ATTACK
# 最近激活的重生点（Vector2.ZERO 表示未指定）
var respawn_position: Vector2 = Vector2.ZERO
# 最近存档点所在的场景路径（空字符串表示未存档）
var respawn_scene: String = ""
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
var story_flags: Dictionary = {}

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

func expected_max_hp_for_level(level: int) -> int:
	return BASE_PLAYER_MAX_HP + max(level - 1, 0) * HP_PER_LEVEL

func previous_expected_max_hp_for_level(level: int) -> int:
	return BASE_PLAYER_MAX_HP + max(level - 1, 0) * PREVIOUS_HP_PER_LEVEL

func expected_attack_for_level(level: int) -> int:
	return BASE_PLAYER_ATTACK + max(level - 1, 0)

func legacy_expected_max_hp_for_level(level: int) -> int:
	return LEGACY_BASE_PLAYER_MAX_HP + max(level - 1, 0) * LEGACY_HP_PER_LEVEL

func legacy_expected_attack_for_level(level: int) -> int:
	return LEGACY_BASE_PLAYER_ATTACK + max(level - 1, 0)

# ── HP management ──────────────────────────────────────────
func heal(amount: int) -> void:
	player_hp = min(player_hp + amount, player_max_hp)
	hp_changed.emit(player_hp, player_max_hp)

func take_damage(amount: int) -> void:
	player_hp = max(player_hp - amount, 0)
	hp_changed.emit(player_hp, player_max_hp)

func on_boss_hit() -> void:
	if player_hp <= 0:
		return
	var restore: int = maxi(1, int(ceil(float(player_max_hp) * BOSS_HIT_HEAL_RATIO)))
	heal(restore)

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
	player_max_hp = expected_max_hp_for_level(player_level)
	player_attack = expected_attack_for_level(player_level)
	# 升级恢复当前最大血量的 10%，再额外补上本级新增的 5 点生命
	var restore := int(player_max_hp * LEVEL_UP_HEAL_RATIO) + HP_PER_LEVEL
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

func drop_gold(amount: int, parent_node: Node, world_position: Vector2) -> void:
	if amount <= 0:
		return
	if parent_node == null:
		add_gold(amount)
		return
	var stack_count: int = clampi(int(ceil(float(amount) / float(_GOLD_STACK_SIZE))), 1, _MAX_GOLD_STACKS)
	var remaining: int = amount
	for stack_index in range(stack_count):
		var stacks_left: int = stack_count - stack_index
		var stack_amount: int = int(ceil(float(remaining) / float(stacks_left)))
		remaining -= stack_amount
		_spawn_gold_pickup(parent_node, world_position, stack_amount, stack_index, stack_count)

func _spawn_gold_pickup(parent_node: Node, world_position: Vector2, amount: int, stack_index: int, stack_count: int) -> void:
	var pickup: Area2D = _GOLD_PICKUP_SCENE.instantiate() as Area2D
	if pickup == null:
		add_gold(amount)
		return
	pickup.set("amount", amount)
	pickup.set("launch_velocity", Vector2(randf_range(-70.0, 70.0), randf_range(-120.0, -60.0)))
	parent_node.add_child(pickup)
	var stack_center: float = (float(stack_count - 1) * 0.5)
	var spread_x: float = (float(stack_index) - stack_center) * 12.0 + randf_range(-6.0, 6.0)
	pickup.global_position = world_position + Vector2(spread_x, randf_range(-8.0, 4.0))

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

func has_story_flag(flag_name: String) -> bool:
	return bool(story_flags.get(flag_name, false))

func set_story_flag(flag_name: String, value: bool = true) -> void:
	if flag_name.strip_edges().is_empty():
		return
	story_flags[flag_name] = value

