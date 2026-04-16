extends Area2D
# 装备拾取物：放在地图中，玩家进入触发区域自动获得装备

@export_enum("HELMET:0", "GOGGLES:1", "SNOWBOARD:2", "SUIT:3") var slot: int = 0
@export var level: int = 1
@export var label_text: String = "装备"   # 显示在拾取提示上
@export var runtime_drop: bool = false
@export var drop_id: String = ""
@export var pickup_delay: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label

var _can_pickup: bool = true
var _collected: bool = false
var _require_player_reenter: bool = false

func _ready() -> void:
	print("[EqPickup] _ready slot=%d level=%d runtime_drop=%s pos=%s" % [slot, level, runtime_drop, global_position])
	add_to_group("equipment_pickup")
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, true)
	var eq_slot: int = slot
	if not runtime_drop and SaveSystem.has_save() and EquipmentManager.has_unlocked(eq_slot, level):
		print("[EqPickup] Already unlocked, removing")
		queue_free()
		return
	if label_text == "装备":
		label_text = EquipmentManager.get_label_text(eq_slot, level)
	# 注意：pickup_delay 由调用方设置
	# - Player._drop_equipped_items: 0.45 (死亡掉落，需要延迟)
	# - BaseMap._spawn_pending_equipment_drops: 0.0 (场景重载，玩家已复活，不需要延迟)
	
	# 只在死亡掉落时（pickup_delay > 0 且玩家在附近）才需要 require_reenter
	# 场景重载后生成的掉落不需要这个限制（玩家已经完全复活）
	if runtime_drop and pickup_delay > 0.0 and _is_any_player_within_pickup_radius():
		_require_player_reenter = true
		print("[EqPickup] Player too close during initial drop, require_reenter=true")
	_sync_visuals()
	if pickup_delay > 0.0:
		print("[EqPickup] Starting pickup_delay=%.2f" % pickup_delay)
		_set_pickup_enabled(false)
		var t: SceneTreeTimer = get_tree().create_timer(pickup_delay)
		t.timeout.connect(func():
			if is_instance_valid(self):
				print("[EqPickup] Delay finished, enabling pickup")
				_set_pickup_enabled(true)
		)
	else:
		print("[EqPickup] No delay, enabling immediately")
		_set_pickup_enabled(true)
	# 漂浮动画
	var tween: Tween = create_tween().set_loops()
	tween.tween_property(sprite, "position:y", -6.0, 0.6).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "position:y", 6.0, 0.6).set_trans(Tween.TRANS_SINE)

func _physics_process(_delta: float) -> void:
	if _collected:
		return
	if not _can_pickup:
		return
	var players: Array = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
	var player: Node = players[0]
	if not (player is Node2D):
		return
	var distance_to_player: float = global_position.distance_to((player as Node2D).global_position)
	
	# Debug: 当玩家接近时输出状态
	if distance_to_player <= 60.0 and Engine.get_physics_frames() % 30 == 0:  # 每0.5秒输出一次
		print("[EqPickup Physics] dist=%.1f can_pickup=%s require_reenter=%s monitoring=%s monitorable=%s" % [
			distance_to_player, _can_pickup, _require_player_reenter, monitoring, monitorable
		])
	
	if runtime_drop and _require_player_reenter:
		if distance_to_player <= 40.0:
			return
		_require_player_reenter = false
		print("[EqPickup] Player left area, require_reenter cleared")
	if distance_to_player <= 40.0:
		_try_collect(player)

func _sync_visuals() -> void:
	label.text = label_text
	var eq_slot: int = slot
	var path: String = EquipmentManager.get_icon_path(eq_slot, level)
	sprite.texture = _load_optional_texture(path)
	sprite.visible = sprite.texture != null
	label.visible = true

func _load_optional_texture(path: String) -> Texture2D:
	if path.is_empty():
		return null
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	var absolute_path: String = ProjectSettings.globalize_path(path)
	if not FileAccess.file_exists(absolute_path):
		return null
	var image: Image = Image.load_from_file(absolute_path)
	if image != null and not image.is_empty():
		return ImageTexture.create_from_image(image)
	return null

func _on_body_entered(body: Node) -> void:
	print("[EqPickup] _on_body_entered: body=%s is_player=%s" % [body.name, body.is_in_group("player")])
	_try_collect(body)

func _set_pickup_enabled(enabled: bool) -> void:
	print("[EqPickup] _set_pickup_enabled: %s" % enabled)
	_can_pickup = enabled
	set_deferred("monitoring", enabled)
	set_deferred("monitorable", enabled)

func _is_any_player_within_pickup_radius() -> bool:
	for node in get_tree().get_nodes_in_group("player"):
		if node is Node2D and global_position.distance_to((node as Node2D).global_position) <= 40.0:
			return true
	return false

func _try_collect(body: Node) -> void:
	print("[EqPickup] _try_collect called: _collected=%s _can_pickup=%s" % [_collected, _can_pickup])
	
	if _collected or not _can_pickup:
		print("[EqPickup] Rejected: already collected or pickup disabled")
		return
	
	if runtime_drop and (GameManager.death_retry_pending or SceneManager.is_transitioning()):
		print("[EqPickup] Rejected: death_retry_pending or transitioning")
		return
	
	if runtime_drop and _require_player_reenter:
		print("[EqPickup] Rejected: require_player_reenter")
		return
	
	if not body.is_in_group("player"):
		print("[EqPickup] Rejected: body not in player group")
		return
	
	var is_dead: bool = bool(body.get("_is_dead")) if body.has_method("get") else false
	if is_dead == true:
		print("[EqPickup] Rejected: player is dead")
		return
	
	_collected = true
	var eq_slot: int = slot
	var cur_level: int = int(EquipmentManager.equipment_level.get(eq_slot, 0))
	var unlocked_level: int = int(EquipmentManager.unlocked_level.get(eq_slot, 0))
	
	print("[DEBUG EquipmentPickup] slot=%d level=%d cur_level=%d unlocked_level=%d runtime_drop=%s" % [eq_slot, level, cur_level, unlocked_level, runtime_drop])
	
	# 只有装备等级高于当前已装备等级时才装备
	if level > cur_level:
		print("[DEBUG EquipmentPickup] Equipping: level(%d) > cur_level(%d)" % [level, cur_level])
		EquipmentManager.equip(eq_slot, level)
		
		# 只有首次获得（等级高于曾经解锁的等级）时才显示通知
		if level > unlocked_level:
			var notif: Dictionary = NotificationManager.get_equipment_description(eq_slot, level)
			NotificationManager.show_item_acquired(notif["name"], notif["desc"])
	else:
		print("[DEBUG EquipmentPickup] NOT Equipping: level(%d) <= cur_level(%d)" % [level, cur_level])
	
	if runtime_drop and not drop_id.is_empty():
		GameManager.remove_pending_equipment_drop(drop_id)
		SaveSystem.save()
	queue_free()
