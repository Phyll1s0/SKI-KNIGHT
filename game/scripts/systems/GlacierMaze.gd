extends "res://scripts/systems/BaseMap.gd"
# 冰川迷宫 — 三段冰区，摩擦力递减，多分叉路径

# 冰区定义：[x_min, x_max, friction]
const ICE_ZONES: Array = [
	[800.0,  1350.0, 22.0],   # 冰区A：入门级滑冰地板
	[1700.0, 2300.0, 14.0],   # 冰区B：更滑，需控制冲量
	[2700.0, 3200.0,  6.0],   # 冰区C：极滑深冰，最后考验
]
const DEFAULT_FRICTION: float = 120.0

@onready var _boss1: Node2D = $IceLynxBoss
@onready var _portal_to_blizzard: Area2D = $PortalToBlizzard
@onready var _portal_label: Label = $PortalToBlizzard/PortalLabel
@onready var _boss_room_trigger: Area2D = $BossRoomEntranceTrigger
@onready var _boss_room_gate: StaticBody2D = $BossRoomGate
@onready var _boss_room_gate_shape: CollisionShape2D = $BossRoomGate/Col
@onready var _boss_room_gate_visual: Polygon2D = $BossRoomGate/Visual

const _BOSS_ROOM_ENTRY_X := 2940.0

func _ready() -> void:
	super._ready()
	_configure_boss1_flow()

func _process(delta: float) -> void:
	super._process(delta)
	_apply_ice_effect()

func _configure_boss1_flow() -> void:
	if GameManager.evolution_count >= 1:
		if is_instance_valid(_boss1):
			_boss1.queue_free()
		_set_boss_room_locked(false)
		if is_instance_valid(_boss_room_trigger):
			_boss_room_trigger.monitoring = false
		_set_blizzard_portal_unlocked(true)
		return
	_set_boss_room_locked(_should_lock_boss_room())
	if is_instance_valid(_boss_room_trigger):
		_boss_room_trigger.monitoring = true
	_set_blizzard_portal_unlocked(false)
	if is_instance_valid(_boss1):
		_boss1.tree_exited.connect(_on_boss1_defeated, CONNECT_ONE_SHOT)

func _set_blizzard_portal_unlocked(is_unlocked: bool) -> void:
	if not is_instance_valid(_portal_to_blizzard):
		return
	_portal_to_blizzard.monitoring = is_unlocked
	_portal_to_blizzard.monitorable = is_unlocked
	_portal_to_blizzard.modulate = Color(1.0, 1.0, 1.0, 1.0) if is_unlocked else Color(0.5, 0.6, 0.85, 0.42)
	if is_instance_valid(_portal_label):
		_portal_label.text = "► 前往暴风雪高地" if is_unlocked else "击败冰川雪豹后开启"

func _on_boss1_defeated() -> void:
	_set_boss_room_locked(false)
	if is_instance_valid(_boss_room_trigger):
		_boss_room_trigger.monitoring = false
	_set_blizzard_portal_unlocked(true)

func _should_lock_boss_room() -> bool:
	return is_instance_valid(_player) and _player.global_position.x >= _BOSS_ROOM_ENTRY_X

func _set_boss_room_locked(is_locked: bool) -> void:
	if is_instance_valid(_boss_room_gate_shape):
		_boss_room_gate_shape.disabled = not is_locked
	if is_instance_valid(_boss_room_gate_visual):
		_boss_room_gate_visual.visible = is_locked

func _on_boss_room_trigger_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	if GameManager.evolution_count >= 1:
		return
	_set_boss_room_locked(true)

func _apply_ice_effect() -> void:
	if not is_instance_valid(_player):
		return
	var px: float = _player.global_position.x
	var friction: float = DEFAULT_FRICTION
	for zone: Array in ICE_ZONES:
		if px >= zone[0] and px <= zone[1]:
			friction = zone[2]
			break
	_player.set("ski_friction", friction)
