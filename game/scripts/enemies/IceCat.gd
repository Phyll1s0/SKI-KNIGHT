extends CharacterBody2D

const _HIT_EFFECT := preload("res://scenes/effects/HitEffect.tscn")
const _PLACEHOLDER_VISUALS := preload("res://scripts/systems/BossPlaceholderVisuals.gd")
const _STAGE_SCALING := preload("res://scripts/systems/EnemyStageScaling.gd")

@export var max_hp: int = 56
@export var slash_damage: int = 12
@export var pounce_damage: int = 18
@export var move_speed: float = 125.0
@export var chase_speed: float = 220.0
@export var pounce_speed: float = 380.0
@export var pounce_height: float = -280.0
@export var gravity: float = 980.0
@export var patrol_range: float = 150.0
@export var detect_range: float = 280.0
@export var melee_range: float = 42.0
@export var pounce_range_min: float = 90.0
@export var pounce_range_max: float = 250.0
@export var pounce_cooldown: float = 1.8
@export var melee_cooldown: float = 0.8
@export var exp_reward: int = 20
@export var gold_min: int = 4
@export var gold_max: int = 6

var hp: int = max_hp
var _spawn_x: float = 0.0
var _patrol_dir: int = 1
var _pounce_timer: float = 0.0
var _melee_timer: float = 0.0
var _state_timer: float = 0.0
var _is_dead: bool = false

enum State { PATROL, CHASE, POUNCE_WINDUP, POUNCE_AIR, MELEE_WINDUP, MELEE, RECOVER, HURT, DEAD }
var state: State = State.PATROL

@onready var sprite: Sprite2D = $Sprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var pounce_area: Area2D = $PounceArea
@onready var detect_area: Area2D = $DetectArea

var _player: CharacterBody2D = null

func _ready() -> void:
	_apply_stage_scaling()
	_spawn_x = global_position.x
	add_to_group("enemy")
	_ensure_placeholder_visuals()
	attack_area.monitoring = false
	pounce_area.monitoring = false
	set_collision_layer_value(1, false)
	set_collision_layer_value(3, true)
	attack_area.set_collision_mask_value(1, false)
	attack_area.set_collision_mask_value(2, true)
	pounce_area.set_collision_mask_value(1, false)
	pounce_area.set_collision_mask_value(2, true)
	detect_area.set_collision_mask_value(1, false)
	detect_area.set_collision_mask_value(2, true)

func _apply_stage_scaling() -> void:
	var multiplier: int = _STAGE_SCALING.resolve_multiplier(self)
	if multiplier > 1:
		max_hp *= multiplier
		slash_damage *= multiplier
		pounce_damage *= multiplier
		exp_reward *= multiplier
		gold_min *= multiplier
		gold_max *= multiplier
	hp = max_hp

func _ensure_placeholder_visuals() -> void:
	if sprite != null and sprite.texture == null:
		sprite.texture = _PLACEHOLDER_VISUALS.make_ice_cat_body()

func _change_state(new_state: State) -> void:
	state = new_state
	_state_timer = 0.0

func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	_state_timer += delta
	_pounce_timer = max(_pounce_timer - delta, 0.0)
	_melee_timer = max(_melee_timer - delta, 0.0)

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
		State.POUNCE_WINDUP:
			velocity.x = 0.0
			if _state_timer >= 0.2:
				var dir: float = 1.0 if not is_instance_valid(_player) else sign(_player.global_position.x - global_position.x)
				velocity.x = dir * pounce_speed
				velocity.y = pounce_height
				pounce_area.monitoring = true
				_change_state(State.POUNCE_AIR)
		State.POUNCE_AIR:
			if _state_timer > 0.12 and is_on_floor():
				pounce_area.monitoring = false
				_pounce_timer = pounce_cooldown
				_change_state(State.RECOVER)
		State.MELEE_WINDUP:
			velocity.x = 0.0
			if _state_timer >= 0.12:
				attack_area.monitoring = true
				_change_state(State.MELEE)
		State.MELEE:
			velocity.x = 0.0
			if _state_timer >= 0.14:
				attack_area.monitoring = false
				_melee_timer = melee_cooldown
				_change_state(State.CHASE)
		State.RECOVER:
			velocity.x = move_toward(velocity.x, 0.0, 700.0 * delta)
			if _state_timer >= 0.3:
				_change_state(State.CHASE)
		State.HURT:
			velocity.x = move_toward(velocity.x, 0.0, 600.0 * delta)
			if _state_timer >= 0.2:
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
	if x_dist <= melee_range and y_dist <= 44.0 and _melee_timer <= 0.0:
		_change_state(State.MELEE_WINDUP)
		return
	if dist >= pounce_range_min and dist <= pounce_range_max and _pounce_timer <= 0.0:
		_change_state(State.POUNCE_WINDUP)
		return
	if is_on_wall() and is_on_floor():
		velocity.y = -280.0
	velocity.x = dir * chase_speed

func take_damage(amount: int, hit_pos: Vector2 = Vector2.ZERO) -> void:
	if _is_dead:
		return
	hp -= amount
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
	velocity.x = dir * 160.0
	pounce_area.monitoring = false
	attack_area.monitoring = false
	_change_state(State.HURT)

func _die() -> void:
	_is_dead = true
	state = State.DEAD
	attack_area.monitoring = false
	pounce_area.monitoring = false
	GameManager.gain_exp(exp_reward)
	var gold_amount: int = randi_range(gold_min, gold_max)
	GameManager.drop_gold(gold_amount, get_parent(), global_position)
	GameManager.on_enemy_killed()
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.45)
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
		body.take_damage(slash_damage, global_position, "冰猫撕咬")

func _on_pounce_area_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(pounce_damage, global_position, "冰猫扑袭")