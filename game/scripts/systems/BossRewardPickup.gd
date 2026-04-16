extends Area2D

enum RewardKind {
	PARALLEL_SKIING,
	SUIT_FRAGMENT,
	GOGGLES_PART,
}

@export_enum("PARALLEL_SKIING:0", "SUIT_FRAGMENT:1", "GOGGLES_PART:2") var reward_kind: int = RewardKind.PARALLEL_SKIING
@export var label_text: String = ""
@export var pickup_delay: float = 0.45
@export var launch_velocity: Vector2 = Vector2.ZERO
@export var drift_damping: float = 280.0
@export var float_amplitude: float = 4.0
@export var float_speed: float = 5.5

@onready var visual_root: Node2D = $VisualRoot
@onready var badge: Polygon2D = $VisualRoot/Badge
@onready var inner_badge: Polygon2D = $VisualRoot/InnerBadge
@onready var glyph: Label = $VisualRoot/Glyph
@onready var reward_label: Label = $VisualRoot/RewardLabel

var _can_pickup: bool = false
var _collected: bool = false
var _time: float = 0.0

func _ready() -> void:
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, true)
	_apply_visuals()
	if pickup_delay > 0.0:
		_set_pickup_enabled(false)
		var timer: SceneTreeTimer = get_tree().create_timer(pickup_delay)
		timer.timeout.connect(func() -> void:
			if is_instance_valid(self):
				_set_pickup_enabled(true)
		)
	else:
		_set_pickup_enabled(true)

func _physics_process(delta: float) -> void:
	if _collected:
		return
	_time += delta
	global_position += launch_velocity * delta
	launch_velocity = launch_velocity.move_toward(Vector2.ZERO, drift_damping * delta)
	if visual_root != null:
		visual_root.position.y = sin(_time * float_speed) * float_amplitude
	if not _can_pickup:
		return
	var player: Node2D = _get_player()
	if player == null:
		return
	if global_position.distance_to(player.global_position) <= 28.0:
		_try_collect(player)

func _on_body_entered(body: Node) -> void:
	_try_collect(body)

func _set_pickup_enabled(enabled: bool) -> void:
	_can_pickup = enabled
	set_deferred("monitoring", enabled)
	set_deferred("monitorable", enabled)

func _get_player() -> Node2D:
	var players: Array = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return null
	return players[0] as Node2D

func _apply_visuals() -> void:
	var base_color: Color = Color(0.42, 0.84, 1.0, 1.0)
	var inner_color: Color = Color(0.88, 0.97, 1.0, 1.0)
	var glyph_text: String = "技"
	if label_text.is_empty():
		match reward_kind:
			RewardKind.PARALLEL_SKIING:
				label_text = "获得平行式滑雪"
			RewardKind.SUIT_FRAGMENT:
				label_text = "获得雪服碎片"
			RewardKind.GOGGLES_PART:
				label_text = "获得雪镜零件"
	match reward_kind:
		RewardKind.PARALLEL_SKIING:
			base_color = Color(0.36, 0.82, 1.0, 1.0)
			inner_color = Color(0.88, 0.97, 1.0, 1.0)
			glyph_text = "技"
		RewardKind.SUIT_FRAGMENT:
			base_color = Color(0.92, 0.74, 0.34, 1.0)
			inner_color = Color(1.0, 0.93, 0.7, 1.0)
			glyph_text = "片"
		RewardKind.GOGGLES_PART:
			base_color = Color(0.64, 0.88, 1.0, 1.0)
			inner_color = Color(0.96, 0.99, 1.0, 1.0)
			glyph_text = "件"
	badge.color = base_color
	inner_badge.color = inner_color
	glyph.text = glyph_text
	reward_label.text = label_text

func _try_collect(body: Node) -> void:
	if _collected or not _can_pickup:
		return
	if body == null or not body.is_in_group("player"):
		return
	var is_dead: bool = bool(body.get("_is_dead")) if body.has_method("get") else false
	if is_dead:
		return
	_collected = true
	_set_pickup_enabled(false)
	_grant_reward()
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.18, 1.18), 0.08)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_callback(queue_free)

func _grant_reward() -> void:
	match reward_kind:
		RewardKind.PARALLEL_SKIING:
			if not SkillManager.has_skill(SkillManager.Skill.PARALLEL_SKIING):
				SkillManager.unlock(SkillManager.Skill.PARALLEL_SKIING)
		RewardKind.SUIT_FRAGMENT:
			GameManager.has_suit_fragment = true
		RewardKind.GOGGLES_PART:
			GameManager.has_goggles_part = true