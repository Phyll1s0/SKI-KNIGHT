extends Control
# 通关胜利界面

func _ready() -> void:
	# 注意：不在 _ready 里暂停，只在界面显示时才暂停
	GameManager.game_completed.connect(_on_game_completed)

func _on_game_completed() -> void:
	# Boss 死亡后 1.5 秒弹出
	await get_tree().create_timer(1.5).timeout
	visible = true
	get_tree().paused = true

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
