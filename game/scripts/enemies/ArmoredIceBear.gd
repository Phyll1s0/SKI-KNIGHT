extends CharacterBody2D

const _HIT_EFFECT := preload("res://scenes/effects/HitEffect.tscn")
const _PLACEHOLDER_VISUALS := preload("res://scripts/systems/BossPlaceholderVisuals.gd")
const _STAGE_SCALING := preload("res://scripts/systems/EnemyStageScaling.gd")

@export var max_hp: int = 120
@export var swipe_damage: int = 20
@export var charge_damage: int = 28
@export var move_speed: float = 62.0
@export var charge_speed: float = 320.0
@export var gravity: float = 980.0
@export var patrol_range: float = 110.0
@export var detect_range: float = 360.0
@export var melee_range: float = 58.0
@export var charge_range_min: float = 120.0
@export var charge_range_max: float = 260.0
@export var charge_cooldown: float = 3.2
@export var exp_reward: int = 44
@export var gold_min: int = 8
@export var gold_max: int = 12

var hp: int = max_hp
var _spawn_x: float = 0.0
var _patrol_dir: int = 1
var _charge_timer: float = 1.6
var _state_timer: float = 0.0
var _is_dead: bool = false

enum State { PATROL, CHASE, CHARGE_WINDUP, CHARGING, CHARGE_STOP, SWIPE_WINDUP, SWIPE, HURT, DEAD }
var state: State = State.PATROL

@onready var sprite: Sprite2D = $Sprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var charge_area: Area2D = $ChargeArea
@onready var detect_area: Area2D = $DetectArea

var _player: CharacterBody2D = null

func _ready() -> void:
	_apply_stage_scaling()
	_spawn_x = global_position.x
	add_to_group("enemy")
	_ensure_placeholder_visuals()
	attack_area.monitoring = false
	charge_area.monitoring = false
	set_collision_layer_value(1, false)
	set_collision_layer_value(3, true)
	attack_area.set_collision_mask_value(1, false)
	attack_area.set_collision_mask_value(2, true)
	charge_area.set_collision_mask_value(1, false)
	charge_area.set_collision_mask_value(2, true)
	detect_area.set_collision_mask_value(1, false)
	detect_area.set_collision_mask_value(2, true)

func _apply_stage_scaling() -> void:
	var multiplier: int = _STAGE_SCALING.resolve_multiplier(self)
	if multiplier > 1:
		max_hp *= multiplier
		swipe_damage *= multiplier
		charge_damage *= multiplier
		exp_reward *= multiplier
		gold_min *= multiplier
		gold_max *= multiplier
	hp = max_hp

func _ensure_placeholder_visuals() -> void:
	if sprite != null and sprite.texture == null:
		sprite.texture = _PLACEHOLDER_VISUALS.make_armored_ice_bear_body()

func _change_state(new_state: State) -> void:
	state = new_state
	_state_timer = 0.0

func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	_state_timer += delta
	_charge_timer = max(_charge_timer - delta, 0.0)

	if not is_instance_valid(_player):
		for node in get_tree().get_nodes_in_group("player"):
			if global_position.distance_to(node.global_position) <= detect_range:
				_player = node
				break

	if not is_on_floor():
		velocity.y += gravity * delta

	match state:
		State.PATROL:
			_do_patrol()
		State.CHASE:
			_do_chase()
		State.CHARGE_WINDUP:
			velocity.x = 0.0
			if _state_timer >= 0.35:
				var dir: float = 1.0 if not is_instance_valid(_player) else sign(_player.global_position.x - global_position.x)
				charge_area.monitoring = true
				velocity.x = dir * charge_speed
				_change_state(State.CHARGING)
		State.CHARGING:
			if is_on_wall() or _state_timer >= 0.7:
				charge_area.monitoring = false
				_charge_timer = charge_cooldown
				_change_state(State.CHARGE_STOP)
		State.CHARGE_STOP:
			velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
			if _state_timer >= 0.35:
				_change_state(State.CHASE)
		State.SWIPE_WINDUP:
			velocity.x = 0.0
			if _state_timer >= 0.25:
				attack_area.monitoring = true
				_change_state(State.SWIPE)
		State.SWIPE:
			velocity.x = 0.0
			if _state_timer >= 0.18:
				attack_area.monitoring = false
				_change_state(State.CHASE)
		State.HURT:
			velocity.x = move_toward(velocity.x, 0.0, 650.0 * delta)
			if _state_timer >= 0.24:
				_change_state(State.CHASE)

	move_and_slide()

	if sprite != null and velocity.x != 0.0:
		sprite.flip_h = velocity.x < 0.0

