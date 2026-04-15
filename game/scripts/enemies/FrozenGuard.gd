extends CharacterBody2D
# Boss 2 — 冻结守卫
# 防御型：正面护盾减伤，旋转斩 + 跳砸，死亡掉落「雪镜二级」

# ── Stats ──────────────────────────────────────────────────
@export var max_hp: int = 400
@export var march_damage: int = 16
@export var spin_damage: int = 22
@export var slam_damage: int = 38
@export var march_speed: float = 72.0
@export var gravity: float = 980.0
@export var detect_range: float = 500.0
@export var spin_range: float = 300.0
@export var slam_range: float = 240.0
@export var spin_cooldown: float = 4.8
@export var slam_cooldown: float = 6.5
@export var exp_reward: int = 330

var hp: int = max_hp
var _is_dead: bool = false
var _shield_broken: bool = false
var _phase2: bool = false
var _spin_timer: float = 2.0    # 初始冷却，防止开场立刻旋转
var _slam_timer: float = 4.0
var _state_timer: float = 0.0

enum State { MARCH, SPIN_WINDUP, SPINNING, SLAM_WINDUP, SLAM_AIR, SLAM_LAND, STAGGER, HURT, DEAD }
var state: State = State.MARCH

@onready var sprite: Sprite2D = $Sprite2D
@onready var shield_sprite: Sprite2D = $ShieldSprite
@onready var march_area: Area2D = $MarchArea
@onready var spin_area: Area2D = $SpinArea
@onready var slam_area: Area2D = $SlamArea
@onready var detect_area: Area2D = $DetectArea

var _player: CharacterBody2D = null

func _ready() -> void:
	add_to_group("enemy")
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

func _change_state(new_state: State) -> void:
	state = new_state
	_state_timer = 0.0

func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	_state_timer += delta
	_spin_timer = max(_spin_timer - delta, 0.0)
	_slam_timer = max(_slam_timer - delta, 0.0)

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
			if _state_timer >= 0.5:
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
			if _state_timer >= 0.4:
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

		State.STAGGER:
			velocity.x = move_toward(velocity.x, 0.0, 400.0 * delta)
			if _state_timer >= (_phase2_stagger_time if _phase2 else 0.5):
				_change_state(State.MARCH)

		State.HURT:
			if _state_timer >= 0.25:
				_change_state(State.MARCH)

	move_and_slide()

	if sprite and velocity.x != 0:
		sprite.flip_h = velocity.x < 0
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
	var spd: float = march_speed * (1.4 if _phase2 else 1.0)
	velocity.x = dir * spd

	# 碰墙时跳跃避免卡死
	if is_on_wall() and is_on_floor():
		velocity.y = -500.0

	# 近战推进
	march_area.monitoring = dist <= 70.0

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
	march_speed = 130.0
	spin_cooldown = 3.5
	slam_cooldown = 5.0
	_change_state(State.STAGGER)  # 护盾破碎，先硬直 2 秒

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
	GameManager.gain_exp(exp_reward)
	GameManager.add_gold(120)
	GameManager.has_goggles_part = true   # 用于升级雪镜二级
	# 进化 #2 → 解锁后空翻（二段跳）+ 提升等级上限脳30
	GameManager.evolve()
	GameManager.on_enemy_killed()
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.8)
	tween.tween_callback(queue_free)

# ── Area 回调 ───────────────────────────────────────────────
func _on_detect_area_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player = body

func _on_detect_area_body_exited(body: Node) -> void:
	if body == _player:
		_player = null

func _on_march_area_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(march_damage, global_position)

func _on_spin_area_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(spin_damage, global_position)

func _on_slam_area_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(slam_damage, global_position)
