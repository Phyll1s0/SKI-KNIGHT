extends StaticBody2D

const _HIT_EFFECT := preload("res://scenes/effects/HitEffect.tscn")

# 冰球炮台：固定位置，朝玩家方向定时发射冰球弹丸
# 帧定义：0=idle  1=charge（充能）  2=fire（开火）  3=dead（破损）

@export var max_hp: int = 50
@export var attack_damage: int = 12
@export var fire_interval: float = 1.8   # 发射间隔（秒）
@export var detect_range: float = 380.0  # 探测距离
@export var exp_reward: int = 18
@export var iceball_scene: PackedScene = preload("res://scenes/enemies/IceBall.tscn")

const FRAME_IDLE   := 0
const FRAME_CHARGE := 1
const FRAME_FIRE   := 2
const FRAME_DEAD   := 3

const CHARGE_DURATION := 0.45   # 充能持续时间（秒）
const FIRE_DURATION   := 0.18   # 开火帧停留时间

var hp: int = max_hp
var _fire_timer: float = 0.0
var _is_dead: bool = false
var _player: CharacterBody2D = null
var _charging: bool = false
var _charge_timer: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var detect_area: Area2D = $DetectArea
@onready var muzzle: Marker2D = $Muzzle

func _ready() -> void:
	add_to_group("enemy")
	_fire_timer = randf_range(0.0, fire_interval)
	set_collision_layer_value(1, false)
	set_collision_layer_value(3, true)
	detect_area.set_collision_mask_value(1, false)
	detect_area.set_collision_mask_value(2, true)

func _process(delta: float) -> void:
	if _is_dead:
		return

	# 保底玩家检测
	if not is_instance_valid(_player):
		for node in get_tree().get_nodes_in_group("player"):
			if global_position.distance_to(node.global_position) <= detect_range:
				_player = node
				break

	# 充能计时中
	if _charging:
		_charge_timer -= delta
		if _charge_timer <= 0.0:
			_charging = false
			_do_fire()
		return

	_fire_timer -= delta
	if _fire_timer <= 0.0 and is_instance_valid(_player):
		var dist := global_position.distance_to(_player.global_position)
		if dist <= detect_range:
			_start_charge()
			_fire_timer = fire_interval

func _start_charge() -> void:
	# 充能：变橙预警色
	_charging = true
	_charge_timer = CHARGE_DURATION
	if sprite:
		sprite.frame = FRAME_CHARGE
		sprite.modulate = Color(1.8, 1.0, 0.2, 1.0)

func _do_fire() -> void:
	if not is_instance_valid(_player):
		_set_idle()
		return
	# 切到开火帧，闪红
	if sprite:
		sprite.frame = FRAME_FIRE
		sprite.modulate = Color(2.0, 0.3, 0.3, 1.0)
	# 生成冰球
	var ball: Node2D = iceball_scene.instantiate()
	get_parent().add_child(ball)
	ball.global_position = muzzle.global_position
	var dir := (_player.global_position - muzzle.global_position).normalized()
	ball.init(dir)
	# 炮管方向翻转（朝左时）
	if sprite:
		sprite.flip_h = dir.x < 0
	# 短暂停留开火帧后回 idle
	var t := get_tree().create_timer(FIRE_DURATION)
	t.timeout.connect(_set_idle)

func _set_idle() -> void:
	if sprite and not _is_dead:
		sprite.frame = FRAME_IDLE
		sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)

func take_damage(amount: int, _hit_pos: Vector2 = Vector2.ZERO) -> void:
	if _is_dead:
		return
	hp -= amount
	# 受击粒子特效
	var fx: GPUParticles2D = _HIT_EFFECT.instantiate()
	get_parent().add_child(fx)
	fx.global_position = global_position
	fx.emitting = true
	var t_fx := get_tree().create_timer(0.5)
	t_fx.timeout.connect(func(): if is_instance_valid(fx): fx.queue_free())
	# 受击闪白（不打断充能帧，只改颜色）
	if sprite:
		var tween := create_tween()
		tween.tween_property(sprite, "modulate", Color(2, 2, 2), 0.05)
		tween.tween_property(sprite, "modulate", Color(1, 1, 1), 0.1)
	if hp <= 0:
		_die()

func _die() -> void:
	_is_dead = true
	_charging = false
	if sprite:
		sprite.frame = FRAME_DEAD
		sprite.modulate = Color(0.5, 0.5, 0.5, 1.0)
	GameManager.gain_exp(exp_reward)
	GameManager.add_gold(randi_range(10, 20))
	GameManager.on_enemy_killed()
	var tween := create_tween()
	tween.tween_interval(0.3)
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	tween.tween_callback(queue_free)

func _on_detect_area_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player = body

func _on_detect_area_body_exited(body: Node) -> void:
	if body == _player:
		_player = null
