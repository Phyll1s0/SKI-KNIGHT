extends Control
# 主菜单

@onready var subtitle: Label     = $VBox/Subtitle
@onready var continue_btn: Button = $VBox/ContinueBtn
@onready var delete_btn: Button   = $VBox/DeleteBtn
@onready var keybind_settings: Control = $KeybindSettings

func _ready() -> void:
	get_tree().paused = false
	_refresh_save_ui()

func _refresh_save_ui() -> void:
	var has := SaveSystem.has_save()
	continue_btn.visible = has
	delete_btn.visible   = has
	subtitle.text = "存档已就绪，可继续上次游戏" if has else "雪山在等待你……"

func _on_continue_pressed() -> void:
	SaveSystem.load_save()   # 内部会调 SceneManager.go_to(saved_scene)

func _on_start_pressed() -> void:
	# 删除旧存档并重置全部数据
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

func _on_delete_pressed() -> void:
	SaveSystem.delete_save()
	_refresh_save_ui()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_settings_pressed() -> void:
	if keybind_settings != null:
		keybind_settings.call("open_panel")
