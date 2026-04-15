extends Node2D
# 冰刃弹丸：玩家发射，直线飞行，穿透0个敌人（命中即消失）

@export var speed: float = 500.0
@export var damage: int = 15
@export var lifetime: float = 2.5
@export var pierce: int = 0   # 穿透敌人数量（0=不穿透）

var direction: Vector2 = Vector2.RIGHT
var _timer: float = 0.0
var _hit_count: int = 0

@onready var area: Area2D = $Area2D

func init(dir: Vector2, dmg: int) -> void:
	direction = dir.normalized()
	damage = dmg
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	_timer += delta
	if _timer >= lifetime:
		_spawn_hit_effect()
		queue_free()

func _spawn_hit_effect() -> void:
	# 留空接口：后续加粒子特效
	pass

func _on_area_2d_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		return   # 不伤害自己
	if body.has_method("take_damage"):
		body.take_damage(damage, global_position)
		_hit_count += 1
		if _hit_count > pierce:
			_spawn_hit_effect()
			queue_free()
	else:
		# 命中地形/障碍物，立即消失
		_spawn_hit_effect()
		queue_free()
