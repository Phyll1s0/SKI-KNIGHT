extends Control

@onready var keybind_settings: Control = $KeybindSettings

func _ready() -> void:
	add_to_group("pause_menu")
	visible = false
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func open_menu() -> void:
	if visible:
		return
	visible = true
	get_tree().paused = true

func close_menu() -> void:
	if not visible:
		return
	visible = false
	get_tree().paused = false

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if keybind_settings != null and keybind_settings.visible:
		return
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_continue_pressed()

func _on_continue_pressed() -> void:
	close_menu()

func _on_settings_pressed() -> void:
	if keybind_settings != null:
		keybind_settings.call("open_panel")

func _on_menu_pressed() -> void:
	SaveSystem.save()
	close_menu()
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")