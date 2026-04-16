extends CharacterBody2D
# 最终 Boss — 雪山之王
# 多阶段：
#   Phase 1 (hp > 50%): 冲锋 + 跳砸
#   Phase 2 (hp ≤ 50%): 增加暴风雪（散射冰球）+ 风暴冲击（击退玩家）

const _PLACEHOLDER_VISUALS := preload("res://scripts/systems/BossPlaceholderVisuals.gd")
const _BOSS_ATTACK_TELEGRAPH := preload("res://scripts/systems/BossAttackTelegraph.gd")

# ── Stats ──────────────────────────────────────────────────
@export var max_hp: int = 1380
@export var charge_damage: int = 38
@export var slam_damage: int = 52
@export var blizzard_damage: int = 22   # 每颗冰球伤害（PhaseII）
@export var wind_damage: int = 26
@export var charge_speed: float = 470.0
@export var move_speed: float = 84.0
@export var gravity: float = 980.0
@export var detect_range: float = 600.0
@export var charge_range: float = 420.0
@export var slam_range: float = 260.0
@export var blizzard_range: float = 400.0
@export var charge_cooldown: float = 4.5
@export var slam_cooldown: float = 6.5
@export var blizzard_cooldown: float = 5.5
@export var exp_reward: int = 800
@export var iceball_scene: PackedScene = preload("res://scenes/enemies/IceBall.tscn")
@export var contact_damage: int = 28
@export var contact_cooldown: float = 0.9
@export var cleave_damage: int = 34
@export var cleave_cooldown: float = 4.0

var hp: int = max_hp
var _is_dead: bool = false
var _phase2: bool = false
var _rage_triggered: bool = false
var _charge_dir: float = 1.0
var _charge_timer: float = 2.0
var _slam_timer: float = 4.0
var _blizzard_timer: float = 3.0
var _state_timer: float = 0.0
var _contact_timer: float = 0.0
var _facing: float = 1.0
var _cleave_timer: float = 1.8

enum State { IDLE, ROAM, CHARGE_WINDUP, CHARGING, CHARGE_STOP,
			 SLAM_WINDUP, SLAM_AIR, SLAM_LAND,
			 CLEAVE_WINDUP, CLEAVE,
			 BLIZZARD_CAST, WIND_BURST,
			 PHASE2_RAGE, HURT, DEAD }
var state: State = State.IDLE

@onready var sprite: Sprite2D = $Sprite2D
@onready var body_collision: CollisionShape2D = $CollisionShape2D
@onready var charge_area: Area2D = $ChargeArea
@onready var slam_area: Area2D = $SlamArea
@onready var wind_area: Area2D = $WindArea
@onready var detect_area: Area2D = $DetectArea
@onready var muzzle: Marker2D = $Muzzle

var _player: CharacterBody2D = null
var _telegraph: Node = null

func _ready() -> void:
	add_to_group("enemy")
	_ensure_placeholder_visuals()
	_telegraph = _BOSS_ATTACK_TELEGRAPH.new()
	add_child(_telegraph)
	charge_area.monitoring = false
	slam_area.monitoring = false
	wind_area.monitoring = false
	# 敌人体在 layer 3
	set_collision_layer_value(1, false)
	set_collision_layer_value(3, true)
	charge_area.set_collision_mask_value(1, false)
	charge_area.set_collision_mask_value(2, true)
	slam_area.set_collision_mask_value(1, false)
	slam_area.set_collision_mask_value(2, true)
	wind_area.set_collision_mask_value(1, false)
	wind_area.set_collision_mask_value(2, true)
	detect_area.set_collision_mask_value(1, false)
	detect_area.set_collision_mask_value(2, true)
	_set_facing(1.0)

func _ensure_placeholder_visuals() -> void:
	if sprite != null and sprite.texture == null:
		sprite.texture = _PLACEHOLDER_VISUALS.make_snow_king_body()

func _change_state(new_state: State) -> void:
	state = new_state
	_state_timer = 0.0

func _set_facing(dir: float) -> void:
	if is_zero_approx(dir):
		return
	_facing = signf(dir)
	if sprite != null:
		sprite.flip_h = _facing < 0.0
	if charge_area != null:
		charge_area.position.x = 38.0 * _facing
	if wind_area != null:
		wind_area.position.x = 92.0 * _facing
	if muzzle != null:
		muzzle.position.x = 30.0 * _facing

