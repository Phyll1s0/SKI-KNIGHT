extends Node

signal bindings_changed

const SETTINGS_PATH := "user://skiknight_keybinds.json"
const ACTIONS := [
	{
		"action": "move_left",
		"label": "向左移动",
		"default_binding": {"kind": "key", "keycode": KEY_A},
		"fallback_bindings": [
			{"kind": "key", "keycode": KEY_LEFT},
			{"kind": "joy_button", "button_index": JOY_BUTTON_DPAD_LEFT},
		],
	},
	{
		"action": "move_right",
		"label": "向右移动",
		"default_binding": {"kind": "key", "keycode": KEY_D},
		"fallback_bindings": [
			{"kind": "key", "keycode": KEY_RIGHT},
			{"kind": "joy_button", "button_index": JOY_BUTTON_DPAD_RIGHT},
		],
	},
	{
		"action": "jump",
		"label": "跳跃",
		"default_binding": {"kind": "key", "keycode": KEY_SPACE},
		"fallback_bindings": [
			{"kind": "key", "keycode": KEY_UP},
			{"kind": "key", "keycode": KEY_W},
			{"kind": "joy_button", "button_index": JOY_BUTTON_A},
		],
	},
	{
		"action": "brake",
		"label": "刹车",
		"default_binding": {"kind": "key", "keycode": KEY_S},
		"fallback_bindings": [
			{"kind": "key", "keycode": KEY_DOWN},
			{"kind": "joy_button", "button_index": JOY_BUTTON_LEFT_STICK},
		],
	},
	{
		"action": "attack",
		"label": "攻击",
		"default_binding": {"kind": "key", "keycode": KEY_J},
		"fallback_bindings": [
			{"kind": "joy_button", "button_index": JOY_BUTTON_X},
		],
	},
	{
		"action": "skill",
		"label": "技能",
		"default_binding": {"kind": "key", "keycode": KEY_K},
		"fallback_bindings": [
			{"kind": "joy_button", "button_index": JOY_BUTTON_Y},
		],
	},
	{
		"action": "interact",
		"label": "交互",
		"default_binding": {"kind": "key", "keycode": KEY_F},
		"fallback_bindings": [
			{"kind": "joy_button", "button_index": JOY_BUTTON_B},
		],
	},
	{
		"action": "ui_cancel",
		"label": "暂停/取消",
		"default_binding": {"kind": "key", "keycode": KEY_ESCAPE},
		"fallback_bindings": [
			{"kind": "joy_button", "button_index": JOY_BUTTON_START},
		],
	},
	{
		"action": "toggle_minimap",
		"label": "小地图显隐",
		"default_binding": {"kind": "key", "keycode": KEY_TAB},
		"fallback_bindings": [
			{"kind": "joy_button", "button_index": JOY_BUTTON_BACK},
		],
	},
	{
		"action": "minimap_zoom_in",
		"label": "小地图放大",
		"default_binding": {"kind": "key", "keycode": KEY_EQUAL},
		"fallback_bindings": [
			{"kind": "key", "keycode": KEY_KP_ADD},
			{"kind": "joy_button", "button_index": JOY_BUTTON_LEFT_SHOULDER},
		],
	},
	{
		"action": "minimap_zoom_out",
		"label": "小地图缩小",
		"default_binding": {"kind": "key", "keycode": KEY_MINUS},
		"fallback_bindings": [
			{"kind": "key", "keycode": KEY_KP_SUBTRACT},
			{"kind": "joy_button", "button_index": JOY_BUTTON_RIGHT_SHOULDER},
		],
	},
]

const _MOUSE_BUTTON_NAMES := {
	MOUSE_BUTTON_LEFT: "鼠标左键",
	MOUSE_BUTTON_RIGHT: "鼠标右键",
	MOUSE_BUTTON_MIDDLE: "鼠标中键",
	MOUSE_BUTTON_WHEEL_UP: "滚轮上",
	MOUSE_BUTTON_WHEEL_DOWN: "滚轮下",
	MOUSE_BUTTON_WHEEL_LEFT: "滚轮左",
	MOUSE_BUTTON_WHEEL_RIGHT: "滚轮右",
	MOUSE_BUTTON_XBUTTON1: "鼠标侧键1",
	MOUSE_BUTTON_XBUTTON2: "鼠标侧键2",
}

