extends CharacterBody2D
# Boss 1 — 冰川雪豹
# 高机动性：扑跳冲击 + 近战抓击，死亡掉落「平行式滑雪」技能

const _PLACEHOLDER_VISUALS := preload("res://scripts/systems/BossPlaceholderVisuals.gd")
const _BOSS_ATTACK_TELEGRAPH := preload("res://scripts/systems/BossAttackTelegraph.gd")
const _BOSS_REWARD_PICKUP_SCENE := preload("res://scenes/systems/BossRewardPickup.tscn")

# ── Stats ──────────────────────────────────────────────────
@export var max_hp: int = 1000
@export var attack_damage: int = 20
@export var pounce_damage: int = 40
@export var move_speed: float = 76.0
@export var pounce_speed: float = 200.0
@export var pounce_height: float = -440.0  # 初速度（负=向上）
@export var gravity: float = 980.0
@export var detect_range: float = 500.0
@export var melee_range: float = 38.0
@export var pounce_range_min: float = 0.0
@export var pounce_range_max: float = 280.0
@export var pounce_cooldown: float = 4.0
@export var melee_cooldown: float = 3.0
@export var exp_reward: int = 1000
@export var attack_reach: float = 28.0
@export var attack_hitbox_size: Vector2 = Vector2(46.0, 32.0)
@export var arena_half_width: float = 140.0
@export var contact_damage: int = 30
@export var contact_cooldown: float = 0.75
@export var body_hitbox_size: Vector2 = Vector2(52.0, 42.0)
@export var pounce_hitbox_size: Vector2 = Vector2(68.0, 48.0)
@export var visual_scale: Vector2 = Vector2(1.14, 1.14)
@export var phase2_tint: Color = Color(1.35, 0.55, 0.55, 1.0)

var hp: int = max_hp
var _is_dead: bool = false
var _pounce_dir: float = 1.0
var _pounce_timer: float = 0.0   # 扑跳冷却
var _melee_timer: float = 0.0    # 爪击冷却
var _state_timer: float = 0.0    # 当前状态已用时间
var _phase2: bool = false         # hp <= 300 进入二阶段
var _facing: float = 1.0
var _home_position: Vector2 = Vector2.ZERO
var _arena_min_x: float = 0.0
var _arena_max_x: float = 0.0
var _contact_timer: float = 0.0

enum State { IDLE, APPROACH, POUNCE_WINDUP, POUNCE_AIR, RECOVER, MELEE_WINDUP, MELEE, HURT, DEAD }
var state: State = State.IDLE

@onready var sprite: Sprite2D = $Sprite2D
@onready var body_collision: CollisionShape2D = $CollisionShape2D
@onready var attack_area: Area2D = $AttackArea
@onready var pounce_area: Area2D = $PounceArea
@onready var detect_area: Area2D = $DetectArea

var _player: CharacterBody2D = null
var _telegraph: Node = null

func _ready() -> void:
	add_to_group("enemy")
	_ensure_placeholder_visuals()
	_telegraph = _BOSS_ATTACK_TELEGRAPH.new()
	add_child(_telegraph)
	attack_area.monitoring = false
	pounce_area.monitoring = false
	_home_position = global_position
	_arena_min_x = _home_position.x - arena_half_width
	_arena_max_x = _home_position.x + arena_half_width
	# 敌人体在 layer 3
	set_collision_layer_value(1, false)
	set_collision_layer_value(3, true)
	attack_area.set_collision_mask_value(1, false)
	attack_area.set_collision_mask_value(2, true)
	pounce_area.set_collision_mask_value(1, false)
	pounce_area.set_collision_mask_value(2, true)
	detect_area.set_collision_mask_value(1, false)
	detect_area.set_collision_mask_value(2, true)
	_apply_tuning()

func _ensure_placeholder_visuals() -> void:
	if sprite != null and sprite.texture == null:
		sprite.texture = _PLACEHOLDER_VISUALS.make_ice_lynx_body()

func _change_state(new_state: State) -> void:
	state = new_state
	_state_timer = 0.0

