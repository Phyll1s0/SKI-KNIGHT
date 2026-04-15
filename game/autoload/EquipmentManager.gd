extends Node
# EquipmentManager — Autoload
# 管理所有装备的持有状态和效果加成

const EQUIPMENT_ICON_PATHS := {
	Slot.HELMET: {
		1: "res://assets/sprites/equipment/helmet.png",
		"label": "头盔"
	},
	Slot.GOGGLES: {
		1: "res://assets/sprites/equipment/goggles_1.png",
		2: "res://assets/sprites/equipment/goggles_2.png",
		"label": "雪镜"
	},
	Slot.SNOWBOARD: {
		1: "res://assets/sprites/equipment/snowboard_upgrade.png",
		"label": "雪板"
	},
	Slot.SUIT: {
		1: "res://assets/sprites/equipment/suit.png",
		"label": "雪服"
	}
}

# ── 装备槽枚举 ────────────────────────────────────────────
enum Slot { HELMET, GOGGLES, SNOWBOARD, SUIT }

# 每件装备的等级（0 = 未持有，1 = 基础，2 = 升级版）
var equipment_level: Dictionary = {
	Slot.HELMET:    0,
	Slot.GOGGLES:   0,
	Slot.SNOWBOARD: 0,   # 0=普通雪板(内置), 1=升级雪板
	Slot.SUIT:      0,
}

var unlocked_level: Dictionary = {
	Slot.HELMET:    0,
	Slot.GOGGLES:   0,
	Slot.SNOWBOARD: 0,
	Slot.SUIT:      0,
}

# ── 信号 ──────────────────────────────────────────────────
signal equipment_changed(slot: int, level: int)

# ── 获取装备 ───────────────────────────────────────────────
func equip(slot: Slot, level: int = 1) -> void:
	equipment_level[slot] = level
	unlocked_level[slot] = max(unlocked_level.get(slot, 0), level)
	equipment_changed.emit(slot, level)

func unequip(slot: Slot) -> void:
	equipment_level[slot] = 0
	equipment_changed.emit(slot, 0)

func upgrade(slot: Slot) -> void:
	equipment_level[slot] += 1
	unlocked_level[slot] = max(unlocked_level.get(slot, 0), equipment_level[slot])
	equipment_changed.emit(slot, equipment_level[slot])

func has_equipment(slot: Slot, min_level: int = 1) -> bool:
	return equipment_level[slot] >= min_level

func has_unlocked(slot: Slot, min_level: int = 1) -> bool:
	return unlocked_level.get(slot, 0) >= min_level

func get_icon_path(slot: Slot, level: int) -> String:
	var meta: Dictionary = EQUIPMENT_ICON_PATHS.get(slot, {})
	if slot == Slot.GOGGLES and level >= 2:
		return meta.get(2, meta.get(1, ""))
	return meta.get(1, "")

func get_label_text(slot: Slot, level: int) -> String:
	var base: String = EQUIPMENT_ICON_PATHS.get(slot, {}).get("label", "装备")
	return "%s Lv.%d" % [base, max(level, 1)]

func get_equipped_items() -> Array[Dictionary]:
	var items: Array[Dictionary] = []
	for slot: Slot in [Slot.HELMET, Slot.GOGGLES, Slot.SNOWBOARD, Slot.SUIT]:
		var level: int = equipment_level.get(slot, 0)
		if level > 0:
			items.append({
				"slot": slot,
				"level": level,
				"label_text": get_label_text(slot, level)
			})
	return items

# ── 装备效果查询（供 Player / 地图使用）────────────────────

# 头盔：冲撞伤害加成倍率（基础1.0）
func collision_damage_mult() -> float:
	match equipment_level[Slot.HELMET]:
		1: return 1.5
		_: return 1.0

# 雪镜：攻击前向距离百分比加成
func attack_range_bonus() -> float:
	match equipment_level[Slot.GOGGLES]:
		1: return 0.10
		2: return 0.20
		_: return 0.0

# 雪镜二级：提供照明（布尔值）
func has_lighting() -> bool:
	return equipment_level[Slot.GOGGLES] >= 2

# 升级雪板：最高速度加成
func max_speed_bonus() -> float:
	match equipment_level[Slot.SNOWBOARD]:
		1: return 150.0
		_: return 0.0

# 高级雪服：防寒（布尔值）
func is_cold_proof() -> bool:
	return equipment_level[Slot.SUIT] >= 1
