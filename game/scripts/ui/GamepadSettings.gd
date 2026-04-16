extends Control

@onready var sensitivity_slider: HSlider = $Overlay/Panel/VBox/Content/SensitivityRow/Slider
@onready var sensitivity_value: Label = $Overlay/Panel/VBox/Content/SensitivityRow/ValueLabel
@onready var mapping_list: VBoxContainer = $Overlay/Panel/VBox/Content/Scroll/MappingList

const DEADZONE_MIN: float = 0.05
const DEADZONE_MAX: float = 0.5
const DEFAULT_DEADZONE: float = 0.15

var _current_deadzone: float = DEFAULT_DEADZONE

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# 从 project.godot 读取当前 deadzone
	var move_left_deadzone = InputMap.action_get_deadzone("move_left")
	if move_left_deadzone > 0.0:
		_current_deadzone = move_left_deadzone
	
	# 初始化滑块
	sensitivity_slider.min_value = DEADZONE_MIN
	sensitivity_slider.max_value = DEADZONE_MAX
	sensitivity_slider.step = 0.01
	sensitivity_slider.value = _current_deadzone
	sensitivity_slider.value_changed.connect(_on_sensitivity_changed)
	
	_update_sensitivity_label()
	_build_mapping_list()
	
	$Overlay/Panel/VBox/Footer/CloseBtn.pressed.connect(close_panel)
	$Overlay/Panel/VBox/Footer/ResetBtn.pressed.connect(_reset_to_default)

func open_panel() -> void:
	visible = true
	get_tree().paused = true

func close_panel() -> void:
	visible = false
	get_tree().paused = false

func _on_sensitivity_changed(value: float) -> void:
	_current_deadzone = value
	_update_sensitivity_label()
	_apply_deadzone_to_actions()

func _update_sensitivity_label() -> void:
	var percentage := int((1.0 - _current_deadzone) * 100)
	sensitivity_value.text = str(percentage) + "%"

func _apply_deadzone_to_actions() -> void:
	# 应用到所有有摇杆的动作
	var actions_with_joystick := ["move_left", "move_right"]
	for action in actions_with_joystick:
		InputMap.action_set_deadzone(action, _current_deadzone)

func _reset_to_default() -> void:
	sensitivity_slider.value = DEFAULT_DEADZONE
	_current_deadzone = DEFAULT_DEADZONE
	_update_sensitivity_label()
	_apply_deadzone_to_actions()

func _build_mapping_list() -> void:
	for child in mapping_list.get_children():
		child.queue_free()
	
	# 手柄按键映射说明
	var mappings := [
		{"action": "移动", "key": "左摇杆 左/右 或 方向键"},
		{"action": "跳跃", "key": "A 键 (按钮0)"},
		{"action": "刹车", "key": "B 键 (按钮1)"},
		{"action": "攻击", "key": "X 键 (按钮2)"},
		{"action": "技能", "key": "Y 键 (按钮3)"},
	]
	
	for mapping in mappings:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		
		var action_label := Label.new()
		action_label.text = mapping["action"]
		action_label.custom_minimum_size = Vector2(100.0, 28.0)
		action_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		action_label.add_theme_color_override("font_color", Color(0.7, 0.9, 1.0))
		
		var key_label := Label.new()
		key_label.text = mapping["key"]
		key_label.custom_minimum_size = Vector2(280.0, 28.0)
		key_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		key_label.add_theme_color_override("font_color", Color(0.85, 0.95, 1.0, 0.9))
		
		row.add_child(action_label)
		row.add_child(key_label)
		mapping_list.add_child(row)

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close_panel()
		get_viewport().set_input_as_handled()
