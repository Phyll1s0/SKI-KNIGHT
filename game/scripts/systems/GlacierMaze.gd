extends "res://scripts/systems/BaseMap.gd"
# 冰川迷宫 — 三段冰区，摩擦力递减，多分叉路径

# 冰区定义：[x_min, x_max, friction]
const ICE_ZONES: Array = [
	[800.0,  1350.0, 22.0],   # 冰区A：入门级滑冰地板
	[1700.0, 2300.0, 14.0],   # 冰区B：更滑，需控制冲量
	[2700.0, 3200.0,  6.0],   # 冰区C：极滑深冰，最后考验
]
const DEFAULT_FRICTION: float = 120.0

func _process(delta: float) -> void:
	super._process(delta)
	_apply_ice_effect()

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
