extends Area2D
# IceSurface — 冰面区域标记
# 玩家进入此区域时标记为"在冰面上"，退出时清除标记
# 用于区分雪面和冰面的刹车行为

func _ready() -> void:
	# 只检测玩家（layer 2）
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, true)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("set_on_ice_surface"):
		body.set_on_ice_surface(true)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("set_on_ice_surface"):
		body.set_on_ice_surface(false)
