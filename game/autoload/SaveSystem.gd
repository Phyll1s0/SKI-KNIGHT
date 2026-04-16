extends Node
# SaveSystem — Autoload
# 使用 user:// 存档，JSON 格式

const SAVE_PATH := "user://skiknight_save.json"

func save() -> void:
	var data := {
		"player_hp":     GameManager.player_hp,
		"player_max_hp": GameManager.player_max_hp,
		"player_exp":    GameManager.player_exp,
		"player_level":  GameManager.player_level,
		"player_attack": GameManager.player_attack,
		"evolution_count": GameManager.evolution_count,
		"has_double_jump": GameManager.has_double_jump,
		"gold": GameManager.gold,
		"has_suit_fragment": GameManager.has_suit_fragment,
		"has_goggles_part":  GameManager.has_goggles_part,
		"equipment": {
			"helmet":    EquipmentManager.equipment_level[EquipmentManager.Slot.HELMET],
			"goggles":   EquipmentManager.equipment_level[EquipmentManager.Slot.GOGGLES],
			"snowboard": EquipmentManager.equipment_level[EquipmentManager.Slot.SNOWBOARD],
			"suit":      EquipmentManager.equipment_level[EquipmentManager.Slot.SUIT],
		},
		"equipment_progress": {
			"helmet":    EquipmentManager.unlocked_level[EquipmentManager.Slot.HELMET],
			"goggles":   EquipmentManager.unlocked_level[EquipmentManager.Slot.GOGGLES],
			"snowboard": EquipmentManager.unlocked_level[EquipmentManager.Slot.SNOWBOARD],
			"suit":      EquipmentManager.unlocked_level[EquipmentManager.Slot.SUIT],
		},
		"skills":       SkillManager.serialize(),
		"pending_equipment_drops": GameManager.pending_equipment_drops,
		"current_scene": get_tree().current_scene.scene_file_path,
		"respawn_x":    GameManager.respawn_position.x,
		"respawn_y":    GameManager.respawn_position.y,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	file.close()

func load_save() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var text := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if not parsed is Dictionary:
		return false
	var data: Dictionary = parsed

	GameManager.player_hp      = data.get("player_hp",     100)
	GameManager.player_max_hp  = data.get("player_max_hp", 100)
	GameManager.player_exp     = data.get("player_exp",    0)
	GameManager.player_level   = data.get("player_level",  1)
	GameManager.player_attack  = data.get("player_attack", GameManager.BASE_PLAYER_ATTACK)
	GameManager.player_max_hp  = data.get("player_max_hp", GameManager.BASE_PLAYER_MAX_HP)
	GameManager.player_hp      = data.get("player_hp",     GameManager.player_max_hp)
	var legacy_max_hp: int = GameManager.legacy_expected_max_hp_for_level(GameManager.player_level)
	if GameManager.player_max_hp == legacy_max_hp:
		GameManager.player_max_hp = GameManager.expected_max_hp_for_level(GameManager.player_level)
		GameManager.player_hp = min(GameManager.player_hp, GameManager.player_max_hp)
	var legacy_attack: int = GameManager.legacy_expected_attack_for_level(GameManager.player_level)
	if GameManager.player_attack == legacy_attack:
		GameManager.player_attack = GameManager.expected_attack_for_level(GameManager.player_level)
	GameManager.evolution_count = data.get("evolution_count", 0)
	GameManager.has_double_jump = data.get("has_double_jump", false)
	GameManager.gold               = data.get("gold", 0)
	GameManager.has_suit_fragment  = data.get("has_suit_fragment", false)
	GameManager.has_goggles_part   = data.get("has_goggles_part",  false)
	GameManager.clear_death_retry_state()
	GameManager.pending_equipment_drops.clear()
	for entry in data.get("pending_equipment_drops", []):
		if entry is Dictionary:
			GameManager.pending_equipment_drops.append(entry)

	if data.has("skills"):
		SkillManager.deserialize(data["skills"])

	if data.has("equipment"):
		var eq: Dictionary = data["equipment"]
		EquipmentManager.equipment_level[EquipmentManager.Slot.HELMET]    = eq.get("helmet",    0)
		EquipmentManager.equipment_level[EquipmentManager.Slot.GOGGLES]   = eq.get("goggles",   0)
		EquipmentManager.equipment_level[EquipmentManager.Slot.SNOWBOARD] = eq.get("snowboard", 0)
		EquipmentManager.equipment_level[EquipmentManager.Slot.SUIT]      = eq.get("suit",      0)

	if data.has("equipment_progress"):
		var progress: Dictionary = data["equipment_progress"]
		EquipmentManager.unlocked_level[EquipmentManager.Slot.HELMET]    = progress.get("helmet", EquipmentManager.equipment_level[EquipmentManager.Slot.HELMET])
		EquipmentManager.unlocked_level[EquipmentManager.Slot.GOGGLES]   = progress.get("goggles", EquipmentManager.equipment_level[EquipmentManager.Slot.GOGGLES])
		EquipmentManager.unlocked_level[EquipmentManager.Slot.SNOWBOARD] = progress.get("snowboard", EquipmentManager.equipment_level[EquipmentManager.Slot.SNOWBOARD])
		EquipmentManager.unlocked_level[EquipmentManager.Slot.SUIT]      = progress.get("suit", EquipmentManager.equipment_level[EquipmentManager.Slot.SUIT])
	else:
		EquipmentManager.unlocked_level[EquipmentManager.Slot.HELMET]    = max(EquipmentManager.unlocked_level[EquipmentManager.Slot.HELMET], EquipmentManager.equipment_level[EquipmentManager.Slot.HELMET])
		EquipmentManager.unlocked_level[EquipmentManager.Slot.GOGGLES]   = max(EquipmentManager.unlocked_level[EquipmentManager.Slot.GOGGLES], EquipmentManager.equipment_level[EquipmentManager.Slot.GOGGLES])
		EquipmentManager.unlocked_level[EquipmentManager.Slot.SNOWBOARD] = max(EquipmentManager.unlocked_level[EquipmentManager.Slot.SNOWBOARD], EquipmentManager.equipment_level[EquipmentManager.Slot.SNOWBOARD])
		EquipmentManager.unlocked_level[EquipmentManager.Slot.SUIT]      = max(EquipmentManager.unlocked_level[EquipmentManager.Slot.SUIT], EquipmentManager.equipment_level[EquipmentManager.Slot.SUIT])

	if data.has("respawn_x") and data.has("respawn_y"):
		GameManager.respawn_position = Vector2(data["respawn_x"], data["respawn_y"])

	# 复活时恢复满血，emit 信号让 HUD 刷新
	GameManager.player_hp = GameManager.player_max_hp
	GameManager.hp_changed.emit(GameManager.player_hp, GameManager.player_max_hp)

	if data.has("current_scene"):
		SceneManager.go_to(data["current_scene"], SceneManager.SAVE_RESPAWN_POINT)
	return true

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
