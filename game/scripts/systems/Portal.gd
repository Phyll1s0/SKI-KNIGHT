extends Area2D
# Portal — 传送点

@export var target_scene: String = ""
@export var spawn_point_name: String = "DefaultSpawn"
@export var activation_direction: String = "any"

func _ready() -> void:
	add_to_group("portal")
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, true)
	# 外圈脉冲动画
	var tween := create_tween().set_loops()
	tween.tween_property($PortalOuter, "modulate:a", 0.35, 0.9).set_trans(Tween.TRANS_SINE)
	tween.tween_property($PortalOuter, "modulate:a", 1.0, 0.9).set_trans(Tween.TRANS_SINE)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	if target_scene == "":
		return
	SceneManager.go_to(target_scene, spawn_point_name)
