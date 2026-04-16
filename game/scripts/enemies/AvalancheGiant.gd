extends CharacterBody2D

const _PLACEHOLDER_VISUALS := preload("res://scripts/systems/BossPlaceholderVisuals.gd")
const _BOSS_ATTACK_TELEGRAPH := preload("res://scripts/systems/BossAttackTelegraph.gd")

@export var max_hp: int = 1020
@export var punch_damage: int = 34
@export var slam_damage: int = 46
@export var avalanche_damage: int = 30
@export var move_speed: float = 68.0
@export var gravity: float = 980.0
@export var detect_range: float = 620.0
@export var melee_range: float = 72.0
@export var slam_range: float = 220.0
@export var avalanche_range: float = 360.0
@export var slam_cooldown: float = 5.0
@export var avalanche_cooldown: float = 4.2
@export var exp_reward: int = 620
@export var gold_reward: int = 220
@export var contact_damage: int = 24
@export var contact_cooldown: float = 0.85
@export var sweep_damage: int = 28
@export var sweep_cooldown: float = 4.8

var hp: int = max_hp
var _is_dead: bool = false
var _phase2: bool = false
var _slam_timer: float = 2.4
var _avalanche_timer: float = 1.8
var _state_timer: float = 0.0
var _contact_timer: float = 0.0
var _facing: float = 1.0
var _sweep_timer: float = 2.2

enum State { IDLE, ROAM, PUNCH_WINDUP, PUNCH, SLAM_WINDUP, SLAM_AIR, SLAM_LAND, AVALANCHE_CAST, SWEEP_WINDUP, SWEEP, HURT, DEAD }
var state: State = State.IDLE

@onready var sprite: Sprite2D = $Sprite2D
@onready var body_collision: CollisionShape2D = $CollisionShape2D
@onready var punch_area: Area2D = $PunchArea
@onready var slam_area: Area2D = $SlamArea
@onready var avalanche_area: Area2D = $AvalancheArea
@onready var detect_area: Area2D = $DetectArea

var _player: CharacterBody2D = null
var _telegraph: Node = null

func _ready() -> void:
	add_to_group("enemy")
	_ensure_placeholder_visuals()
	_telegraph = _BOSS_ATTACK_TELEGRAPH.new()
	add_child(_telegraph)
	punch_area.monitoring = false
	slam_area.monitoring = false
	avalanche_area.monitoring = false
	set_collision_layer_value(1, false)
	set_collision_layer_value(3, true)
	punch_area.set_collision_mask_value(1, false)
	punch_area.set_collision_mask_value(2, true)
	slam_area.set_collision_mask_value(1, false)
	slam_area.set_collision_mask_value(2, true)
	avalanche_area.set_collision_mask_value(1, false)
	avalanche_area.set_collision_mask_value(2, true)
	detect_area.set_collision_mask_value(1, false)
	detect_area.set_collision_mask_value(2, true)
	hp = max_hp
	_set_facing(1.0)

func _ensure_placeholder_visuals() -> void:
	if sprite != null and sprite.texture == null:
		sprite.texture = _PLACEHOLDER_VISUALS.make_avalanche_giant_body()

func _change_state(new_state: State) -> void:
	state = new_state
	_state_timer = 0.0

func _set_facing(dir: float) -> void:
	if is_zero_approx(dir):
		return
	_facing = signf(dir)
	if sprite != null:
		sprite.flip_h = _facing < 0.0
	if punch_area != null:
		punch_area.position.x = 42.0 * _facing
	if avalanche_area != null:
		avalanche_area.position.x = 110.0 * _facing

func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	_state_timer += delta
	_slam_timer = max(_slam_timer - delta, 0.0)
	_avalanche_timer = max(_avalanche_timer - delta, 0.0)
	_sweep_timer = max(_sweep_timer - delta, 0.0)
	_contact_timer = max(_contact_timer - delta, 0.0)
	if _telegraph != null:
		_telegraph.hide_warning()

	if not is_on_floor():
		velocity.y += gravity * delta

	if not _phase2 and float(hp) / float(max_hp) <= 0.45:
		_phase2 = true
		slam_cooldown = 3.8
		avalanche_cooldown = 3.2
		move_speed = 80.0

	match state:
		State.IDLE:
			velocity.x = 0.0
			if is_instance_valid(_player):
				_change_state(State.ROAM)
		State.ROAM:
			_do_roam()
		State.PUNCH_WINDUP:
			velocity.x = 0.0
			if _telegraph != null:
				_telegraph.show_forward(_facing, 118.0, "重拳", -30.0)
			if _state_timer >= 0.4:
				punch_area.monitoring = true
				_change_state(State.PUNCH)
		State.PUNCH:
			velocity.x = 0.0
			if _state_timer >= 0.18:
				punch_area.monitoring = false
				_change_state(State.ROAM)
		State.SLAM_WINDUP:
			velocity.x = 0.0
			if _telegraph != null:
				_telegraph.show_zone(240.0, "践踏", 16.0)
			if _state_timer >= 0.6:
				velocity.y = -620.0
				_change_state(State.SLAM_AIR)
		State.SLAM_AIR:
			if _state_timer > 0.12 and is_on_floor():
				slam_area.monitoring = true
				_change_state(State.SLAM_LAND)
		State.SLAM_LAND:
			velocity.x = 0.0
			if _state_timer >= 0.4:
				slam_area.monitoring = false
				_slam_timer = slam_cooldown
				_change_state(State.ROAM)
		State.AVALANCHE_CAST:
			velocity.x = 0.0
			if _telegraph != null:
				_telegraph.show_forward(_facing, 230.0, "雪崩", -22.0)
			if _state_timer >= 0.75 and _state_timer < 0.82:
				avalanche_area.monitoring = true
			if _state_timer >= 1.18:
				avalanche_area.monitoring = false
				_avalanche_timer = avalanche_cooldown
				_change_state(State.ROAM)
		State.SWEEP_WINDUP:
			velocity.x = 0.0
			if _telegraph != null:
				_telegraph.show_forward(_facing, 188.0, "横扫", -20.0)
			if _state_timer >= 0.46:
				_hit_player_in_box(188.0, 52.0, sweep_damage, "雪崩巨人横扫")
				_sweep_timer = sweep_cooldown
				_change_state(State.SWEEP)
		State.SWEEP:
			velocity.x = 0.0
			if _state_timer >= 0.18:
				_change_state(State.ROAM)
		State.HURT:
			velocity.x = move_toward(velocity.x, 0.0, 420.0 * delta)
			if _state_timer >= 0.26:
				_change_state(State.ROAM)

	move_and_slide()
	_check_contact_damage()

	if velocity.x != 0.0:
		_set_facing(velocity.x)

