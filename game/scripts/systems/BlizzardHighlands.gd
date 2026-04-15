extends "res://scripts/systems/BaseMap.gd"
# 暴风雪高地 — cold_zone，持续侧风，入场需要高级雪服 + 平行式滑雪技能

# 强风参数
@export var wind_force: float = 180.0      # 水平风力（像素/秒²）
@export var wind_direction: float = 1.0    # 1.0=向右, -1.0=向左
@export var wind_gust_interval: float = 6.0 # 阵风切换间隔（秒）

var _wind_timer: float = 0.0

# BaseMap 已处理 cold_zone 扣血，cold_zone = true 在场景导出属性里设置

func _ready() -> void:
	super._ready()
	# 随机初始风向
	wind_direction = 1.0 if randf() > 0.5 else -1.0

func _process(delta: float) -> void:
	super._process(delta)   # 调用 BaseMap 寒冷扣血
	_update_wind(delta)
	_apply_wind(delta)

func _update_wind(delta: float) -> void:
	_wind_timer += delta
	if _wind_timer >= wind_gust_interval:
		_wind_timer = 0.0
		wind_direction *= -1.0   # 阵风反向

func _apply_wind(delta: float) -> void:
	if not is_instance_valid(_player):
		return
	# 根据玩家 x 位置计算风区强度
	# x<400 = 峡谷入口（弱风×0.25），400-1400 = 斜坡风道（×1.0），
	# 1400-2600 = 裸露山脊（×1.4），2600+ = 暴风走廊（×1.7）
	var px: float = _player.global_position.x
	var zone_mult: float = 0.25
	if px > 2600.0:
		zone_mult = 1.7
	elif px > 1400.0:
		zone_mult = 1.4
	elif px > 400.0:
		zone_mult = 1.0
	var input_dir: float = Input.get_axis("move_left", "move_right")
	var resistance: float = 0.4 if input_dir * wind_direction < 0 else 1.0
	_player.velocity.x += wind_force * wind_direction * resistance * zone_mult * delta
