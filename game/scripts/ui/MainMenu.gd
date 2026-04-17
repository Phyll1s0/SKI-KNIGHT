extends Control
# 主菜单

@onready var title_label: Label = $Title
@onready var subtitle: Label = $Subtitle
@onready var main_buttons: VBoxContainer = $MainButtons
@onready var settings_menu: VBoxContainer = $SettingsMenu
@onready var continue_btn: Button = $MainButtons/ContinueBtn
@onready var keybind_settings: Control = $KeybindSettings
@onready var gamepad_settings: Control = $GamepadSettings

func _ready() -> void:
	get_tree().paused = false
	_refresh_save_ui()
	_start_title_animation()
	_animate_entrance()

func _refresh_save_ui() -> void:
	var has := SaveSystem.has_save()
	continue_btn.visible = has
	subtitle.text = "存档已就绪，可继续上次游戏" if has else "雪山在等待你……"

func _start_title_animation() -> void:
	# 标题颜色在冷白与冰蓝之间循环闪烁，模拟冰雪光泽
	var tween := create_tween().set_loops()
	tween.tween_property(title_label, "theme_override_colors/font_color",
			Color(0.92, 0.98, 1.0, 1.0), 1.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(title_label, "theme_override_colors/font_color",
			Color(0.36, 0.68, 1.0, 1.0), 1.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _animate_entrance() -> void:
	title_label.modulate.a = 0.0
	subtitle.modulate.a = 0.0
	main_buttons.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(title_label, "modulate:a", 1.0, 0.9).set_trans(Tween.TRANS_CUBIC)
	tween.tween_interval(0.05)
	tween.tween_property(subtitle, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(main_buttons, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_CUBIC)

func _on_continue_pressed() -> void:
	SaveSystem.load_save()

func _on_start_pressed() -> void:
	SaveSystem.delete_save()
	GameManager.player_max_hp          = GameManager.BASE_PLAYER_MAX_HP
	GameManager.player_hp              = GameManager.BASE_PLAYER_MAX_HP
	GameManager.player_exp             = 0
	GameManager.player_level           = 1
	GameManager.player_attack          = GameManager.BASE_PLAYER_ATTACK
	GameManager.evolution_count        = 0
	GameManager.has_double_jump        = false
	GameManager.gold                   = 0
	GameManager.has_suit_fragment      = false
	GameManager.has_goggles_part       = false
	GameManager.has_ice_blade          = false
	GameManager.respawn_position       = Vector2.ZERO
	EquipmentManager.equipment_level[EquipmentManager.Slot.HELMET]    = 0
	EquipmentManager.equipment_level[EquipmentManager.Slot.GOGGLES]   = 0
	EquipmentManager.equipment_level[EquipmentManager.Slot.SNOWBOARD] = 0
	EquipmentManager.equipment_level[EquipmentManager.Slot.SUIT]      = 0
	EquipmentManager.unlocked_level[EquipmentManager.Slot.HELMET]    = 0
	EquipmentManager.unlocked_level[EquipmentManager.Slot.GOGGLES]   = 0
	EquipmentManager.unlocked_level[EquipmentManager.Slot.SNOWBOARD] = 0
	EquipmentManager.unlocked_level[EquipmentManager.Slot.SUIT]      = 0
	GameManager.pending_equipment_drops.clear()
	GameManager.clear_death_retry_state()
	SkillManager.unlocked_skills[SkillManager.Skill.ICE_BLADE]       = false
	SkillManager.unlocked_skills[SkillManager.Skill.PARALLEL_SKIING] = false
	SkillManager.unlocked_skills[SkillManager.Skill.CARVING]         = false
	SkillManager.unlocked_skills[SkillManager.Skill.BACK_FLIP]       = false
	SceneManager.go_to("res://scenes/maps/TestMap.tscn")

func _on_settings_pressed() -> void:
	main_buttons.visible = false
	settings_menu.modulate.a = 0.0
	settings_menu.visible = true
	create_tween().tween_property(settings_menu, "modulate:a", 1.0, 0.2).set_trans(Tween.TRANS_CUBIC)

func _on_keybind_pressed() -> void:
	if keybind_settings != null:
		keybind_settings.call("open_panel")

func _on_gamepad_pressed() -> void:
	if gamepad_settings != null:
		gamepad_settings.call("open_panel")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_back_pressed() -> void:
	settings_menu.visible = false
	main_buttons.modulate.a = 0.0
	main_buttons.visible = true
	create_tween().tween_property(main_buttons, "modulate:a", 1.0, 0.2).set_trans(Tween.TRANS_CUBIC)