const _JOY_BUTTON_NAMES := {
	JOY_BUTTON_A: "手柄 A",
	JOY_BUTTON_B: "手柄 B",
	JOY_BUTTON_X: "手柄 X",
	JOY_BUTTON_Y: "手柄 Y",
	JOY_BUTTON_BACK: "手柄 Back",
	JOY_BUTTON_GUIDE: "手柄 Guide",
	JOY_BUTTON_START: "手柄 Start",
	JOY_BUTTON_LEFT_STICK: "左摇杆按下",
	JOY_BUTTON_RIGHT_STICK: "右摇杆按下",
	JOY_BUTTON_LEFT_SHOULDER: "左肩键",
	JOY_BUTTON_RIGHT_SHOULDER: "右肩键",
	JOY_BUTTON_DPAD_UP: "十字键上",
	JOY_BUTTON_DPAD_DOWN: "十字键下",
	JOY_BUTTON_DPAD_LEFT: "十字键左",
	JOY_BUTTON_DPAD_RIGHT: "十字键右",
}

var custom_bindings: Dictionary = {}
var _action_meta: Dictionary = {}

func _ready() -> void:
	for entry in ACTIONS:
		_action_meta[String(entry.get("action", ""))] = entry
	_load_bindings()
	apply_bindings()

func get_actions() -> Array:
	return ACTIONS.duplicate(true)

func get_action_label(action_name: String) -> String:
	var entry: Dictionary = _action_meta.get(action_name, {})
	return String(entry.get("label", action_name))

func get_primary_keycode(action_name: String) -> int:
	var binding: Dictionary = _get_primary_binding(action_name)
	return int(binding.get("keycode", KEY_NONE)) if String(binding.get("kind", "")) == "key" else KEY_NONE

func get_primary_event(action_name: String) -> InputEvent:
	return _binding_to_event(_get_primary_binding(action_name))

func get_display_text(action_name: String) -> String:
	var binding: Dictionary = _get_primary_binding(action_name)
	return _binding_to_text(binding)

func set_primary_event(action_name: String, event: InputEvent) -> void:
	if not _action_meta.has(action_name):
		return
	var binding: Dictionary = _serialize_event(event)
	if binding.is_empty():
		return
	custom_bindings[action_name] = binding
	apply_bindings()
	_save_bindings()

func set_primary_key(action_name: String, keycode: int) -> void:
	if not _action_meta.has(action_name):
		return
	if keycode == KEY_NONE:
		custom_bindings.erase(action_name)
	else:
		custom_bindings[action_name] = _make_key_binding(keycode)
	apply_bindings()
	_save_bindings()

func reset_to_default() -> void:
	custom_bindings.clear()
	apply_bindings()
	_save_bindings()

func apply_bindings() -> void:
	for entry in ACTIONS:
		var action_name: String = String(entry.get("action", ""))
		if action_name.is_empty():
			continue
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
		InputMap.action_erase_events(action_name)
		_add_binding_event(action_name, _get_primary_binding(action_name))
		for fallback_binding in entry.get("fallback_bindings", []):
			_add_binding_event(action_name, _normalize_binding(fallback_binding))
	# 始终为移动动作添加左摇杆轴绑定（不可自定义，确保模拟输入正常）
	_add_joy_axis_event("move_left",  JOY_AXIS_LEFT_X, -1.0)
	_add_joy_axis_event("move_right", JOY_AXIS_LEFT_X,  1.0)
	bindings_changed.emit()

func _add_joy_axis_event(action_name: String, axis: int, axis_value: float) -> void:
	if not InputMap.has_action(action_name):
		return
	for existing in InputMap.action_get_events(action_name):
		if existing is InputEventJoypadMotion:
			var joy_motion := existing as InputEventJoypadMotion
			if joy_motion.axis == axis and sign(joy_motion.axis_value) == sign(axis_value):
				return
	var motion_event := InputEventJoypadMotion.new()
	motion_event.device = -1
	motion_event.axis = axis
	motion_event.axis_value = axis_value
	InputMap.action_add_event(action_name, motion_event)

