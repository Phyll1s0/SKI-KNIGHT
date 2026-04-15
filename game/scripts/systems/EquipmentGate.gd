extends Node2D
# EquipmentGate — 装备锁门
# 放在地图区域边界，根据装备条件决定是否通行
# 如果条件不满足，显示提示并阻挡玩家（StaticBody2D 开关）

@export_enum("HELMET:0", "GOGGLES:1", "SNOWBOARD:2", "SUIT:3") var required_slot: int = 2
@export var required_level: int = 1
@export var hint_text: String = "需要特定装备才能通过"

# 通行后跳转的场景路径（空=仅解锁碰撞体）
@export var target_scene: String = ""

var _is_open: bool = false

@onready var blocker: StaticBody2D = $Blocker
@onready var hint_label: Label = $HintLabel
@onready var trigger: Area2D = $TriggerArea

func _ready() -> void:
	hint_label.text = hint_text
	hint_label.visible = false
	_check_open()
	EquipmentManager.equipment_changed.connect(func(_s, _l): _check_open())

func _check_open() -> void:
	var eq_slot: EquipmentManager.Slot = required_slot as EquipmentManager.Slot
	_is_open = EquipmentManager.has_equipment(eq_slot, required_level)
	blocker.get_node("CollisionShape2D").disabled = _is_open
	# 视觉：开门变透明
	blocker.modulate.a = 0.0 if _is_open else 1.0

func _on_trigger_area_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	if _is_open:
		if target_scene != "":
			get_tree().change_scene_to_file(target_scene)
	else:
		hint_label.visible = true
		# 2 秒后隐藏提示
		var t := get_tree().create_timer(2.0)
		t.timeout.connect(func(): hint_label.visible = false)

func _on_trigger_area_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		hint_label.visible = false
