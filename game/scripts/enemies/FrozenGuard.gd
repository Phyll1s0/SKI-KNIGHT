extends CharacterBody2D
# Boss 2 — 冻结守卫
# 防御型：正面护盾减伤，旋转斩 + 跳砸，死亡掉落「雪镜二级」

const _PLACEHOLDER_VISUALS := preload("res://scripts/systems/BossPlaceholderVisuals.gd")
const _BOSS_ATTACK_TELEGRAPH := preload("res://scripts/systems/BossAttackTelegraph.gd")
const _BOSS_REWARD_PICKUP_SCENE := preload("res://scenes/systems/BossRewardPickup.tscn")

# ── Stats ──────────────────────────────────────────────────
@export var max_hp: int = 820
@export var march_damage: int = 20
@export var spin_damage: int = 28
@export var slam_damage: int = 46
@export var march_speed: float = 62.0
@export var gravity: float = 980.0
@export var detect_range: float = 500.0
@export var spin_range: float = 300.0
@export var slam_range: float = 240.0
@export var spin_cooldown: float = 4.8
@export var slam_cooldown: float = 6.5
@export var exp_reward: int = 380
@export var contact_damage: int = 18
@export var contact_cooldown: float = 0.8
@export var shield_bash_damage: int = 26
@export var shield_bash_speed: float = 240.0
@export var shield_bash_cooldown: float = 4.6

var hp: int = max_hp
var _is_dead: bool = false
var _shield_broken: bool = false
var _phase2: bool = false
var _spin_timer: float = 2.0    # 初始冷却，防止开场立刻旋转
var _slam_timer: float = 4.0
var _state_timer: float = 0.0
var _contact_timer: float = 0.0
var _facing: float = 1.0
var _bash_timer: float = 2.6

enum State { MARCH, SPIN_WINDUP, SPINNING, SLAM_WINDUP, SLAM_AIR, SLAM_LAND, BASH_WINDUP, BASHING, STAGGER, HURT, DEAD }
var state: State = State.MARCH

@onready var sprite: Sprite2D = $Sprite2D
@onready var shield_sprite: Sprite2D = $ShieldSprite
@onready var body_collision: CollisionShape2D = $CollisionShape2D
@onready var march_area: Area2D = $MarchArea
@onready var spin_area: Area2D = $SpinArea
@onready var slam_area: Area2D = $SlamArea
@onready var detect_area: Area2D = $DetectArea

var _player: CharacterBody2D = null
var _telegraph: Node = null

func _ready() -> void:
	add_to_group("enemy")
	_ensure_placeholder_visuals()
	_telegraph = _BOSS_ATTACK_TELEGRAPH.new()
	add_child(_telegraph)
	march_area.monitoring = false
	spin_area.monitoring = false
	slam_area.monitoring = false
	# 敌人体在 layer 3
	set_collision_layer_value(1, false)
	set_collision_layer_value(3, true)
	march_area.set_collision_mask_value(1, false)
	march_area.set_collision_mask_value(2, true)
	spin_area.set_collision_mask_value(1, false)
	spin_area.set_collision_mask_value(2, true)
	slam_area.set_collision_mask_value(1, false)
	slam_area.set_collision_mask_value(2, true)
	detect_area.set_collision_mask_value(1, false)
	detect_area.set_collision_mask_value(2, true)
	_set_facing(1.0)

func _ensure_placeholder_visuals() -> void:
	if sprite != null and sprite.texture == null:
		sprite.texture = _PLACEHOLDER_VISUALS.make_frozen_guard_body()
	if shield_sprite != null and shield_sprite.texture == null:
		shield_sprite.texture = _PLACEHOLDER_VISUALS.make_frozen_guard_shield()

func _change_state(new_state: State) -> void:
	state = new_state
	_state_timer = 0.0

func _set_facing(dir: float) -> void:
	if is_zero_approx(dir):
		return
	_facing = signf(dir)
	if sprite != null:
		sprite.flip_h = _facing < 0.0
	if shield_sprite != null:
		shield_sprite.position.x = 28.0 * _facing
		shield_sprite.flip_h = _facing < 0.0
	if march_area != null:
		march_area.position.x = 30.0 * _facing