func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	_state_timer += delta
	_charge_timer = max(_charge_timer - delta, 0.0)
	_slam_timer = max(_slam_timer - delta, 0.0)
	_blizzard_timer = max(_blizzard_timer - delta, 0.0)
	_cleave_timer = max(_cleave_timer - delta, 0.0)
	_contact_timer = max(_contact_timer - delta, 0.0)
	if _telegraph != null:
		_telegraph.hide_warning()

	if not is_on_floor():
		velocity.y += gravity * delta

	# 二阶段触发
	if not _phase2 and float(hp) / float(max_hp) <= 0.5:
		_phase2 = true
		if not _rage_triggered:
			_rage_triggered = true
			_change_state(State.PHASE2_RAGE)
			return

	match state:
		State.IDLE:
			velocity.x = 0.0
			if _player:
				_change_state(State.ROAM)

		State.ROAM:
			_do_roam(delta)

		State.CHARGE_WINDUP:
			velocity.x = 0.0
			if _telegraph != null:
				_telegraph.show_forward(_charge_dir if not is_zero_approx(_charge_dir) else _facing, 168.0, "冲锋", -26.0)
			if _state_timer >= 0.78:
				_charge_dir = sign(_player.global_position.x - global_position.x) if is_instance_valid(_player) else _charge_dir
				_set_facing(_charge_dir)
				charge_area.monitoring = true
				velocity.x = _charge_dir * charge_speed
				_change_state(State.CHARGING)

		State.CHARGING:
			# 冲锋持续最多 1.8s，撞墙或超距立刻停
			if is_on_wall() or _state_timer >= 1.8:
				charge_area.monitoring = false
				velocity.x = 0.0
				_charge_timer = charge_cooldown
				_change_state(State.CHARGE_STOP)

		State.CHARGE_STOP:
			velocity.x = move_toward(velocity.x, 0.0, 800.0 * delta)
			if _state_timer >= 0.5:
				_change_state(State.ROAM)

		State.SLAM_WINDUP:
			velocity.x = 0.0
			if _telegraph != null:
				_telegraph.show_zone(320.0, "跳砸", 20.0)
			if _state_timer >= 0.65:
				velocity.y = -640.0
				_change_state(State.SLAM_AIR)

		State.SLAM_AIR:
			if _state_timer > 0.15 and is_on_floor():
				slam_area.monitoring = true
				_change_state(State.SLAM_LAND)

		State.SLAM_LAND:
			velocity.x = 0.0
			if _state_timer >= 0.5:
				slam_area.monitoring = false
				_slam_timer = slam_cooldown
				_change_state(State.ROAM)

		State.CLEAVE_WINDUP:
			velocity.x = 0.0
			if is_instance_valid(_player):
				_set_facing(_player.global_position.x - global_position.x)
			if _telegraph != null:
				_telegraph.show_forward(_facing, 172.0, "王斩", -20.0)
			if _state_timer >= 0.44:
				_hit_player_in_box(172.0, 52.0, cleave_damage, "雪山之王王斩")
				_cleave_timer = cleave_cooldown
				_change_state(State.CLEAVE)

		State.CLEAVE:
			velocity.x = 0.0
			if _state_timer >= 0.2:
				_change_state(State.ROAM)

		State.BLIZZARD_CAST:
			velocity.x = 0.0
			# 0.6s 吟唱后发射 5 颗扇形冰球
			if is_instance_valid(_player):
				_set_facing(_player.global_position.x - global_position.x)
			if _telegraph != null:
				_telegraph.show_forward(_facing, 190.0, "暴风雪", -28.0)
			if _state_timer >= 0.78 and _state_timer < 0.84:
				_fire_blizzard()
			if _state_timer >= 1.35:
				_blizzard_timer = blizzard_cooldown
				_change_state(State.ROAM)

		State.WIND_BURST:
			velocity.x = 0.0
			if is_instance_valid(_player):
				_set_facing(_player.global_position.x - global_position.x)
			if _telegraph != null:
				_telegraph.show_forward(_facing, 180.0, "风暴冲击", -18.0)
			if _state_timer >= 0.4 and _state_timer < 0.46:
				wind_area.monitoring = true
			if _state_timer >= 0.78:
				wind_area.monitoring = false
				_change_state(State.ROAM)

		State.PHASE2_RAGE:
			# 进入狂暴动画（站立硬直 1.5s，表示愤怒）
			velocity.x = 0.0
			if _state_timer >= 1.5:
				# 加速所有冷却
				charge_cooldown = 3.4
				slam_cooldown = 4.8
				blizzard_cooldown = 4.2
				charge_speed = 510.0
				_change_state(State.ROAM)

		State.HURT:
			if _state_timer >= 0.35:
				_change_state(State.ROAM)

	move_and_slide()
	_check_contact_damage()

	if velocity.x != 0.0:
		_set_facing(velocity.x)

