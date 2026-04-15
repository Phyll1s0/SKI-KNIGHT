extends AnimatableBody2D
# 缆车 — 在两点间匀速往返的移动平台
# travel_offset: 相对起始位置的终点偏移（通常为水平方向）
# 玩家站在平台上时，move_and_slide 自动继承平台速度

@export var travel_offset: Vector2 = Vector2(400.0, 0.0)
@export var speed: float = 110.0       # 像素 / 秒
@export var wait_time: float = 1.6     # 到达端点后停留秒数

var _start: Vector2
var _end: Vector2
var _dir: float = 1.0      # 1.0 = 向终点，-1.0 = 向起点
var _wait: float = 0.0

func _ready() -> void:
	_start = global_position
	_end   = global_position + travel_offset

func _physics_process(delta: float) -> void:
	if _wait > 0.0:
		_wait -= delta
		return

	var target: Vector2 = _end if _dir > 0.0 else _start
	var to_target: Vector2 = target - global_position
	if to_target.length() <= speed * delta:
		global_position = target
		_wait = wait_time
		_dir *= -1.0
	else:
		global_position += to_target.normalized() * speed * delta