func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	_state_timer += delta
	_spin_timer = max(_spin_timer - delta, 0.0)
	_slam_timer = max(_slam_timer - delta, 0.0)
	_bash_timer = max(_bash_timer - delta, 0.0)
	_contact_timer = max(_contact_timer - delta, 0.0)
	if _telegraph != null:
		_telegraph.hide_warning()

	if not is_on_floor():
		velocity.y += gravity * delta

	# 二阶段：hp < 40% 护盾破碎，进入狂暴
	if not _phase2 and float(hp) / float(max_hp) < 0.4:
		_enter_phase2()

	match state:
		State.MARCH:
			_do_march(delta)

		State.SPIN_WINDUP:
			velocity.x = 0.0
			if _telegraph != null:
				_telegraph.show_zone(190.0, "旋斩", -2.0)
			if _state_timer >= 0.68:
				spin_area.monitoring = true
				_change_state(State.SPINNING)

		State.SPINNING:
			velocity.x = 0.0
			if _state_timer >= 0.7:
				spin_area.monitoring = false
				_spin_timer = spin_cooldown
				_change_state(State.MARCH)

		State.SLAM_WINDUP:
			velocity.x = 0.0
			if _telegraph != null:
				_telegraph.show_zone(250.0, "跳砸", 18.0)
			if _state_timer >= 0.55:
				velocity.y = -580.0
				_change_state(State.SLAM_AIR)

		State.SLAM_AIR:
			if _state_timer > 0.1 and is_on_floor():
				slam_area.monitoring = true
				_change_state(State.SLAM_LAND)

		State.SLAM_LAND:
			velocity.x = 0.0
			if _state_timer >= 0.4:
				slam_area.monitoring = false
				_slam_timer = slam_cooldown
				_change_state(State.MARCH)

		State.BASH_WINDUP:
			velocity.x = 0.0
			if _telegraph != null:
				_telegraph.show_forward(_facing, 140.0, "盾击", -8.0)
			if _state_timer >= 0.42:
				velocity.x = _facing * shield_bash_speed
				_change_state(State.BASHING)

		State.BASHING:
			_hit_player_in_box(96.0, 44.0, shield_bash_damage, "冻结守卫盾击")
			if _state_timer >= 0.34:
				velocity.x = 0.0
				_bash_timer = shield_bash_cooldown
				_change_state(State.MARCH)

		State.STAGGER:
			velocity.x = move_toward(velocity.x, 0.0, 400.0 * delta)
			if _state_timer >= (_phase2_stagger_time if _phase2 else 0.5):
				_change_state(State.MARCH)

		State.HURT:
			if _state_timer >= 0.25:
				_change_state(State.MARCH)

	move_and_slide()
	_check_contact_damage()

	if velocity.x != 0.0:
		_set_facing(velocity.x)
	# 护盾始终朝前
	if shield_sprite:
		shield_sprite.visible = not _shield_broken

var _phase2_stagger_time: float = 2.0  # 护盾破碎硬直时间

func _do_march(delta: float) -> void:
	if not is_instance_valid(_player):
		velocity.x = 0.0
		return

	var dist := global_position.distance_to(_player.global_position)
	var dir: float = sign(_player.global_position.x - global_position.x)
	_set_facing(dir if not is_zero_approx(dir) else _facing)
	var spd: float = march_speed * (1.2 if _phase2 else 1.0)
	velocity.x = dir * spd

	# 碰墙时跳跃避免卡死
	if is_on_wall() and is_on_floor():
		velocity.y = -500.0

	# 近战推进
	march_area.monitoring = dist <= 62.0
	if _bash_timer <= 0.0 and dist >= 84.0 and dist <= 168.0:
		_change_state(State.BASH_WINDUP)
		return

	# 旋转攻击
	if _spin_timer <= 0.0 and dist <= spin_range:
		_change_state(State.SPIN_WINDUP)
		return

	# 跳砸
	if _slam_timer <= 0.0 and dist <= slam_range:
		_change_state(State.SLAM_WINDUP)

func _enter_phase2() -> void:
	_phase2 = true
	_shield_broken = true
	march_speed = 98.0
	spin_cooldown = 3.8
	slam_cooldown = 5.4
	_change_state(State.STAGGER)  # 护盾破碎，先硬直 2 秒

