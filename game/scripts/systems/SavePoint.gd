extends Area2D
# SavePoint — 复活点/检查点
# 玩家接触后更新最近复活位置，显示短暂提示

@onready var saved_label: Label = $SavedLabel

func _ready() -> void:
	add_to_group("savepoint")

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	GameManager.respawn_position = global_position
	saved_label.visible = true
	var timer: SceneTreeTimer = get_tree().create_timer(2.0)
	timer.timeout.connect(func(): saved_label.visible = false)
