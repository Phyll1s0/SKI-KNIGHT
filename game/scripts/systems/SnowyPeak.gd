extends "res://scripts/systems/BaseMap.gd"
# 雪山顶峰 — 逆风攀顶 + Boss后飞速下山
# Zone1-3 (x<DESCENT_X): 强双向极风，玩家逆势爬升
# Zone4  (x>=DESCENT_X): 微风顺向助推，配合下坡形成爽快冲刺感

@export var peak_wind_force: float = 260.0    # Zone1-3 极风
@export var descent_wind_force: float = 45.0  # Zone4 顺风下山
const DESCENT_START_X: float = 3600.0         # Boss竞技场右侧

var _wind_dir: float = 1.0
var _wind_timer: float = 0.0

func _ready() -> void:
	super._ready()

func _process(delta: float) -> void:
	super._process(delta)
	if not is_instance_valid(_player):
		return
	var px: float = _player.global_position.x
	if px < DESCENT_START_X:
		# Zone1-3: 强风双向交替，顶风时降低加速
		_wind_timer += delta
		if _wind_timer >= 4.0:
			_wind_timer = 0.0
			_wind_dir *= -1.0
		var input_dir: float = Input.get_axis("move_left", "move_right")
		var resistance: float = 0.4 if input_dir * _wind_dir < 0.0 else 1.0
		_player.velocity.x += peak_wind_force * _wind_dir * resistance * delta
	else:
		# Zone4: 微风向右，助力下山（不对抗）
		_player.velocity.x += descent_wind_force * delta

