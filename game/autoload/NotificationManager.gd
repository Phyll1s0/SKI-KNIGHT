extends Node
# NotificationManager — Autoload
# 管理全局物品获得通知显示

const _NOTIFICATION_SCENE := preload("res://scenes/ui/ItemNotification.tscn")

var _notification_instance: CanvasLayer = null

func _ready() -> void:
	_notification_instance = _NOTIFICATION_SCENE.instantiate()
	add_child(_notification_instance)

func show_item_acquired(item_name: String, description: String) -> void:
	if _notification_instance != null and _notification_instance.has_method("show_notification"):
		_notification_instance.show_notification(item_name, description)

# 装备获得提示文本
func get_equipment_description(slot: int, level: int) -> Dictionary:
	match slot:
		0:  # HELMET
			match level:
				1: return {"name": "头盔 Lv1", "desc": "减少30%冲撞伤害和坠落伤害\n减少50%击退效果"}
				2: return {"name": "头盔 Lv2", "desc": "减少50%冲撞伤害和坠落伤害\n完全免疫击退"}
		1:  # GOGGLES
			match level:
				1: return {"name": "雪镜 Lv1", "desc": "增加10%攻击距离和伤害"}
				2: return {"name": "雪镜 Lv2", "desc": "增加20%攻击距离和伤害\n提供照明效果"}
		2:  # SNOWBOARD
			match level:
				1: return {"name": "雪板 Lv1", "desc": "解锁新区域通行"}
				2: return {"name": "雪板 Lv2", "desc": "解锁高级区域通行"}
		3:  # SUIT
			match level:
				1: return {"name": "雪服 Lv1", "desc": "防寒保护，抵御寒冷伤害"}
	return {"name": "装备", "desc": "获得新装备"}

# 技能获得提示文本
func get_skill_description(skill_id: int) -> Dictionary:
	match skill_id:
		0:  # ICE_BLADE
			return {"name": "冰刃投掷", "desc": "按 K 投掷冰刃进行远程攻击"}
		1:  # PARALLEL_SKIING
			return {"name": "平行式滑雪", "desc": "按 S 可以在雪面上快速刹车\n增加最快滑雪速度和陡坡通过能力"}
		2:  # BACK_FLIP
			return {"name": "后空翻", "desc": "空中可以使用二段跳跃"}
		3:  # CARVING
			return {"name": "卡宾技术", "desc": "在任何表面都可以刹车（按 S）\n提升转向灵活性，适应复杂路线"}
	return {"name": "新技能", "desc": "获得新技能"}