func _do_patrol() -> void:
	velocity.x = move_speed * _patrol_dir
	var dist_from_spawn: float = global_position.x - _spawn_x
	if dist_from_spawn > patrol_range or dist_from_spawn < -patrol_range or is_on_wall():
		_patrol_dir *= -1
	if is_instance_valid(_player) and global_position.distance_to(_player.global_position) <= detect_range:
		_change_state(State.CHASE)

func _do_chase() -> void:
	if not is_instance_valid(_player):
		_change_state(State.PATROL)
		return
	var dist: float = global_position.distance_to(_player.global_position)
	if dist > detect_range * 1.5:
		_player = null
		_change_state(State.PATROL)
		return
	var dir: float = sign(_player.global_position.x - global_position.x)
	var x_dist: float = absf(_player.global_position.x - global_position.x)
	var y_dist: float = absf(_player.global_position.y - global_position.y)
	if x_dist <= melee_range and y_dist <= 56.0:
		_change_state(State.SWIPE_WINDUP)
		return
	if dist >= charge_range_min and dist <= charge_range_max and _charge_timer <= 0.0:
		_change_state(State.CHARGE_WINDUP)
		return
	if is_on_wall() and is_on_floor():
		velocity.y = -260.0
	velocity.x = dir * move_speed

func take_damage(amount: int, hit_pos: Vector2 = Vector2.ZERO) -> void:
	if _is_dead:
		return
	var actual: int = amount
	if sprite != null:
		var facing_right: bool = not sprite.flip_h
		var hit_from_front: bool = (hit_pos.x > global_position.x and facing_right) \
			or (hit_pos.x < global_position.x and not facing_right)
		if hit_from_front and state != State.CHARGING:
			actual = max(1, int(round(amount * 0.6)))
	hp -= actual
	var fx: GPUParticles2D = _HIT_EFFECT.instantiate()
	get_parent().add_child(fx)
	fx.global_position = global_position
	fx.emitting = true
	var timer: SceneTreeTimer = get_tree().create_timer(0.5)
	timer.timeout.connect(func(): if is_instance_valid(fx): fx.queue_free())
	if hp <= 0:
		_die()
		return
	var dir: float = sign(global_position.x - (hit_pos.x if hit_pos != Vector2.ZERO else global_position.x - 1.0))
	velocity.x = dir * 130.0
	attack_area.monitoring = false
	charge_area.monitoring = false
	_change_state(State.HURT)

func _die() -> void:
	_is_dead = true
	state = State.DEAD
	attack_area.monitoring = false
	charge_area.monitoring = false
	GameManager.gain_exp(exp_reward)
	var gold_amount: int = randi_range(gold_min, gold_max)
	GameManager.drop_gold(gold_amount, get_parent(), global_position)
	GameManager.on_enemy_killed()
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.6)
	tween.tween_callback(queue_free)

func _on_detect_area_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player = body
		if state == State.PATROL:
			_change_state(State.CHASE)

func _on_detect_area_body_exited(body: Node) -> void:
	if body == _player:
		_player = null
		_change_state(State.PATROL)

func _on_attack_area_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(swipe_damage, global_position, "铠甲冰熊爪击")

func _on_charge_area_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(charge_damage, global_position, "铠甲冰熊冲撞")