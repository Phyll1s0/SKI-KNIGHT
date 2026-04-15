extends "res://scripts/systems/BaseMap.gd"
# 地下冰窟 — 极暗区域，深处有雪崩巨人（掉落卡宾技能）
# 入场需求：升级雪板 + 雪镜二级

const VISIBILITY_DARK_COLOR := Color(0.05, 0.08, 0.15, 1.0)  # 背景极暗色调

func _ready() -> void:
	super._ready()
