extends CharacterBody2D

# ── Stats ──────────────────────────────────────────────────
@export var max_hp: int = 100
var hp: int = max_hp

# ── Movement ───────────────────────────────────────────────
@export var walk_speed: float = 190.0      # 仅用于空中横向控制上限
@export var ski_accel: float = 440.0       # 地面加速度
@export var ski_friction: float = 180.0    # 平地滑行减速度（冰雪摩擦）
@export var air_friction: float = 45.0
@export var max_ski_speed: float = 620.0
@export var jump_force: float = -540.0
@export var gravity: float = 980.0

# ── Attack ─────────────────────────────────────────────────
@export var attack_damage: int = 20
@export var attack_cooldown: float = 0.55
@export var attack_forward_reach: float = 90.0
@export var attack_vertical_size: float = 40.0

var _attack_timer: float = 0.0
var _is_attacking: bool = false

# ── Ice Blade skill ────────────────────────────────────────
@export var ice_blade_damage: int = 20
@export var ice_blade_cooldown: float = 0.8
var _skill_timer: float = 0.0
const ICE_BLADE_SCENE := preload("res://scenes/player/IceBlade.tscn")
const _ATTACK_TRAIL := preload("res://scenes/effects/AttackTrail.tscn")
const _EQUIPMENT_PICKUP_SCENE := preload("res://scenes/systems/EquipmentPickup.tscn")

# ── Hit / invincibility ────────────────────────────────────
@export var invincible_duration: float = 1.2
@export var knockback_force: float = 200.0
@export var log_damage_sources: bool = true
var _invincible_timer: float = 0.0
var _is_dead: bool = false
var _respawn_grace: bool = false  # 复活无敌期间不播 hurt 动画

# ── State ──────────────────────────────────────────────────
var _on_slope: bool = false
var _slope_normal: Vector2 = Vector2.UP
var _on_uphill: bool = false   # 正在上坡（走路动画 而非滑雪）
var _facing: int = 1   # 1 = right, -1 = left
var _debug_frame: int = 0
var _last_safe_position: Vector2 = Vector2.ZERO
var _attack_hit_bodies: Dictionary = {}

# 冲撞速度阈值：超过此速度时攻击会触发冲撞伤害加成
@export var collision_speed_threshold: float = 350.0
@export var helmet_collision_forward_range: float = 56.0
@export var helmet_collision_vertical_range: float = 52.0
var _helmet_query_shape: RectangleShape2D = RectangleShape2D.new()

# ── Node refs ──────────────────────────────────────────────
@onready var sprite: Sprite2D = $Sprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_collision: CollisionShape2D = $AttackArea/AttackCollision
var anim: AnimationPlayer = null   # 等美术资源就绪后接入

func _ready() -> void:
	add_to_group("player")
	attack_area.monitoring = false
	GameManager.hp_changed.connect(_on_game_hp_changed)
	# 从 GameManager 同步 HP，确保跨地图 HP 保留
	_on_game_hp_changed(GameManager.player_hp, GameManager.player_max_hp)
	anim = get_node_or_null("AnimationPlayer")
	EquipmentManager.equipment_changed.connect(_on_equipment_changed)
	_apply_equipment_stats()
	# 玩家在 layer 2，不与敌人体 (layer 3) 发生物理碰撞
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, true)
	attack_area.set_collision_mask_value(1, false)
	attack_area.set_collision_mask_value(3, true)
	_update_attack_hitbox()
	_last_safe_position = global_position
	print("[Player] _ready OK pos=", global_position)

func _on_game_hp_changed(current: int, maximum: int) -> void:
	max_hp = maximum
	hp = current
	attack_damage = GameManager.player_attack
	ice_blade_damage = GameManager.player_attack

func _on_equipment_changed(_slot: int, _level: int) -> void:
	_apply_equipment_stats()

func _apply_equipment_stats() -> void:
	# 雪板升级：最高速度加成；叠加平行式滑雪技能
	max_ski_speed = 600.0 + EquipmentManager.max_speed_bonus() + SkillManager.parallel_speed_bonus()
	# 攻击框位置随雪镜距离加成更新（在攻击时动态取）
	_update_attack_hitbox()

