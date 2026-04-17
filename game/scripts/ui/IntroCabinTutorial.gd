extends CanvasLayer

const INITIAL_DELAY := 3.0
const GAP_DURATION := 3.0

enum TutorialPhase {
	INITIAL_WAIT,
	SHOW_MOVE,
	GAP_AFTER_MOVE,
	SHOW_JUMP,
	GAP_AFTER_JUMP,
	SHOW_ATTACK,
	DONE,
}

@onready var hint_panel: PanelContainer = $CenterContainer/HintPanel
@onready var keys_label: Label = $CenterContainer/HintPanel/Padding/VBox/KeysLabel
@onready var description_label: Label = $CenterContainer/HintPanel/Padding/VBox/DescriptionLabel

var _phase: TutorialPhase = TutorialPhase.INITIAL_WAIT
var _timer: float = INITIAL_DELAY
var _did_move_input: bool = false
var _did_jump_input: bool = false
var _did_attack_input: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	hint_panel.visible = false
	KeybindManager.bindings_changed.connect(_on_bindings_changed)

func _process(delta: float) -> void:
	_capture_action_progress()

	if _phase == TutorialPhase.DONE:
		set_process(false)
		return

	match _phase:
		TutorialPhase.INITIAL_WAIT:
			_timer -= delta
			if _timer <= 0.0:
				_begin_move_phase()
		TutorialPhase.SHOW_MOVE:
			if _did_move_input:
				_hide_hint()
				_phase = TutorialPhase.GAP_AFTER_MOVE
				_timer = GAP_DURATION
		TutorialPhase.GAP_AFTER_MOVE:
			_timer -= delta
			if _timer <= 0.0:
				_begin_jump_phase()
		TutorialPhase.SHOW_JUMP:
			if _did_jump_input:
				_hide_hint()
				_phase = TutorialPhase.GAP_AFTER_JUMP
				_timer = GAP_DURATION
		TutorialPhase.GAP_AFTER_JUMP:
			_timer -= delta
			if _timer <= 0.0:
				_begin_attack_phase()
		TutorialPhase.SHOW_ATTACK:
			if _did_attack_input:
				_hide_hint()
				_phase = TutorialPhase.DONE
		TutorialPhase.DONE:
			pass

func _on_bindings_changed() -> void:
	match _phase:
		TutorialPhase.SHOW_MOVE:
			_show_move_hint()
		TutorialPhase.SHOW_JUMP:
			_show_jump_hint()
		TutorialPhase.SHOW_ATTACK:
			_show_attack_hint()
		_:
			pass

func _show_move_hint() -> void:
	_show_hint(_get_move_hint_text(), "向左右移动")

func _show_jump_hint() -> void:
	_show_hint(_get_jump_hint_text(), "跳跃")

func _show_attack_hint() -> void:
	_show_hint(_get_attack_hint_text(), "攻击")

func _begin_move_phase() -> void:
	if _did_move_input:
		_phase = TutorialPhase.GAP_AFTER_MOVE
		_timer = GAP_DURATION
		return
	_show_move_hint()
	_phase = TutorialPhase.SHOW_MOVE

func _begin_jump_phase() -> void:
	if _did_jump_input:
		_phase = TutorialPhase.GAP_AFTER_JUMP
		_timer = GAP_DURATION
		return
	_show_jump_hint()
	_phase = TutorialPhase.SHOW_JUMP

func _begin_attack_phase() -> void:
	if _did_attack_input:
		_phase = TutorialPhase.DONE
		return
	_show_attack_hint()
	_phase = TutorialPhase.SHOW_ATTACK

func _show_hint(keys_text: String, description_text: String) -> void:
	keys_label.text = keys_text
	description_label.text = description_text
	hint_panel.visible = true
	hint_panel.modulate.a = 1.0

func _hide_hint() -> void:
	hint_panel.visible = false

func _capture_action_progress() -> void:
	if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right"):
		_did_move_input = true
	if Input.is_action_just_pressed("jump"):
		_did_jump_input = true
	if Input.is_action_just_pressed("attack"):
		_did_attack_input = true

func _get_move_hint_text() -> String:
	var left_text := _get_preferred_action_key_text("move_left", [KEY_A, KEY_LEFT])
	var right_text := _get_preferred_action_key_text("move_right", [KEY_D, KEY_RIGHT])
	return "%s / %s" % [left_text, right_text]

func _get_jump_hint_text() -> String:
	var jump_keys := _get_preferred_action_key_texts("jump", [KEY_W, KEY_SPACE, KEY_UP], 2)
	if jump_keys.is_empty():
		return "W / 空格"
	if jump_keys.size() == 1:
		return jump_keys[0]
	return " / ".join(jump_keys)

func _get_attack_hint_text() -> String:
	return _get_preferred_action_key_text("attack", [KEY_J])

func _get_preferred_action_key_text(action_name: String, preferred_keycodes: Array[int]) -> String:
	var key_texts := _get_preferred_action_key_texts(action_name, preferred_keycodes, 1)
	if key_texts.is_empty():
		return "?"
	return key_texts[0]

func _get_preferred_action_key_texts(action_name: String, preferred_keycodes: Array[int], max_count: int) -> Array[String]:
	var by_keycode: Dictionary = {}
	var all_keycodes: Array[int] = []
	for event in InputMap.action_get_events(action_name):
		if not event is InputEventKey:
			continue
		var key_event := event as InputEventKey
		var keycode := int(key_event.physical_keycode if key_event.physical_keycode != KEY_NONE else key_event.keycode)
		if keycode == KEY_NONE or by_keycode.has(keycode):
			continue
		by_keycode[keycode] = _format_key_text(keycode)
		all_keycodes.append(keycode)

	var results: Array[String] = []
	for preferred_keycode in preferred_keycodes:
		if not by_keycode.has(preferred_keycode):
			continue
		results.append(String(by_keycode[preferred_keycode]))
		if results.size() >= max_count:
			return results

	for keycode in all_keycodes:
		var text := String(by_keycode[keycode])
		if results.has(text):
			continue
		results.append(text)
		if results.size() >= max_count:
			break
	return results

func _format_key_text(keycode: int) -> String:
	match keycode:
		KEY_SPACE:
			return "空格"
		KEY_LEFT:
			return "左"
		KEY_RIGHT:
			return "右"
		KEY_UP:
			return "上"
		_:
			return OS.get_keycode_string(keycode).to_upper()