func _do_roam(delta: float) -> void:
	if not is_instance_valid(_player):
		velocity.x = 0.0
		_change_state(State.IDLE)
		return

	var dist := global_position.distance_to(_player.global_position)
	var dir: float = sign(_player.global_position.x - global_position.x)
	var x_dist: float = absf(_player.global_position.x - global_position.x)
	var y_dist: float = absf(_player.global_position.y - global_position.y)
	_set_facing(dir if not is_zero_approx(dir) else _facing)
	if _cleave_timer <= 0.0 and x_dist <= 172.0 and y_dist <= 62.0:
		_change_state(State.CLEAVE_WINDUP)
		return

	# Phase 2 优先：暴风雪
	if _phase2 and _blizzard_timer <= 0.0 and dist <= blizzard_range:
		_change_state(State.BLIZZARD_CAST)
		return

	# Phase 2：随机风暴冲击（每次攻击间随机触发）
	if _phase2 and _slam_timer <= 1.0 and dist < 180.0:
		_change_state(State.WIND_BURST)
		return

	# 冲锋
	if _charge_timer <= 0.0 and dist >= 200.0 and dist <= charge_range:
		_change_state(State.CHARGE_WINDUP)
		return

	# 跳砸
	if _slam_timer <= 0.0 and dist <= slam_range:
		_change_state(State.SLAM_WINDUP)
		return

	# 普通走近
	velocity.x = dir * move_speed * (1.0 if dist > 80.0 else 0.0)

func _get_body_half_extents() -> Vector2:
	if body_collision != null:
		if body_collision.shape is RectangleShape2D:
			return (body_collision.shape as RectangleShape2D).size * 0.5
		if body_collision.shape is CircleShape2D:
			var radius: float = (body_collision.shape as CircleShape2D).radius
			return Vector2(radius, radius)
	return Vector2(26.0, 36.0)

func _check_contact_damage() -> void:
	if _contact_timer > 0.0 or _is_dead or not is_instance_valid(_player):
		return
	var extents: Vector2 = _get_body_half_extents()
	var x_dist: float = absf(_player.global_position.x - global_position.x)
	var y_dist: float = absf(_player.global_position.y - global_position.y)
	if x_dist <= extents.x + 18.0 and y_dist <= extents.y + 18.0:
		_player.take_damage(contact_damage, global_position, "雪山之王碰撞")
		_contact_timer = contact_cooldown

func _hit_player_in_box(forward_range: float, half_height: float, damage: int, source_name: String) -> void:
	if not is_instance_valid(_player):
		return
	var offset: Vector2 = _player.global_position - global_position
	if offset.x * _facing < 0.0:
		return
	if absf(offset.x) <= forward_range and absf(offset.y) <= half_height:
		_player.take_damage(damage, global_position, source_name)

# ── 发射暴风雪（5颗扇形）──────────────────────────────────
func _fire_blizzard() -> void:
	if not is_instance_valid(_player):
		return
	var base_dir: Vector2 = (_player.global_position - muzzle.global_position).normalized()
	var angles: Array[float] = [-40.0, -20.0, 0.0, 20.0, 40.0]
	for angle_deg in angles:
		var rotated_dir: Vector2 = base_dir.rotated(deg_to_rad(angle_deg))
		var ball: Node2D = iceball_scene.instantiate()
		ball.damage = blizzard_damage
		get_parent().add_child(ball)
		ball.global_position = muzzle.global_position
		ball.init(rotated_dir)

# ── 受击 / 死亡 ─────────────────────────────────────────────
func take_damage(amount: int, hit_pos: Vector2 = Vector2.ZERO) -> void:
	if _is_dead:
		return
	if amount > 0:
		GameManager.on_boss_hit()
	hp -= amount
	if hp <= 0:
		_die()
		return
	if sprite:
		var tween := create_tween()
		tween.tween_property(sprite, "modulate", Color(2, 2, 2), 0.05)
		tween.tween_property(sprite, "modulate", Color(1, 1, 1), 0.12)
	if state != State.CHARGING and state != State.SLAM_AIR:
		var dir: float = sign(global_position.x - (hit_pos.x if hit_pos != Vector2.ZERO else global_position.x - 1.0))
		velocity.x = dir * 80.0
		_change_state(State.HURT)

func _die() -> void:
	_is_dead = true
	_change_state(State.DEAD)
	charge_area.monitoring = false
	slam_area.monitoring = false
	wind_area.monitoring = false
	_contact_timer = 0.0
	if _telegraph != null:
		_telegraph.hide_warning()
	GameManager.gain_exp(exp_reward)
	GameManager.drop_gold(200, get_parent(), global_position)
	GameManager.on_enemy_killed()
	GameManager.complete_game()
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.2)
	tween.tween_callback(queue_free)

# ── Area 回调 ───────────────────────────────────────────────
func _on_detect_area_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player = body
		if state == State.IDLE:
			_change_state(State.ROAM)

func _on_detect_area_body_exited(body: Node) -> void:
	if body == _player:
		_player = null
		_change_state(State.IDLE)

func _on_charge_area_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(charge_damage, global_position, "雪山之王冲锋")

func _on_slam_area_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(slam_damage, global_position, "雪山之王跳砸")

func _on_wind_area_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(wind_damage, global_position, "雪山之王风暴冲击")
	# 强力击退
	if body is CharacterBody2D:
		var knock_dir: float = sign(body.global_position.x - global_position.x)
		body.velocity.x += knock_dir * 600.0
		body.velocity.y = -250.0
