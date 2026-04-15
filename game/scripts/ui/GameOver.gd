extends Control
# 游戏结束（备用覆盖层）

func _ready() -> void:
	add_to_group("game_over_overlay")
	visible = false   # 默认隐藏，由 Player.die() 激活

func _on_retry_pressed() -> void:
	get_tree().paused = false
	visible = false
	var players: Array = get_tree().get_nodes_in_group("player")
	if players.size() > 0 and players[0].has_method("respawn"):
		GameManager.clear_death_retry_state()
		players[0].respawn()
		return
	if SaveSystem.has_save():
		SaveSystem.load_save()   # 有存档 → 回到存档点
	else:
		get_tree().reload_current_scene()

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
