extends "res://scripts/systems/BaseMap.gd"
# 地下冰窟 — 极暗区域，深处有雪崩巨人（掉落卡宾技能）
# 入场需求：升级雪板 + 雪镜二级

const VISIBILITY_DARK_COLOR := Color(0.05, 0.08, 0.15, 1.0)  # 背景极暗色调

@onready var _boss3: Node2D = $AvalancheGiantBoss
@onready var _portal_to_peak: Area2D = $PortalToPeak
@onready var _portal_label: Label = $PortalToPeak/PortalLabel

func _ready() -> void:
	super._ready()
	_configure_boss3_flow()

func _configure_boss3_flow() -> void:
	if GameManager.evolution_count >= 3 or SkillManager.has_skill(SkillManager.Skill.CARVING):
		if is_instance_valid(_boss3):
			_boss3.queue_free()
		_set_peak_portal_unlocked(true)
		return
	_set_peak_portal_unlocked(false)
	if is_instance_valid(_boss3):
		_boss3.tree_exited.connect(_on_boss3_defeated, CONNECT_ONE_SHOT)

func _set_peak_portal_unlocked(is_unlocked: bool) -> void:
	if not is_instance_valid(_portal_to_peak):
		return
	_portal_to_peak.monitoring = is_unlocked
	_portal_to_peak.monitorable = is_unlocked
	_portal_to_peak.modulate = Color(1.0, 1.0, 1.0, 1.0) if is_unlocked else Color(0.55, 0.62, 0.86, 0.42)
	if is_instance_valid(_portal_label):
		_portal_label.text = "► 前往雪山顶峰" if is_unlocked else "击败雪崩巨人后开启"

func _on_boss3_defeated() -> void:
	_set_peak_portal_unlocked(true)