func _update_attack_hitbox() -> void:
	if attack_collision == null or attack_collision.shape == null:
		return
	var range_bonus: float = EquipmentManager.attack_range_bonus()
	var forward_reach: float = attack_forward_reach * (1.0 + range_bonus)
	var backward_reach: float = forward_reach * 0.1
	var total_width: float = forward_reach + backward_reach
	var center_offset: float = (forward_reach - backward_reach) * 0.5
	var shape: RectangleShape2D = attack_collision.shape as RectangleShape2D
	if shape != null:
		shape.size = Vector2(total_width, attack_vertical_size)
	attack_area.position = Vector2(center_offset * _facing, 0.0)

func _get_attack_damage_value() -> int:
	return int(round(float(attack_damage) * (1.0 + EquipmentManager.attack_damage_bonus())))

func _get_ice_blade_damage_value() -> int:
	return int(round(float(ice_blade_damage) * (1.0 + EquipmentManager.attack_damage_bonus())))

func _physics_process(delta: float) -> void:
	if _is_dead:
		return
	# 掉坑死亡：y > 1100则立即死亡
	if global_position.y > 1100:
		die(true)
		return
	_attack_timer = max(_attack_timer - delta, 0.0)
	var _prev_inv := _invincible_timer
	_invincible_timer = max(_invincible_timer - delta, 0.0)
	if _prev_inv > 0.0 and _invincible_timer == 0.0:
		_respawn_grace = false

	_apply_gravity(delta)
	_handle_movement(delta)
	_handle_jump()
	_handle_attack()
	_handle_skill(delta)

	move_and_slide()
	if is_on_floor():
		_last_safe_position = global_position
	_handle_body_collision()   # 头盔撞击伤害
	_update_slope_info()
	_update_sprite()
	# 每60帧打印一次调试信息（约1秒）
	_debug_frame += 1
	if _debug_frame % 60 == 0:
		var fn := get_floor_normal()
		print("[P] vx=", int(velocity.x), " floor=", is_on_floor(),
			" fn.x=", snapped(fn.x, 0.01), " slope=", absf(fn.x) > 0.08)

# ── Gravity ────────────────────────────────────────────────
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

# ── Movement ───────────────────────────────────────────────
func _handle_movement(delta: float) -> void:
	var input_dir: float = Input.get_axis("move_left", "move_right")

	if input_dir != 0:
		_facing = int(sign(input_dir))

	# 动态技能加成
	var friction: float = ski_friction + SkillManager.parallel_friction_bonus()
	var accel: float = ski_accel + SkillManager.carving_accel_bonus()
	var air_ctrl: float = air_friction + SkillManager.carving_air_control_bonus()

	_on_uphill = false

	if is_on_floor():
		var fn := get_floor_normal()   # 地面法线，ny < 0（指向玩家）
		var slope_x := absf(fn.x)      # 0 = 平地，越大坡越陡
		var can_parallel_brake: bool = SkillManager.has_skill(SkillManager.Skill.PARALLEL_SKIING) \
			and Input.is_action_pressed("brake") and slope_x > 0.08
		if can_parallel_brake:
			velocity.x = 0.0
			return

		if slope_x > 0.08:   # 在斜坡上
			# 下坡切线：旋转 fn 使 Y > 0（指向屏幕下方 = 下坡）
			var tangent := Vector2(-fn.y, fn.x)
			if tangent.y < 0:
				tangent = -tangent
			var downhill_dir: float = sign(tangent.x)   # +1=向右下坡，-1=向左下坡

			var is_uphill: bool = (input_dir != 0) and (sign(input_dir) != downhill_dir)

			if is_uphill:
				_on_uphill = true
				var uphill_max: float = walk_speed * absf(fn.y) * 0.55
				velocity.x = move_toward(velocity.x, input_dir * uphill_max, accel * 0.5 * delta)
				velocity.x = clamp(velocity.x, -uphill_max, uphill_max)
			else:
				# 下坡或松手：g * sin(angle) = g * slope_x，持续加速
				velocity.x += downhill_dir * gravity * slope_x * delta
				if input_dir != 0:
					velocity.x += input_dir * accel * 0.15 * delta
				velocity.x = clamp(velocity.x, -max_ski_speed, max_ski_speed)
		else:
			# 平地：动量模型
			if input_dir != 0:
				velocity.x = move_toward(velocity.x, input_dir * max_ski_speed, accel * delta)
			else:
				velocity.x = move_toward(velocity.x, 0.0, friction * delta)
			velocity.x = clamp(velocity.x, -max_ski_speed, max_ski_speed)
	else:
		if input_dir != 0:
			velocity.x = move_toward(velocity.x, input_dir * walk_speed, air_ctrl * delta)

