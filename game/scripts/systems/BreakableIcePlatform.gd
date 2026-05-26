extends StaticBody2D
# BreakableIcePlatform — 站上后短暂碎裂，随后复原

@export var break_delay: float = 0.65
@export var respawn_delay: float = 2.4

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var trigger: Area2D = $Trigger
@onready var visual: Polygon2D = $Visual
@onready var crack_a: Line2D = $CrackA
@onready var crack_b: Line2D = $CrackB

var _breaking: bool = false
var _broken: bool = false

func _ready() -> void:
	trigger.set_collision_mask_value(1, false)
	trigger.set_collision_mask_value(2, true)
	trigger.body_entered.connect(_on_trigger_body_entered)
	_set_cracks_visible(false)

func _on_trigger_body_entered(body: Node) -> void:
	if _breaking or _broken or not body.is_in_group("player"):
		return
	_breaking = true
	_set_cracks_visible(true)
	var tween: Tween = create_tween()
	tween.tween_property(visual, "modulate", Color(1.25, 1.25, 1.25, 1.0), break_delay * 0.45)
	tween.tween_property(visual, "modulate", Color(0.72, 0.88, 1.0, 0.72), break_delay * 0.55)
	tween.tween_callback(_break_platform)

func _break_platform() -> void:
	_breaking = false
	_broken = true
	collision.set_deferred("disabled", true)
	trigger.set_deferred("monitoring", false)
	visual.visible = false
	_set_cracks_visible(false)
	await get_tree().create_timer(respawn_delay).timeout
	_restore_platform()

func _restore_platform() -> void:
	_broken = false
	collision.set_deferred("disabled", false)
	trigger.set_deferred("monitoring", true)
	visual.visible = true
	visual.modulate = Color(1, 1, 1, 1)

func _set_cracks_visible(is_visible: bool) -> void:
	if crack_a != null:
		crack_a.visible = is_visible
	if crack_b != null:
		crack_b.visible = is_visible
