extends Node
# SkillManager — Autoload
# 管理所有可解锁技能的持有状态和效果加成

# ── 技能枚举 ──────────────────────────────────────────────
enum Skill {
	ICE_BLADE,        # 冰刃投掷（暴风雪高地宝箱）
	PARALLEL_SKIING,  # 平行式滑雪（进化1：打败Boss1冰川雪豹）
	BACK_FLIP,        # 后空翻/二段跳（进化2：打败Boss2冻结守卫）
	CARVING,          # 卡宾（进化3：打败Boss3雪崩巨人）
}

# 已解锁的技能集合
var unlocked_skills: Dictionary = {
	Skill.ICE_BLADE:       false,
	Skill.PARALLEL_SKIING: false,
	Skill.BACK_FLIP:       false,
	Skill.CARVING:         false,
}

# ── 信号 ──────────────────────────────────────────────────
signal skill_unlocked(skill: int)

# ── 解锁 ──────────────────────────────────────────────────
func unlock(skill: Skill) -> void:
	if unlocked_skills[skill]:
		return   # 已解锁，不重复触发
	unlocked_skills[skill] = true
	# 同步到 GameManager（保持向后兼容）
	if skill == Skill.ICE_BLADE:
		GameManager.has_ice_blade = true
	if skill == Skill.BACK_FLIP:
		GameManager.has_double_jump = true
	skill_unlocked.emit(skill)

func has_skill(skill: Skill) -> bool:
	return unlocked_skills.get(skill, false)

# ── 平行式滑雪效果查询 ─────────────────────────────────────
# 速度上限加成（像素/秒）
func parallel_speed_bonus() -> float:
	return 120.0 if has_skill(Skill.PARALLEL_SKIING) else 0.0

# 刹车加速度加成（ski_friction 加成）
func parallel_friction_bonus() -> float:
	return 80.0 if has_skill(Skill.PARALLEL_SKIING) else 0.0

# 平行式滑雪：仅允许在雪地使用刹车
func parallel_brake_on_snow_only() -> bool:
	return has_skill(Skill.PARALLEL_SKIING)

# 可通行的最大坡度（法线 Y 分量阈值，越小越陡）
# 默认 0.2；平行式滑雪后 0.1
func passable_slope_threshold() -> float:
	return 0.1 if has_skill(Skill.PARALLEL_SKIING) else 0.2

# ── 后空翻效果查询 ────────────────────────────────────────
# 是否拥有二段跳能力
func can_double_jump() -> bool:
	return has_skill(Skill.BACK_FLIP)

# ── 卡宾效果查询 ──────────────────────────────────────────
# 空中横向控制力加成
func carving_air_control_bonus() -> float:
	return 60.0 if has_skill(Skill.CARVING) else 0.0

# 转向响应速度加成（地面 ski_accel 加成）
func carving_accel_bonus() -> float:
	return 100.0 if has_skill(Skill.CARVING) else 0.0

# 卡宾：短冲刺参数
func carving_dash_speed() -> float:
	return 360.0 if has_skill(Skill.CARVING) else 0.0

func carving_dash_duration() -> float:
	return 0.14 if has_skill(Skill.CARVING) else 0.0

func carving_dash_cooldown() -> float:
	return 0.55 if has_skill(Skill.CARVING) else 0.0

# 卡宾：地面可在雪面和冰面都刹车
func carving_all_surface_brake() -> bool:
	return has_skill(Skill.CARVING)

# ── 序列化（供 SaveSystem 使用）─────────────────────────────
func serialize() -> Dictionary:
	return {
		"ice_blade":       unlocked_skills[Skill.ICE_BLADE],
		"parallel_skiing": unlocked_skills[Skill.PARALLEL_SKIING],
		"back_flip":        unlocked_skills[Skill.BACK_FLIP],
		"carving":          unlocked_skills[Skill.CARVING],
	}

func deserialize(data: Dictionary) -> void:
	if data.get("ice_blade", false):
		unlock(Skill.ICE_BLADE)
	if data.get("parallel_skiing", false):
		unlock(Skill.PARALLEL_SKIING)
	if data.get("back_flip", false):
		unlock(Skill.BACK_FLIP)
	if data.get("carving", false):
		unlock(Skill.CARVING)