# ── Helmet collision damage (头盔撞击) ─────────────────────
# 玩家不与敌人体发生物理碰撞，因此这里用前向近距离检测来结算冲撞伤害
var _collision_hit_set: Dictionary = {}

func _handle_body_collision() -> void:
	if not EquipmentManager.has_equipment(EquipmentManager.Slot.HELMET):
		_collision_hit_set.clear()
		return
	var spd := absf(velocity.x)
	if spd < collision_speed_threshold:
		_collision_hit_set.clear()
		return
	var move_dir := signf(velocity.x)
	if is_zero_approx(move_dir):
		return
	_helmet_query_shape.size = Vector2(helmet_collision_forward_range, helmet_collision_vertical_range)
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = _helmet_query_shape
	query.transform = Transform2D(0.0, global_position + Vector2(move_dir * (helmet_collision_forward_range * 0.5 + 16.0), 0.0))
	query.collide_with_bodies = true
	query.collide_with_areas = false
	query.collision_mask = 1 << 2
	query.exclude = [get_rid()]
	for result in get_world_2d().direct_space_state.intersect_shape(query, 16):
		var enemy: Node = result.get("collider")
		if not is_instance_valid(enemy):
			continue
		if not (enemy is Node2D):
			continue
		if _collision_hit_set.has(enemy):
			continue
		if not enemy.has_method("take_damage"):
			continue
		var enemy_pos: Vector2 = (enemy as Node2D).global_position
		var to_enemy: Vector2 = enemy_pos - global_position
		if to_enemy.x * move_dir < 0.0:
			continue
		if absf(to_enemy.x) > helmet_collision_forward_range:
			continue
		if absf(to_enemy.y) > helmet_collision_vertical_range:
			continue
		_collision_hit_set[enemy] = true
		var dmg := int(float(attack_damage) * EquipmentManager.collision_damage_mult())
		enemy.take_damage(dmg, global_position)

# ── Jump ───────────────────────────────────────────────────
var _double_jump_used: bool = false

func _handle_jump() -> void:
	if is_on_floor():
		_double_jump_used = false
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jump_force
		elif SkillManager.can_double_jump() and not _double_jump_used:
			velocity.y = jump_force * 0.85   # 二段跳略低于第一跳
			_double_jump_used = true

# ── Attack ─────────────────────────────────────────────────
func _handle_attack() -> void:
	if Input.is_action_just_pressed("attack") and _attack_timer <= 0.0:
		_attack_timer = attack_cooldown
		_is_attacking = true
		_attack_hit_bodies.clear()
		attack_area.monitoring = true
		_update_attack_hitbox()
		_hit_overlapping_attack_bodies()
		# 攻击拖尾粒子
		var trail: GPUParticles2D = _ATTACK_TRAIL.instantiate()
		get_parent().add_child(trail)
		trail.global_position = attack_area.global_position
		trail.emitting = true
		var t_free := get_tree().create_timer(0.5)
		t_free.timeout.connect(func(): if is_instance_valid(trail): trail.queue_free())
		if anim and anim.has_animation("attack"):
			anim.play("attack")
		# Disable hitbox after brief window
		var t: SceneTreeTimer = get_tree().create_timer(0.15)
		t.timeout.connect(func(): attack_area.monitoring = false; _is_attacking = false; _attack_hit_bodies.clear())

func _hit_overlapping_attack_bodies() -> void:
	for body in attack_area.get_overlapping_bodies():
		_try_hit_attack_body(body)

func _try_hit_attack_body(body: Node) -> void:
	if body == null or not body.is_in_group("enemy"):
		return
	if not body.has_method("take_damage"):
		return
	if _attack_hit_bodies.has(body):
		return
	_attack_hit_bodies[body] = true
	body.take_damage(_get_attack_damage_value(), global_position)

# ── Slope detection (仅用于 _update_sprite 層级判断) ──────────────
func _update_slope_info() -> void:
	_on_slope = false
	_slope_normal = Vector2.UP
	var fn := get_floor_normal()
	if is_on_floor() and absf(fn.x) > 0.08:
		_on_slope = true
		_slope_normal = fn

