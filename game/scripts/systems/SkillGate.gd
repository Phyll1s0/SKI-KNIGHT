extends Area2D
# SkillGate — 技能门控
# 玩家接触时检查是否持有指定技能；未持有则显示提示并阻止通行（静态碰撞体）

const SKILL_GATE_ICON_PATH := "res://assets/sprites/ui/skill_gate_icon.png"

@export_enum("ICE_BLADE:0", "PARALLEL_SKIING:1", "CARVING:2") var required_skill: int = 1
@export var hint_text: String = "需要特定技能才能通过"

@onready var collision: CollisionShape2D = get_node_or_null("BlockCollision")
@onready var hint: Label = get_node_or_null("HintLabel")
@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")

var _hint_timer: float = 0.0

func _ready() -> void:
	var icon := _load_optional_texture(SKILL_GATE_ICON_PATH)
	if sprite != null:
		sprite.texture = icon
		sprite.visible = icon != null
	if SkillManager.has_skill(required_skill as SkillManager.Skill):
		if collision != null:
			collision.set_deferred("disabled", true)
		if hint != null:
			hint.visible = false
	if hint != null:
		hint.text = hint_text
		hint.visible = false

func _load_optional_texture(path: String) -> Texture2D:
	if path.is_empty():
		return null
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	var absolute_path := ProjectSettings.globalize_path(path)
	if not FileAccess.file_exists(absolute_path):
		return null
	var image := Image.load_from_file(absolute_path)
	if image != null and not image.is_empty():
		return ImageTexture.create_from_image(image)
	return null

func _process(delta: float) -> void:
	if _hint_timer > 0.0:
		_hint_timer -= delta
		if _hint_timer <= 0.0 and hint != null:
			hint.visible = false

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	if SkillManager.has_skill(required_skill as SkillManager.Skill):
		if collision != null:
			collision.set_deferred("disabled", true)
		if hint != null:
			hint.visible = false
	else:
		if hint != null:
			hint.visible = true
		_hint_timer = 2.5
