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
	add_to_group("equipment_pickup")
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, true)
	var eq_slot: int = slot
	if not runtime_drop and SaveSystem.has_save() and EquipmentManager.has_unlocked(eq_slot, level):
		queue_free()
		return
	if label_text == "装备":
		label_text = EquipmentManager.get_label_text(eq_slot, level)
	if runtime_drop and pickup_delay <= 0.0:
		pickup_delay = 0.45
	if runtime_drop and _is_any_player_within_pickup_radius():
		_require_player_reenter = true
	_sync_visuals()
	if pickup_delay > 0.0:
		_set_pickup_enabled(false)
		var t: SceneTreeTimer = get_tree().create_timer(pickup_delay)
		t.timeout.connect(func():
			if is_instance_valid(self):
				_set_pickup_enabled(true)
		)
	else:
		_set_pickup_enabled(true)
	# 漂浮动画
	var tween: Tween = create_tween().set_loops()
	tween.tween_property(sprite, "position:y", -6.0, 0.6).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "position:y", 6.0, 0.6).set_trans(Tween.TRANS_SINE)

func _physics_process(_delta: float) -> void:
	if _collected or not _can_pickup:
		return
	var players: Array = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
	var player: Node = players[0]
	if not (player is Node2D):
		return
	var distance_to_player: float = global_position.distance_to((player as Node2D).global_position)
	if runtime_drop and _require_player_reenter:
		if distance_to_player <= 40.0:
			return
		_require_player_reenter = false
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
	_try_collect(body)

func _set_pickup_enabled(enabled: bool) -> void:
	_can_pickup = enabled
	set_deferred("monitoring", enabled)
	set_deferred("monitorable", enabled)

func _is_any_player_within_pickup_radius() -> bool:
	for node in get_tree().get_nodes_in_group("player"):
		if node is Node2D and global_position.distance_to((node as Node2D).global_position) <= 40.0:
			return true
	return false

func _try_collect(body: Node) -> void:
	if _collected or not _can_pickup:
		return
	if runtime_drop and (GameManager.death_retry_pending or SceneManager.is_transitioning()):
		return
	if runtime_drop and _require_player_reenter:
		return
	if not body.is_in_group("player"):
		return
	var is_dead: bool = bool(body.get("_is_dead")) if body.has_method("get") else false
	if is_dead == true:
		return
	_collected = true
	var eq_slot: int = slot
	var cur_level: int = int(EquipmentManager.equipment_level.get(eq_slot, 0))
	if level > cur_level:
		EquipmentManager.equip(eq_slot, level)
	if runtime_drop and not drop_id.is_empty():
		GameManager.remove_pending_equipment_drop(drop_id)
		SaveSystem.save()
	queue_free()