func _do_roam() -> void:
	if not is_instance_valid(_player):
		velocity.x = 0.0
		_change_state(State.IDLE)
		return
	var dist: float = global_position.distance_to(_player.global_position)
	var dir: float = sign(_player.global_position.x - global_position.x)
	var x_dist: float = absf(_player.global_position.x - global_position.x)
	var y_dist: float = absf(_player.global_position.y - global_position.y)
	_set_facing(dir if not is_zero_approx(dir) else _facing)
	if x_dist <= melee_range and y_dist <= 64.0:
		_change_state(State.PUNCH_WINDUP)
		return
	if _sweep_timer <= 0.0 and x_dist >= 96.0 and x_dist <= 188.0 and y_dist <= 70.0:
		_change_state(State.SWEEP_WINDUP)
		return
	if _slam_timer <= 0.0 and dist <= slam_range:
		_change_state(State.SLAM_WINDUP)
		return
	if _avalanche_timer <= 0.0 and dist <= avalanche_range:
		_change_state(State.AVALANCHE_CAST)
		return
	if is_on_wall() and is_on_floor():
		velocity.y = -360.0
	velocity.x = dir * move_speed

func _get_body_half_extents() -> Vector2:
	if body_collision != null:
		if body_collision.shape is RectangleShape2D:
			return (body_collision.shape as RectangleShape2D).size * 0.5
		if body_collision.shape is CircleShape2D:
			var radius: float = (body_collision.shape as CircleShape2D).radius
			return Vector2(radius, radius)
	return Vector2(32.0, 46.0)

func _check_contact_damage() -> void:
	if _contact_timer > 0.0 or _is_dead or not is_instance_valid(_player):
		return
	var extents: Vector2 = _get_body_half_extents()
	var x_dist: float = absf(_player.global_position.x - global_position.x)
	var y_dist: float = absf(_player.global_position.y - global_position.y)
	if x_dist <= extents.x + 18.0 and y_dist <= extents.y + 18.0:
		_player.take_damage(contact_damage, global_position, "雪崩巨人碰撞")
		_contact_timer = contact_cooldown

func _hit_player_in_box(forward_range: float, half_height: float, damage: int, source_name: String) -> void:
	if not is_instance_valid(_player):
		return
	var offset: Vector2 = _player.global_position - global_position
	if offset.x * _facing < 0.0:
		return
	if absf(offset.x) <= forward_range and absf(offset.y) <= half_height:
		_player.take_damage(damage, global_position, source_name)

func take_damage(amount: int, hit_pos: Vector2 = Vector2.ZERO) -> void:
	if _is_dead:
		return
	if amount > 0:
		GameManager.on_boss_hit()
	hp -= amount
	if hp <= 0:
		_die()
		return
	if sprite != null:
		var tween: Tween = create_tween()
		tween.tween_property(sprite, "modulate", Color(2.0, 2.0, 2.0, 1.0), 0.05)
		tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.12)
	if state != State.SLAM_AIR:
		var dir: float = sign(global_position.x - (hit_pos.x if hit_pos != Vector2.ZERO else global_position.x - 1.0))
		velocity.x = dir * 90.0
		_change_state(State.HURT)

func _die() -> void:
	_is_dead = true
	_change_state(State.DEAD)
	punch_area.monitoring = false
	slam_area.monitoring = false
	avalanche_area.monitoring = false
	_contact_timer = 0.0
	if _telegraph != null:
		_telegraph.hide_warning()
	GameManager.gain_exp(exp_reward)
	GameManager.drop_gold(gold_reward, get_parent(), global_position)
	GameManager.evolve()
	GameManager.on_enemy_killed()
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	tween.tween_callback(queue_free)

func _on_detect_area_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player = body
		if state == State.IDLE:
			_change_state(State.ROAM)

func _on_detect_area_body_exited(body: Node) -> void:
	if body == _player:
		_player = null
		_change_state(State.IDLE)

func _on_punch_area_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(punch_damage, global_position, "雪崩巨人重拳")

func _on_slam_area_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(slam_damage, global_position, "雪崩巨人践踏")

func _on_avalanche_area_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(avalanche_damage, global_position, "雪崩巨人雪崩冲击")