# ── Sprite flip + 动画状态机 ──────────────────────────────
func _update_sprite() -> void:
	if sprite:
		sprite.flip_h = (_facing == -1)
	# 优先级：dead > hurt > attack > jump > ski > idle
	if _is_dead:
		_play_anim("dead")
	elif _invincible_timer > 0.0 and not _respawn_grace:
		_play_anim("hurt")
	elif _is_attacking:
		_play_anim("attack")
	elif not is_on_floor():
		_play_anim("jump")
	elif absf(velocity.x) > 20.0:
		if _on_uphill:
			_play_anim("run")   # 上坡走路动画
		else:
			_play_anim("ski")   # 下坡/平地滑雪动画
	else:
		_play_anim("idle")

const _ANIM_FRAMES := {"idle": 0, "run": 1, "ski": 2, "attack": 3, "hurt": 4, "dead": 5, "jump": 6}

func _play_anim(anim_name: String) -> void:
	if not anim:
		if sprite and _ANIM_FRAMES.has(anim_name):
			sprite.frame = _ANIM_FRAMES[anim_name]
		return
	if anim.has_animation(anim_name) and anim.current_animation != anim_name:
		anim.play(anim_name)
# ── Signals ───────────────────────────────────────────────
signal respawn_countdown(seconds_left: int)
signal respawned
# ── Hit / Death ────────────────────────────────────────────
func take_damage(amount: int, hit_source_position: Vector2 = Vector2.ZERO, source_name: String = "") -> void:
	if _invincible_timer > 0.0 or _is_dead:
		return
	var final_damage: int = _get_incoming_damage_value(amount, source_name)
	GameManager.take_damage(final_damage)
	hp = GameManager.player_hp
	_invincible_timer = invincible_duration
	_log_damage_source(final_damage, hit_source_position, source_name)

	# Knockback away from damage source
	if hit_source_position != Vector2.ZERO:
		var dir: float = sign(global_position.x - hit_source_position.x)
		velocity.x = dir * knockback_force
		velocity.y = -200.0

	# Blink effect
	_start_blink()

	if GameManager.player_hp <= 0:
		die()

func _get_incoming_damage_value(amount: int, source_name: String) -> int:
	var final_damage: int = amount
	if _is_collision_damage_source(source_name):
		var reduction: float = EquipmentManager.collision_damage_reduction()
		if reduction > 0.0:
			final_damage = maxi(1, int(round(float(amount) * (1.0 - reduction))))
	return final_damage

func _is_collision_damage_source(source_name: String) -> bool:
	return source_name.contains("碰撞") or source_name.contains("冲撞")

func _log_damage_source(amount: int, hit_source_position: Vector2, source_name: String) -> void:
	if not log_damage_sources:
		return
	var scene_name: String = get_tree().current_scene.name if get_tree().current_scene != null else "UnknownScene"
	var source_label: String = source_name if not source_name.is_empty() else "未知来源"
	var source_pos_text: String = "n/a"
	if hit_source_position != Vector2.ZERO:
		source_pos_text = "(%.1f, %.1f)" % [hit_source_position.x, hit_source_position.y]
	print("[PlayerDamage] scene=", scene_name,
		" source=", source_label,
		" amount=", amount,
		" hp=", hp, "/", max_hp,
		" player_pos=", global_position,
		" source_pos=", source_pos_text)

func die(fell_into_pit: bool = false) -> void:
	if _is_dead:
		return
	_is_dead = true
	GameManager.begin_death_retry_state()
	if _should_drop_equipment_on_death():
		_drop_equipped_items(fell_into_pit)
	SaveSystem.save()
	velocity = Vector2.ZERO
	respawn_countdown.emit(1)

	# ── 死亡特效：变红 + 缩小 + 淡出 ──
	var tween := create_tween()
	for _i in 3:
		tween.tween_property(sprite, "modulate", Color(2.0, 0.2, 0.2, 1.0), 0.08)
		tween.tween_property(sprite, "modulate", Color(1.5, 0.5, 0.5, 1.0), 0.08)
	tween.tween_property(sprite, "scale", Vector2(0.5, 0.5) * sprite.scale, 0.5)
	tween.parallel().tween_property(sprite, "modulate:a", 0.0, 0.5)

	# “死亡完成”后自动回到最近复活点
	await tween.finished
	GameManager.clear_death_retry_state()
	respawn()