func _apply_tuning() -> void:
	if sprite != null:
		sprite.scale = visual_scale
	var attack_collision: CollisionShape2D = attack_area.get_node_or_null("AttackCollision")
	if attack_collision != null and attack_collision.shape is RectangleShape2D:
		(attack_collision.shape as RectangleShape2D).size = attack_hitbox_size
	if body_collision != null and body_collision.shape is RectangleShape2D:
		(body_collision.shape as RectangleShape2D).size = body_hitbox_size
	var pounce_collision: CollisionShape2D = pounce_area.get_node_or_null("PounceCollision")
	if pounce_collision != null and pounce_collision.shape is RectangleShape2D:
		(pounce_collision.shape as RectangleShape2D).size = pounce_hitbox_size
	var detect_collision: CollisionShape2D = detect_area.get_node_or_null("DetectCollision")
	if detect_collision != null and detect_collision.shape is CircleShape2D:
		(detect_collision.shape as CircleShape2D).radius = detect_range
	if sprite != null:
		sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
	_set_facing(1.0)

func _phase2_threshold_hp() -> int:
	return 300

func _enter_phase2() -> void:
	_phase2 = true
	pounce_cooldown = 4.0
	pounce_speed = 200.0
	if sprite != null:
		var tween: Tween = create_tween()
		tween.tween_property(sprite, "modulate", phase2_tint, 0.22)

func _get_melee_damage() -> int:
	return 30 if _phase2 else 20

func _get_pounce_damage() -> int:
	return pounce_damage

func _get_contact_damage() -> int:
	return contact_damage

func _set_facing(dir: float) -> void:
	if is_zero_approx(dir):
		return
	_facing = signf(dir)
	attack_area.position = Vector2(attack_reach * _facing, 0.0)
	if sprite != null:
		sprite.flip_h = _facing < 0.0

func _is_player_inside_arena() -> bool:
	return is_instance_valid(_player) and _player.global_position.x >= _arena_min_x and _player.global_position.x <= _arena_max_x

func _get_chase_target_x() -> float:
	if _is_player_inside_arena():
		return _player.global_position.x
	return _home_position.x

func _clamp_to_arena() -> void:
	var clamped_x: float = clampf(global_position.x, _arena_min_x, _arena_max_x)
	if not is_equal_approx(clamped_x, global_position.x):
		global_position.x = clamped_x
		velocity.x = 0.0

func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	_state_timer += delta
	_pounce_timer = max(_pounce_timer - delta, 0.0)
	_melee_timer = max(_melee_timer - delta, 0.0)

	# 重力
	if not is_on_floor():
		velocity.y += gravity * delta

	# 二阶段检测
	if not _phase2 and hp <= _phase2_threshold_hp():
		_enter_phase2()

	_contact_timer = max(_contact_timer - delta, 0.0)
	if _telegraph != null:
		_telegraph.hide_warning()

	match state:
		State.IDLE:
			velocity.x = 0.0
			if _player:
				_change_state(State.APPROACH)

		State.APPROACH:
			var target_x: float = _get_chase_target_x()
			var delta_x: float = target_x - global_position.x
			var dir: float = signf(delta_x)
			_set_facing(dir if not is_zero_approx(dir) else _facing)
			velocity.x = 0.0 if absf(delta_x) <= 6.0 else dir * move_speed
			var can_engage: bool = _is_player_inside_arena()
			var dist: float = global_position.distance_to(_player.global_position) if can_engage else INF
			var can_melee: bool = can_engage and dist <= melee_range and _melee_timer <= 0.0
			var can_pounce: bool = _phase2 and can_engage and dist >= pounce_range_min and dist <= pounce_range_max and _pounce_timer <= 0.0

			# 碰墙时跳跃避免卡死
			if is_on_wall() and is_on_floor():
				velocity.y = -420.0

			if can_melee and can_pounce:
				if randf() < 0.5:
					_change_state(State.MELEE_WINDUP)
				else:
					_pounce_dir = dir
					_set_facing(_pounce_dir)
					_change_state(State.POUNCE_WINDUP)
			elif can_melee:
				_change_state(State.MELEE_WINDUP)
			elif can_pounce:
				_pounce_dir = dir
				_set_facing(_pounce_dir)
				_change_state(State.POUNCE_WINDUP)

		State.POUNCE_WINDUP:
			velocity.x = 0.0
			if _telegraph != null:
				_telegraph.show_forward(_pounce_dir if not is_zero_approx(_pounce_dir) else _facing, 132.0, "扑击", -26.0)
			# 0.55s 蓄力后起跳
			if _state_timer >= 0.55:
				_set_facing(_pounce_dir)
				velocity.x = _pounce_dir * pounce_speed
				velocity.y = pounce_height
				pounce_area.monitoring = true
				_change_state(State.POUNCE_AIR)

		State.POUNCE_AIR:
			# 越过 0.12s 才判断落地（防止刚起跳就判为落地）
			if _state_timer > 0.12 and is_on_floor():
				pounce_area.monitoring = false
				_pounce_timer = pounce_cooldown
				_change_state(State.RECOVER)

		State.RECOVER:
			velocity.x = move_toward(velocity.x, 0.0, 600.0 * delta)
			if _state_timer >= 0.55:
				_change_state(State.APPROACH)

		State.MELEE_WINDUP:
			velocity.x = 0.0
			if _telegraph != null:
				_telegraph.show_forward(_facing, 82.0, "爪击", -20.0)
			if _state_timer >= 0.32:
				attack_area.monitoring = true
				_change_state(State.MELEE)

		State.MELEE:
			velocity.x = 0.0
			if _state_timer >= 0.25:
				attack_area.monitoring = false
				_melee_timer = melee_cooldown
				_change_state(State.APPROACH)

		State.HURT:
			if _state_timer >= 0.3:
				_change_state(State.APPROACH)

	move_and_slide()
	_clamp_to_arena()
	_check_contact_damage()
	if velocity.x != 0.0:
		_set_facing(velocity.x)

