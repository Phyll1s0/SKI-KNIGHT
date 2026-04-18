extends Control

@onready var action_list: VBoxContainer = $Overlay/Panel/VBox/Scroll/ActionList
@onready var hint_label: Label = $Overlay/Panel/VBox/Hint

var _buttons: Dictionary = {}
var _listening_action: String = ""
var _listening_armed: bool = false
var _ignored_mouse_buttons: Dictionary = {}

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	_rebuild_rows()
	KeybindManager.bindings_changed.connect(_refresh_button_texts)

func open_panel() -> void:
	visible = true
	move_to_front()
	_cancel_listening()
	_refresh_button_texts()

func close_panel() -> void:
	visible = false
	_cancel_listening()

func _rebuild_rows() -> void:
	_buttons.clear()
	for child in action_list.get_children():
		child.queue_free()
	for entry in KeybindManager.get_actions():
		var action_name: String = String(entry.get("action", ""))
		var label_text: String = String(entry.get("label", action_name))
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		var name_label := Label.new()
		name_label.text = label_text
		name_label.custom_minimum_size = Vector2(180.0, 34.0)
		name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		var key_button := Button.new()
		key_button.custom_minimum_size = Vector2(170.0, 34.0)
		key_button.focus_mode = Control.FOCUS_NONE
		key_button.pressed.connect(_begin_listening.bind(action_name))
		row.add_child(name_label)
		row.add_child(key_button)
		action_list.add_child(row)
		_buttons[action_name] = key_button
	_refresh_button_texts()

func _begin_listening(action_name: String) -> void:
	_listening_action = action_name
	_listening_armed = false
	_ignored_mouse_buttons.clear()
	for button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]:
		if Input.is_mouse_button_pressed(button_index):
			_ignored_mouse_buttons[button_index] = true
	_refresh_button_texts()
	hint_label.text = "按下键盘/鼠标/手柄按钮进行绑定，Esc 取消，Backspace 恢复默认"
	call_deferred("_arm_listening")

func _arm_listening() -> void:
	if not _listening_action.is_empty():
		_listening_armed = true

func _cancel_listening() -> void:
	_listening_action = ""
	_listening_armed = false
	_ignored_mouse_buttons.clear()
	hint_label.text = "点击右侧按钮修改按键。支持空格、鼠标键和手柄按钮；Esc 关闭，Backspace 恢复默认。"
	_refresh_button_texts()

func _refresh_button_texts() -> void:
	for action_name in _buttons.keys():
		var button: Button = _buttons[action_name]
		if button == null:
			continue
		button.text = "按下任意键..." if action_name == _listening_action else KeybindManager.get_display_text(String(action_name))

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if _listening_action.is_empty():
		if event.is_action_pressed("ui_cancel"):
			get_viewport().set_input_as_handled()
			close_panel()
		return
	if not _listening_armed:
		return
	var captured_event: InputEvent = _capture_binding_event(event)
	if captured_event == null:
		return
	get_viewport().set_input_as_handled()
	KeybindManager.set_primary_event(_listening_action, captured_event)
	_cancel_listening()

func _capture_binding_event(event: InputEvent) -> InputEvent:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if not key_event.pressed or key_event.echo:
			return null
		if key_event.keycode == KEY_ESCAPE:
			_cancel_listening()
			return null
		if key_event.keycode == KEY_BACKSPACE:
			KeybindManager.set_primary_key(_listening_action, KEY_NONE)
			_cancel_listening()
			return null
		var rebound_key := InputEventKey.new()
		rebound_key.physical_keycode = int(key_event.physical_keycode if key_event.physical_keycode != KEY_NONE else key_event.keycode)
		return rebound_key
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if _ignored_mouse_buttons.has(mouse_event.button_index):
			if not mouse_event.pressed:
				_ignored_mouse_buttons.erase(mouse_event.button_index)
			return null
		if not mouse_event.pressed:
			return null
		var rebound_mouse := InputEventMouseButton.new()
		rebound_mouse.button_index = mouse_event.button_index
		rebound_mouse.pressed = true
		return rebound_mouse
	if event is InputEventJoypadButton:
		var joypad_event := event as InputEventJoypadButton
		if not joypad_event.pressed:
			return null
		var rebound_joypad := InputEventJoypadButton.new()
		rebound_joypad.device = -1
		rebound_joypad.button_index = joypad_event.button_index
		rebound_joypad.pressed = true
		return rebound_joypad
	return null

func _on_reset_pressed() -> void:
	KeybindManager.reset_to_default()
	_cancel_listening()

func _on_close_pressed() -> void:
	close_panel()