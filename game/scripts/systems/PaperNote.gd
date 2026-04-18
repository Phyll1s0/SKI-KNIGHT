extends Area2D

@export_multiline var note_text: String = ""
@export var signature_text: String = "—— 师傅"
@export var prompt_action_text: String = "阅读纸条"

@onready var prompt_label: Label = $PromptLabel
@onready var dim: ColorRect = $NoteCanvas/Dim
@onready var note_panel: PanelContainer = $NoteCanvas/NotePanel
@onready var title_label: Label = $NoteCanvas/NotePanel/Margin/VBox/TitleLabel
@onready var body_label: Label = $NoteCanvas/NotePanel/Margin/VBox/BodyLabel
@onready var signature_label: Label = $NoteCanvas/NotePanel/Margin/VBox/SignatureLabel
@onready var close_tip: Label = $NoteCanvas/NotePanel/Margin/VBox/CloseTip

var _player_nearby: bool = false
var _open: bool = false
var _did_pause_tree: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, true)
	prompt_label.visible = false
	dim.visible = false
	note_panel.visible = false
	_apply_note_font_overrides()
	body_label.text = note_text
	signature_label.text = signature_text
	KeybindManager.bindings_changed.connect(_refresh_input_hints)
	_refresh_input_hints()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and _player_nearby:
		_toggle_note()
		return
	if Input.is_action_just_pressed("ui_cancel") and _open:
		_toggle_note()

func _refresh_input_hints() -> void:
	prompt_label.text = "[%s] %s" % [
		KeybindManager.get_combined_display_text("interact"),
		prompt_action_text,
	]
	close_tip.text = "[ %s ] 收起   [ %s ] 关闭" % [
		KeybindManager.get_combined_display_text("interact"),
		KeybindManager.get_combined_display_text("ui_cancel"),
	]

func _apply_note_font_overrides() -> void:
	if ThemeDB.fallback_font == null:
		return
	title_label.add_theme_font_override("font", _make_font_variation(2))
	prompt_label.add_theme_font_override("font", _make_font_variation(1))
	body_label.add_theme_font_override("font", _make_font_variation(1))
	signature_label.add_theme_font_override("font", _make_font_variation(2))
	close_tip.add_theme_font_override("font", _make_font_variation(1))

func _make_font_variation(glyph_spacing: int) -> FontVariation:
	var font := FontVariation.new()
	font.base_font = ThemeDB.fallback_font
	font.spacing_glyph = glyph_spacing
	return font

func _toggle_note() -> void:
	_open = not _open
	dim.visible = _open
	note_panel.visible = _open
	if _open:
		if not get_tree().paused:
			get_tree().paused = true
			_did_pause_tree = true
		prompt_label.visible = false
	else:
		if _did_pause_tree:
			get_tree().paused = false
			_did_pause_tree = false
		prompt_label.visible = _player_nearby

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	_player_nearby = true
	if not _open:
		prompt_label.visible = true

func _on_body_exited(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	_player_nearby = false
	prompt_label.visible = false