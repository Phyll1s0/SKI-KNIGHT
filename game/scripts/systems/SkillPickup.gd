extends Area2D
# SkillPickup — 技能解锁宝箱/拾取物
# 玩家进入触发区域后解锁对应技能，并显示提示，然后消失

@export_enum("ICE_BLADE:0", "PARALLEL_SKIING:1", "CARVING:2") var skill: int = 0
@export var label_text: String = "新技能"

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label

func _ready() -> void:
	add_to_group("skill_pickup")
	label.text = label_text
	label.visible = false
	# 如果已经解锁就直接消失（读档后重进地图）
	if SkillManager.has_skill(skill as SkillManager.Skill):
		queue_free()
		return
	# 漂浮闪光动画
	var tween := create_tween().set_loops()
	tween.tween_property(sprite, "position:y", -8.0, 0.7).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "position:y", 8.0, 0.7).set_trans(Tween.TRANS_SINE)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	SkillManager.unlock(skill as SkillManager.Skill)
	label.visible = true
	# 显示提示后淡出消失
	var tween := create_tween()
	tween.tween_property(label, "modulate:a", 0.0, 1.5).set_delay(1.0)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.5).set_delay(1.0)
	tween.tween_callback(queue_free)