func _get_body_half_extents() -> Vector2:
	if body_collision != null:
		if body_collision.shape is RectangleShape2D:
			return (body_collision.shape as RectangleShape2D).size * 0.5
		if body_collision.shape is CircleShape2D:
			var radius: float = (body_collision.shape as CircleShape2D).radius
			return Vector2(radius, radius)
	return Vector2(22.0, 18.0)

func _check_contact_damage() -> void:
	if _contact_timer > 0.0 or _is_dead or not is_instance_valid(_player):
		return
	var extents: Vector2 = _get_body_half_extents()
	var x_dist: float = absf(_player.global_position.x - global_position.x)
	var y_dist: float = absf(_player.global_position.y - global_position.y)
	if x_dist <= extents.x + 16.0 and y_dist <= extents.y + 18.0:
		_player.take_damage(_get_contact_damage(), global_position, "冰川雪豹碰撞")
		_contact_timer = contact_cooldown

# ── 受击 / 死亡 ─────────────────────────────────────────────
func take_damage(amount: int, hit_pos: Vector2 = Vector2.ZERO) -> void:
	if _is_dead:
		return
	if amount > 0:
		GameManager.on_boss_hit()
	hp -= amount
	if hp <= 0:
		_die()
	else:
		if state != State.POUNCE_AIR:
			var dir: float = sign(global_position.x - (hit_pos.x if hit_pos != Vector2.ZERO else global_position.x - 1.0))
			velocity.x = dir * 120.0
			_set_facing(-dir)
			_change_state(State.HURT)

func _die() -> void:
	_is_dead = true
	_change_state(State.DEAD)
	attack_area.monitoring = false
	pounce_area.monitoring = false
	_contact_timer = 0.0
	if _telegraph != null:
		_telegraph.hide_warning()
	GameManager.gain_exp(exp_reward)
	GameManager.drop_gold(100, get_parent(), global_position)
	GameManager.has_suit_fragment = true   # 用于铁匠合成高级雪服
	# 进化 #1 → 解锁平行式滑雪 + 提升等级上限至20
	GameManager.evolve()
	_spawn_boss_rewards()
	GameManager.on_enemy_killed()
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.6)
	tween.tween_callback(queue_free)

func _spawn_boss_rewards() -> void:
	var parent_node: Node = get_parent()
	if parent_node == null:
		return
	var suit_reward: Area2D = _BOSS_REWARD_PICKUP_SCENE.instantiate()
	suit_reward.reward_kind = 1
	suit_reward.label_text = "雪服碎片"
	suit_reward.launch_velocity = Vector2(-85.0, -125.0)
	parent_node.add_child(suit_reward)
	suit_reward.global_position = global_position + Vector2(-20.0, -8.0)

	var skill_reward: Area2D = _BOSS_REWARD_PICKUP_SCENE.instantiate()
	skill_reward.reward_kind = 0
	skill_reward.label_text = "平行式滑雪"
	skill_reward.launch_velocity = Vector2(92.0, -138.0)
	parent_node.add_child(skill_reward)
	skill_reward.global_position = global_position + Vector2(22.0, -12.0)

# ── Area 回调 ───────────────────────────────────────────────
func _on_detect_area_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player = body
		if state == State.IDLE:
			_change_state(State.APPROACH)

func _on_detect_area_body_exited(body: Node) -> void:
	if body == _player:
		_player = null
		_change_state(State.IDLE)

func _on_attack_area_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(_get_melee_damage(), global_position, "冰川雪豹抓击")

func _on_pounce_area_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(_get_pounce_damage(), global_position, "冰川雪豹扑击")
