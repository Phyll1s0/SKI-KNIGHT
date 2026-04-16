extends CharacterBody2D

const _HIT_EFFECT := preload("res://scenes/effects/HitEffect.tscn")
const _STAGE_SCALING := preload("res://scripts/systems/EnemyStageScaling.gd")

# ── Stats ──────────────────────────────────────────────────
@export var max_hp: int = 80
@export var attack_damage: int = 16
@export var move_speed: float = 85.0
@export var chase_speed: float = 150.0
@export var gravity: float = 980.0
@export var patrol_range: float = 130.0   # pixels from spawn
@export var detect_range: float = 240.0   # aggro radius
@export var attack_range: float = 65.0    # melee reach
@export var attack_cooldown: float = 0.95
@export var exp_reward: int = 30
@export var gold_min: int = 1
@export var gold_max: int = 2

var hp: int = max_hp
var _spawn_x: float = 0.0
var _patrol_dir: int = 1
var _attack_timer: float = 0.0
var _contact_timer: float = 0.0   # 接触伤害冷却
var _is_dead: bool = false

# State machine
enum State { PATROL, CHASE, ATTACK, HURT, DEAD }
var state: State = State.PATROL

@onready var sprite: Sprite2D = $Sprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var detect_area: Area2D = $DetectArea

var _player: CharacterBody2D = null

const _ANIM_FRAMES := {"walk": 0, "attack": 1, "hurt": 2, "dead": 3}

func _set_frame(anim_name: String) -> void:
	if sprite and _ANIM_FRAMES.has(anim_name):
		sprite.frame = _ANIM_FRAMES[anim_name]

func _ready() -> void:
	_apply_stage_scaling()
	add_to_group("enemy")
	_spawn_x = global_position.x
	attack_area.monitoring = false
	# 敌人体在 layer 3，玩家可穿透；Area2D 改为检测 layer 2（玩家）
	set_collision_layer_value(1, false)
	set_collision_layer_value(3, true)
	attack_area.set_collision_mask_value(1, false)
	attack_area.set_collision_mask_value(2, true)
	detect_area.set_collision_mask_value(1, false)
	detect_area.set_collision_mask_value(2, true)

func _apply_stage_scaling() -> void:
	var multiplier: int = _STAGE_SCALING.resolve_multiplier(self)
	if multiplier > 1:
		max_hp *= multiplier
		attack_damage *= multiplier
		exp_reward *= multiplier
		gold_min *= multiplier
		gold_max *= multiplier
	hp = max_hp

func _physics_process(delta: float) -> void:
	if _is_dead:
		return
	_attack_timer = max(_attack_timer - delta, 0.0)
	_contact_timer = max(_contact_timer - delta, 0.0)

	# 保底玩家检测
	if not is_instance_valid(_player):
		for node in get_tree().get_nodes_in_group("player"):
			if global_position.distance_to(node.global_position) <= detect_range:
				_player = node
				break

	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	match state:
		State.PATROL:
			_do_patrol(delta)
		State.CHASE:
			_do_chase(delta)
		State.ATTACK:
			_do_attack()

	move_and_slide()
	_check_contact_damage()

	# Flip sprite to face movement direction
	if sprite and velocity.x != 0:
		sprite.flip_h = velocity.x < 0

# ── Patrol ─────────────────────────────────────────────────
func _do_patrol(delta: float) -> void:
	_set_frame("walk")
	velocity.x = move_speed * _patrol_dir

	# Reverse at patrol boundary or wall
	var dist_from_spawn := global_position.x - _spawn_x
	if dist_from_spawn > patrol_range or (dist_from_spawn < -patrol_range):
		_patrol_dir *= -1
	if is_on_wall():
		_patrol_dir *= -1

	# Check for player in detect range
	if _player and global_position.distance_to(_player.global_position) <= detect_range:
		state = State.CHASE

# ── Chase ──────────────────────────────────────────────────
func _do_chase(delta: float) -> void:
	_set_frame("walk")
	if not is_instance_valid(_player):
		state = State.PATROL
		return

	var dist := global_position.distance_to(_player.global_position)

	# Lost player
	if dist > detect_range * 1.5:
		state = State.PATROL
		return

	# In attack range — 只比较横向距离，且纵向距离不超过50px
	var x_dist := absf(_player.global_position.x - global_position.x)
	var y_dist := absf(_player.global_position.y - global_position.y)
	if x_dist <= attack_range * 0.7 and y_dist <= 50.0 and _attack_timer <= 0.0:
		state = State.ATTACK
		return

	# 碰墙时跳跃避免卡死
	if is_on_wall() and is_on_floor():
		velocity.y = -380.0

	var dir: float = sign(_player.global_position.x - global_position.x)
	velocity.x = dir * chase_speed

# ── Attack ─────────────────────────────────────────────────
func _do_attack() -> void:
	_set_frame("attack")
	velocity.x = 0.0
	if _attack_timer > 0.0:
		state = State.CHASE
		return

	_attack_timer = attack_cooldown
	# 直接距离判断，不依赖 Area2D body_entered
	if is_instance_valid(_player):
		var x_dist := absf(_player.global_position.x - global_position.x)
		var y_dist := absf(_player.global_position.y - global_position.y)
		if x_dist <= attack_range * 0.7 and y_dist <= 50.0:
			_player.take_damage(attack_damage, global_position, "雪人近战")

	var t: SceneTreeTimer = get_tree().create_timer(0.4)
	t.timeout.connect(func():
		if state == State.ATTACK:
			state = State.CHASE
	)

# ── Contact damage ─────────────────────────────────────────
# 玩家直接撞到怪物身体时扣血（接触伤害，有冷却）
func _check_contact_damage() -> void:
	if _contact_timer > 0.0 or _is_dead:
		return
	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		var body := col.get_collider()
		if body != null and body.is_in_group("player"):
			body.take_damage(attack_damage, global_position, "雪人碰撞")
			_contact_timer = 0.8
			break

# ── Damage / Death ─────────────────────────────────────────
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
	if hp <= 0:
		_die()
	else:
		_set_frame("hurt")
		# Brief stagger: push back
		var dir: float = sign(global_position.x - (_hit_pos.x if _hit_pos != Vector2.ZERO else global_position.x - 1.0))
		velocity.x = dir * 150.0

func _die() -> void:
	_is_dead = true
	state = State.DEAD
	_set_frame("dead")
	GameManager.gain_exp(exp_reward)
	var gold_amount: int = randi_range(gold_min, gold_max)
	GameManager.drop_gold(gold_amount, get_parent(), global_position)
	GameManager.on_enemy_killed()
	# Fade out then free
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)

# ── Detect area callbacks ───────────────────────────────────
func _on_detect_area_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player = body
		if state == State.PATROL:
			state = State.CHASE

func _on_detect_area_body_exited(body: Node) -> void:
	if body == _player:
		_player = null
		state = State.PATROL

# ── Attack hit callback ────────────────────────────────────
func _on_attack_area_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(attack_damage, global_position, "雪人攻击区域")
