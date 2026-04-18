extends Area2D

@export_multiline var message_text: String = ""
@export var prompt_action_text: String = "查看碑文"
@export var quote_duration: float = 5.0

@onready var prompt_label: Label = $PromptLabel

var _player_nearby: bool = false
var _showing_quote: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, true)
	prompt_label.visible = false
	KeybindManager.bindings_changed.connect(_refresh_prompt)
	_refresh_prompt()

func _process(_delta: float) -> void:
	if _showing_quote:
		return
	if not _player_nearby:
		return
	if not Input.is_action_just_pressed("interact"):
		return
	if message_text.strip_edges().is_empty():
		return
	_showing_quote = true
	prompt_label.visible = false
	await SceneManager.show_story_quote(message_text, quote_duration)
	_showing_quote = false
	if _player_nearby:
		prompt_label.visible = true

func _refresh_prompt() -> void:
	prompt_label.text = "[%s] %s" % [
		KeybindManager.get_combined_display_text("interact"),
		prompt_action_text,
	]

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	_player_nearby = true
	if not _showing_quote:
		prompt_label.visible = true

func _on_body_exited(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	_player_nearby = false
	prompt_label.visible = false