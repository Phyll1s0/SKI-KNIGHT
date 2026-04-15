extends CharacterBody2D
# Boss 1 — 冰川雪豹
# 高机动性：扑跳冲击 + 近战抓击，死亡掉落「平行式滑雪」技能

# ── Stats ──────────────────────────────────────────────────
@export var max_hp: int = 320
@export var attack_damage: int = 20
@export var pounce_damage: int = 28
@export var move_speed: float = 115.0
@export var pounce_speed: float = 440.0
@export var pounce_height: float = -440.0  # 初速度（负=向上）
@export var gravity: float = 980.0
@export var detect_range: float = 500.0
@export var melee_range: float = 58.0
@export var pounce_range_min: float = 150.0
@export var pounce_range_max: float = 460.0
@export var pounce_cooldown: float = 3.0
@export var exp_reward: int = 220

var hp: int = max_hp
var _is_dead: bool = false
var _pounce_dir: float = 1.0
var _pounce_timer: float = 0.0   # 扑跳冷却
var _state_timer: float = 0.0    # 当前状态已用时间
var _phase2: bool = false         # hp < 50% 进入二阶段

enum State { IDLE, APPROACH, POUNCE_WINDUP, POUNCE_AIR, RECOVER, MELEE_WINDUP, MELEE, HURT, DEAD }
var state: State = State.IDLE

@onready var sprite: Sprite2D = $Sprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var pounce_area: Area2D = $PounceArea
@onready var detect_area: Area2D = $DetectArea

var _player: CharacterBody2D = null

func _ready() -> void:
	add_to_group("enemy")
	attack_area.monitoring = false
	pounce_area.monitoring = false
	# 敌人体在 layer 3
	set_collision_layer_value(1, false)
	set_collision_layer_value(3, true)
	attack_area.set_collision_mask_value(1, false)
	attack_area.set_collision_mask_value(2, true)
	pounce_area.set_collision_mask_value(1, false)
	pounce_area.set_collision_mask_value(2, true)
	detect_area.set_collision_mask_value(1, false)
	detect_area.set_collision_mask_value(2, true)

func _change_state(new_state: State) -> void:
	state = new_state
	_state_timer = 0.0

func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	_state_timer += delta
	_pounce_timer = max(_pounce_timer - delta, 0.0)

	# 重力
	if not is_on_floor():
		velocity.y += gravity * delta

	# 二阶段检测
	if not _phase2 and float(hp) / float(max_hp) < 0.5:
		_phase2 = true
		pounce_cooldown = 1.8
		pounce_speed = 560.0

	match state:
		State.IDLE:
			velocity.x = 0.0
			if _player:
				_change_state(State.APPROACH)

		State.APPROACH:
			if not is_instance_valid(_player):
				_change_state(State.IDLE)
				return
			var dist := global_position.distance_to(_player.global_position)
			var dir: float = sign(_player.global_position.x - global_position.x)
			velocity.x = dir * move_speed

			# 碰墙时跳跃避免卡死
			if is_on_wall() and is_on_floor():
				velocity.y = -420.0

			if dist <= melee_range:
				_change_state(State.MELEE_WINDUP)
			elif dist >= pounce_range_min and dist <= pounce_range_max and _pounce_timer <= 0.0:
				_pounce_dir = dir
				_change_state(State.POUNCE_WINDUP)

		State.POUNCE_WINDUP:
			velocity.x = 0.0
			# 0.35s 蓄力后起跳
			if _state_timer >= 0.35:
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
			if _state_timer >= 0.2:
				attack_area.monitoring = true
				_change_state(State.MELEE)

		State.MELEE:
			velocity.x = 0.0
			if _state_timer >= 0.25:
				attack_area.monitoring = false
				_change_state(State.APPROACH)

		State.HURT:
			if _state_timer >= 0.3:
				_change_state(State.APPROACH)

	move_and_slide()

	if sprite and velocity.x != 0:
		sprite.flip_h = velocity.x < 0

# ── 受击 / 死亡 ─────────────────────────────────────────────
func take_damage(amount: int, hit_pos: Vector2 = Vector2.ZERO) -> void:
	if _is_dead:
		return
	hp -= amount
	if hp <= 0:
		_die()
	else:
		if state != State.POUNCE_AIR:
			var dir: float = sign(global_position.x - (hit_pos.x if hit_pos != Vector2.ZERO else global_position.x - 1.0))
			velocity.x = dir * 120.0
			_change_state(State.HURT)

func _die() -> void:
	_is_dead = true
	_change_state(State.DEAD)
	attack_area.monitoring = false
	pounce_area.monitoring = false
	GameManager.gain_exp(exp_reward)
	GameManager.add_gold(80)
	GameManager.has_suit_fragment = true   # 用于铁匠合成高级雪服
	# 进化 #1 → 解锁平行式滑雪 + 提升等级上限至20
	GameManager.evolve()
	GameManager.on_enemy_killed()
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.6)
	tween.tween_callback(queue_free)

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
		body.take_damage(attack_damage, global_position)

func _on_pounce_area_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(pounce_damage, global_position)
