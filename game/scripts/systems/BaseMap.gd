extends Node2D
# BaseMap — 所有地图场景的基类脚本
# 子类场景 script 改为继承此脚本，或直接使用

const _EQUIPMENT_PICKUP_SCENE := preload("res://scenes/systems/EquipmentPickup.tscn")

@export var cold_zone: bool = false
@export var cold_damage_per_sec: int = 5
@export var bgm_path: String = ""
@export var respawn_delay: float = 60.0   # 敌人死亡后多少秒重新刷新（1分钟）

var _player: CharacterBody2D = null
var _cold_timer: float = 0.0

# 刷怪数据：{ scene_path, spawn_position, group }
class _EnemyRecord:
	var scene_path: String
	var spawn_pos: Vector2
	var node_name: String

var _enemy_records: Array[_EnemyRecord] = []
var _respawn_queue: Array = []   # [{record, timer}]

func _ready() -> void:
	_register_enemies()
	_place_player()
	_spawn_pending_equipment_drops()

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if get_tree().paused:
		return
	if _has_modal_ui_open():
		return
	SaveSystem.save()
	get_viewport().set_input_as_handled()
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

func _has_modal_ui_open() -> bool:
	for shop in get_tree().get_nodes_in_group("shop"):
		if shop.get("_open") == true:
			return true
	return false

# ── 注册场景内所有敌人 ──────────────────────────────────────────────────
func _register_enemies() -> void:
	for child in get_children():
		if child.is_in_group("enemy"):
			var rec := _EnemyRecord.new()
			rec.scene_path = child.scene_file_path
			rec.spawn_pos  = child.global_position
			rec.node_name  = child.name
			_enemy_records.append(rec)
			# 初次加载时同样向上推 48px，防止陷入墙体
			if child is CharacterBody2D:
				child.global_position += Vector2(0, -48)
			# 监听树退出（死亡 queue_free 后触发）
			child.tree_exited.connect(_on_enemy_removed.bind(rec))

func _on_enemy_removed(rec: _EnemyRecord) -> void:
	# Boss 不刷新（IceLynx / FrozenGuard / SnowKing）
	if rec.scene_path.contains("Boss") or rec.scene_path.contains("IceLynx") \
			or rec.scene_path.contains("FrozenGuard") or rec.scene_path.contains("SnowKing"):
		return
	_respawn_queue.append({ "rec": rec, "timer": respawn_delay })

# ── 主循环：倒计时刷怪 ────────────────────────────────────────────────
func _process(delta: float) -> void:
	# 刷怪倒计时
	var still_waiting: Array = []
	for entry in _respawn_queue:
		entry["timer"] -= delta
		if entry["timer"] <= 0.0:
			_spawn_enemy(entry["rec"])
		else:
			still_waiting.append(entry)
	_respawn_queue = still_waiting

	# 寒冷扣血
	if not cold_zone:
		return
	if not is_instance_valid(_player):
		return
	if EquipmentManager.is_cold_proof():
		return
	_cold_timer += delta
	if _cold_timer >= 1.0:
		_cold_timer = 0.0
		_player.take_damage(cold_damage_per_sec, Vector2.ZERO)

# ── 实例化单个敌人 ────────────────────────────────────────────────────
func _spawn_enemy(rec: _EnemyRecord) -> void:
	if rec.scene_path == "":
		return
	var packed: PackedScene = load(rec.scene_path)
	if not packed:
		return
	var node: Node = packed.instantiate()
	node.name = rec.node_name
	add_child(node)
	# 向上偏移 48px，确保不生成在墙体内；CharacterBody2D 会靠重力落地
	node.global_position = rec.spawn_pos + Vector2(0, -48)
	# 重新注册（下次死亡继续刷）
	node.tree_exited.connect(_on_enemy_removed.bind(rec))

# ── 玩家落点 ──────────────────────────────────────────────────────────
func _place_player() -> void:
	var spawn_name := SceneManager.get_spawn_point_name()
	var spawn: Node = _find_spawn(spawn_name)
	if not spawn:
		spawn = _find_spawn("DefaultSpawn")
	_player = get_node_or_null("Player")
	if _player and spawn:
		_player.global_position = spawn.global_position

func _spawn_pending_equipment_drops() -> void:
	var scene := get_tree().current_scene
	if scene == null or scene.scene_file_path.is_empty():
		return
	var drops := GameManager.get_pending_equipment_drops(scene.scene_file_path)
	for entry in drops:
		var pickup: Area2D = _EQUIPMENT_PICKUP_SCENE.instantiate()
		pickup.slot = int(entry.get("slot", 0))
		pickup.level = int(entry.get("level", 1))
		pickup.label_text = String(entry.get("label_text", "装备"))
		pickup.runtime_drop = true
		pickup.drop_id = String(entry.get("id", ""))
		add_child(pickup)
		pickup.global_position = Vector2(float(entry.get("x", 0.0)), float(entry.get("y", 0.0)))

func _find_spawn(point_name: String) -> Node:
	for child in get_children():
		if child is Marker2D and child.get("point_name") == point_name:
			return child
	return null