func _get_body_half_extents() -> Vector2:
	if body_collision != null:
		if body_collision.shape is RectangleShape2D:
			return (body_collision.shape as RectangleShape2D).size * 0.5
		if body_collision.shape is CircleShape2D:
			var radius: float = (body_collision.shape as CircleShape2D).radius
			return Vector2(radius, radius)
	return Vector2(19.0, 28.0)

func _check_contact_damage() -> void:
	if _contact_timer > 0.0 or _is_dead or not is_instance_valid(_player):
		return
	var extents: Vector2 = _get_body_half_extents()
	var x_dist: float = absf(_player.global_position.x - global_position.x)
	var y_dist: float = absf(_player.global_position.y - global_position.y)
	if x_dist <= extents.x + 16.0 and y_dist <= extents.y + 18.0:
		_player.take_damage(contact_damage, global_position, "冻结守卫碰撞")
		_contact_timer = contact_cooldown

func _hit_player_in_box(forward_range: float, half_height: float, damage: int, source_name: String) -> void:
	if not is_instance_valid(_player):
		return
	var offset: Vector2 = _player.global_position - global_position
	if offset.x * _facing < 0.0:
		return
	if absf(offset.x) <= forward_range and absf(offset.y) <= half_height:
		_player.take_damage(damage, global_position, source_name)

# ── 受击 / 死亡 ─────────────────────────────────────────────
func take_damage(amount: int, hit_pos: Vector2 = Vector2.ZERO) -> void:
	if _is_dead:
		return

	var actual: int = amount

	# 护盾：正面减伤 70%（只在 MARCH 状态且护盾未破碎）
	if not _shield_broken and state == State.MARCH and is_instance_valid(_player):
		var facing_right: bool = not sprite.flip_h
		var hit_from_front: bool = (hit_pos.x > global_position.x and facing_right) \
								or (hit_pos.x < global_position.x and not facing_right)
		if hit_from_front:
			actual = int(amount * 0.3)
	if actual > 0:
		GameManager.on_boss_hit()

	hp -= actual
	if hp <= 0:
		_die()
		return

	# 护盾中弹闪白，背刺或破盾后才产生硬直
	if sprite:
		var tween := create_tween()
		tween.tween_property(sprite, "modulate", Color(2, 2, 2), 0.05)
		tween.tween_property(sprite, "modulate", Color(1, 1, 1), 0.1)

	if _shield_broken or actual == amount:
		var dir: float = sign(global_position.x - (hit_pos.x if hit_pos != Vector2.ZERO else global_position.x - 1.0))
		velocity.x = dir * 100.0
		_change_state(State.HURT)

func _die() -> void:
	_is_dead = true
	_change_state(State.DEAD)
	march_area.monitoring = false
	spin_area.monitoring = false
	slam_area.monitoring = false
	_contact_timer = 0.0
	if _telegraph != null:
		_telegraph.hide_warning()
	GameManager.gain_exp(exp_reward)
	GameManager.drop_gold(150, get_parent(), global_position)
	GameManager.has_goggles_part = true   # 用于升级雪镜二级
	# 进化 #2 → 解锁后空翻（二段跳）+ 提升等级上限脳30
	GameManager.evolve()
	_spawn_boss_reward()
	GameManager.on_enemy_killed()
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.8)
	tween.tween_callback(queue_free)

func _spawn_boss_reward() -> void:
	var parent_node: Node = get_parent()
	if parent_node == null:
		return
	var reward: Area2D = _BOSS_REWARD_PICKUP_SCENE.instantiate()
	reward.reward_kind = 2
	reward.label_text = "雪镜升级零件"
	reward.launch_velocity = Vector2(0.0, -145.0)
	parent_node.add_child(reward)
	reward.global_position = global_position + Vector2(0.0, -14.0)

# ── Area 回调 ───────────────────────────────────────────────
func _on_detect_area_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player = body

func _on_detect_area_body_exited(body: Node) -> void:
	if body == _player:
		_player = null

func _on_march_area_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(march_damage, global_position, "冻结守卫冲撞")

func _on_spin_area_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(spin_damage, global_position, "冻结守卫旋斩")

func _on_slam_area_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(slam_damage, global_position, "冻结守卫跳砸")
