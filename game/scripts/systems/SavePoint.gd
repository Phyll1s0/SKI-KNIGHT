extends Area2D
# SavePoint — 复活点/检查点
# 玩家接触后更新最近复活位置，显示短暂提示

@onready var saved_label: Label = $SavedLabel

func _ready() -> void:
	add_to_group("savepoint")
	_activate_existing_player.call_deferred()

func _on_body_entered(body: Node) -> void:
	_activate_for_body(body)

func _activate_existing_player() -> void:
	await get_tree().physics_frame
	for body in get_overlapping_bodies():
		_activate_for_body(body)
		return

func _activate_for_body(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	var respawn_pos: Vector2 = global_position
	if body is Node2D:
		respawn_pos.y = (body as Node2D).global_position.y
	var current_scene_path := ""
	if get_tree().current_scene != null:
		current_scene_path = String(get_tree().current_scene.scene_file_path)
	var already_active: bool = current_scene_path == GameManager.respawn_scene \
		and GameManager.respawn_position.is_equal_approx(respawn_pos)
	if already_active:
		return
	GameManager.respawn_position = respawn_pos
	if not current_scene_path.is_empty():
		GameManager.respawn_scene = current_scene_path
	SaveSystem.save()
	saved_label.visible = true
	var timer: SceneTreeTimer = get_tree().create_timer(2.0)
	timer.timeout.connect(func(): saved_label.visible = false)
