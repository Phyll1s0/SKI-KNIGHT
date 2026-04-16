extends Node2D

# 冰球弹丸：由炮台生成，直线飞行，击中玩家或地形后消失

@export var speed: float = 300.0
@export var damage: int = 10
@export var lifetime: float = 3.0

var direction: Vector2 = Vector2.RIGHT
var _timer: float = 0.0

@onready var area: Area2D = $Area2D

func _ready() -> void:
	# 检测地形 (layer 1) 和玩家 (layer 2)
	area.set_collision_mask_value(1, true)
	area.set_collision_mask_value(2, true)

func init(dir: Vector2) -> void:
	direction = dir.normalized()
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	_timer += delta
	if _timer >= lifetime:
		queue_free()

func _on_area_2d_body_entered(body: Node) -> void:
	# 只伤害玩家，穿过敌人和中性物体
	if body.is_in_group("enemy"):
		return
	if body.is_in_group("player"):
		body.take_damage(damage, global_position, "冰球炮弹")
	queue_free()