func _should_drop_equipment_on_death() -> bool:
	var current_scene: Node = get_tree().current_scene
	if current_scene == null:
		return false
	var scene_path := String(current_scene.scene_file_path)
	return scene_path == "res://scenes/maps/GlacierMaze.tscn" or current_scene.name == "GlacierMaze"

func _drop_equipped_items(fell_into_pit: bool) -> void:
	var items := EquipmentManager.get_equipped_items()
	if items.is_empty():
		return
	var drop_origin := _last_safe_position if fell_into_pit else global_position
	drop_origin.y -= 18.0
	var scene_path := get_tree().current_scene.scene_file_path if get_tree().current_scene else ""
	var parent_node: Node = get_parent()
	for index in items.size():
		var item: Dictionary = items[index]
		var drop_pos := drop_origin + Vector2((index - (items.size() - 1) * 0.5) * 22.0, -4.0 * float(index % 2))
		EquipmentManager.unequip(item["slot"])
		var id := GameManager.add_pending_equipment_drop(scene_path, drop_pos, int(item["slot"]), int(item["level"]), String(item["label_text"]))
		var pickup: Area2D = _EQUIPMENT_PICKUP_SCENE.instantiate()
		pickup.slot = int(item["slot"])
		pickup.level = int(item["level"])
		pickup.label_text = String(item["label_text"])
		pickup.runtime_drop = true
		pickup.drop_id = id
		pickup.pickup_delay = 0.45
		parent_node.add_child(pickup)
		pickup.global_position = drop_pos

func respawn() -> void:
	GameManager.clear_death_retry_state()
	velocity = Vector2.ZERO
	attack_area.monitoring = false
	_is_attacking = false
	_attack_hit_bodies.clear()
	_collision_hit_set.clear()
	_is_dead = false
	_respawn_grace = true
	_invincible_timer = 2.0
	max_hp = GameManager.player_max_hp
	hp = max_hp
	GameManager.player_hp = hp
	GameManager.hp_changed.emit(hp, max_hp)

	var current_scene: Node = get_tree().current_scene
	if current_scene != null and not String(current_scene.scene_file_path).is_empty():
		var spawn_target: String = SceneManager.SAVE_RESPAWN_POINT if GameManager.respawn_position != Vector2.ZERO else "DefaultSpawn"
		SceneManager.go_to(String(current_scene.scene_file_path), spawn_target)
		return

	var pos: Vector2 = GameManager.respawn_position
	if pos == Vector2.ZERO:
		for node in get_tree().get_nodes_in_group("spawn_point"):
			pos = node.global_position
			break
		if pos == Vector2.ZERO:
			pos = Vector2(200, 656)
	global_position = pos
	if sprite:
		sprite.modulate = Color(1, 1, 1, 1)
		sprite.scale = Vector2(0.33, 0.33)
	apply_floor_snap()
	respawned.emit()

func _start_blink() -> void:
	if not sprite:
		return
	var tween: Tween = create_tween()
	tween.set_loops(int(invincible_duration / 0.1))
	tween.tween_property(sprite, "modulate:a", 0.2, 0.05)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.05)

# ── Attack hit callback ────────────────────────────────────
# J 键攻击——固定伤害，造型与速度/头盔无关
func _on_attack_area_body_entered(body: Node) -> void:
	_try_hit_attack_body(body)

# ── Ice Blade skill ────────────────────────────────────────
func _handle_skill(delta: float) -> void:
	_skill_timer = max(_skill_timer - delta, 0.0)
	if Input.is_action_just_pressed("skill") and _skill_timer <= 0.0:
		if not GameManager.has_ice_blade:
			return
		_skill_timer = ice_blade_cooldown
		_fire_ice_blade()

func _fire_ice_blade() -> void:
	var blade: Node2D = ICE_BLADE_SCENE.instantiate()
	get_parent().add_child(blade)
	blade.global_position = global_position
	var dir := Vector2(float(_facing), 0.0)
	var blade_damage: int = _get_ice_blade_damage_value()
	# 雪镜二级：额外斜45°第二刀
	blade.init(dir, blade_damage)
	if EquipmentManager.has_equipment(EquipmentManager.Slot.GOGGLES, 2):
		var blade2: Node2D = ICE_BLADE_SCENE.instantiate()
		get_parent().add_child(blade2)
		blade2.global_position = global_position
		blade2.init(Vector2(float(_facing) * 0.707, -0.707), blade_damage)