func _get_primary_binding(action_name: String) -> Dictionary:
	if custom_bindings.has(action_name):
		return _normalize_binding(custom_bindings[action_name])
	var entry: Dictionary = _action_meta.get(action_name, {})
	return _normalize_binding(entry.get("default_binding", {}))

func _add_binding_event(action_name: String, binding: Dictionary) -> void:
	if binding.is_empty():
		return
	for existing in InputMap.action_get_events(action_name):
		if _serialize_event(existing) == binding:
			return
	var event: InputEvent = _binding_to_event(binding)
	if event == null:
		return
	InputMap.action_add_event(action_name, event)

func _make_key_binding(keycode: int) -> Dictionary:
	return {"kind": "key", "keycode": keycode}

func _normalize_binding(value: Variant) -> Dictionary:
	if value is int:
		return _make_key_binding(int(value))
	if not value is Dictionary:
		return {}
	var binding: Dictionary = value
	match String(binding.get("kind", "")):
		"key":
			return {"kind": "key", "keycode": int(binding.get("keycode", KEY_NONE))}
		"mouse_button":
			return {"kind": "mouse_button", "button_index": int(binding.get("button_index", MOUSE_BUTTON_NONE))}
		"joy_button":
			return {"kind": "joy_button", "button_index": int(binding.get("button_index", -1))}
		_:
			return {}

func _binding_to_event(binding: Dictionary) -> InputEvent:
	match String(binding.get("kind", "")):
		"key":
			var keycode: int = int(binding.get("keycode", KEY_NONE))
			if keycode == KEY_NONE:
				return null
			var key_event := InputEventKey.new()
			key_event.physical_keycode = keycode
			return key_event
		"mouse_button":
			var button_index: int = int(binding.get("button_index", MOUSE_BUTTON_NONE))
			if button_index == MOUSE_BUTTON_NONE:
				return null
			var mouse_event := InputEventMouseButton.new()
			mouse_event.button_index = button_index
			mouse_event.pressed = true
			return mouse_event
		"joy_button":
			var joy_button: int = int(binding.get("button_index", -1))
			if joy_button < 0:
				return null
			var joy_event := InputEventJoypadButton.new()
			joy_event.device = -1
			joy_event.button_index = joy_button
			joy_event.pressed = true
			return joy_event
		_:
			return null

func _serialize_event(event: InputEvent) -> Dictionary:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		var keycode: int = int(key_event.physical_keycode if key_event.physical_keycode != KEY_NONE else key_event.keycode)
		return _make_key_binding(keycode) if keycode != KEY_NONE else {}
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		return {
			"kind": "mouse_button",
			"button_index": int(mouse_event.button_index),
		} if mouse_event.button_index != MOUSE_BUTTON_NONE else {}
	if event is InputEventJoypadButton:
		var joy_event := event as InputEventJoypadButton
		return {
			"kind": "joy_button",
			"button_index": int(joy_event.button_index),
		} if joy_event.button_index >= 0 else {}
	return {}

func _binding_to_text(binding: Dictionary) -> String:
	match String(binding.get("kind", "")):
		"key":
			var keycode: int = int(binding.get("keycode", KEY_NONE))
			return OS.get_keycode_string(keycode) if keycode != KEY_NONE else "未设置"
		"mouse_button":
			var mouse_button: int = int(binding.get("button_index", MOUSE_BUTTON_NONE))
			return String(_MOUSE_BUTTON_NAMES.get(mouse_button, "鼠标按键 %d" % mouse_button))
		"joy_button":
			var joy_button: int = int(binding.get("button_index", -1))
			return String(_JOY_BUTTON_NAMES.get(joy_button, "手柄按钮 %d" % joy_button))
		_:
			return "未设置"

func _load_bindings() -> void:
	custom_bindings.clear()
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		return
	for action_name in parsed.keys():
		if _action_meta.has(String(action_name)):
			var binding: Dictionary = _normalize_binding(parsed[action_name])
			if not binding.is_empty():
				custom_bindings[String(action_name)] = binding

func _save_bindings() -> void:
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(custom_bindings, "\t"))
	file.close()