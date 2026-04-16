extends Area2D

@export var amount: int = 1
@export var pickup_delay: float = 0.18
@export var magnet_radius: float = 120.0
@export var magnet_speed: float = 420.0
@export var drift_damping: float = 260.0
@export var float_amplitude: float = 3.0
@export var float_speed: float = 6.0
@export var launch_velocity: Vector2 = Vector2.ZERO

@onready var visual_root: Node2D = $VisualRoot
@onready var amount_label: Label = $VisualRoot/AmountLabel

var _can_pickup: bool = false
var _collected: bool = false
var _time: float = 0.0

func _ready() -> void:
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, true)
	monitoring = true
	monitorable = true
	_refresh_label()
	if pickup_delay > 0.0:
		_can_pickup = false
		monitoring = false
		var timer: SceneTreeTimer = get_tree().create_timer(pickup_delay)
		timer.timeout.connect(func() -> void:
			if is_instance_valid(self):
				_can_pickup = true
				monitoring = true
		)
	else:
		_can_pickup = true

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
	var distance: float = global_position.distance_to(player.global_position)
	if distance <= 20.0:
		_try_collect(player)
		return
	if distance <= magnet_radius:
		global_position = global_position.move_toward(player.global_position, magnet_speed * delta)

func _refresh_label() -> void:
	if amount_label != null:
		amount_label.text = "%d G" % max(amount, 1)

func _get_player() -> Node2D:
	var players: Array = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return null
	var player: Node = players[0]
	return player as Node2D

func _on_body_entered(body: Node) -> void:
	_try_collect(body)

func _try_collect(body: Node) -> void:
	if _collected or not _can_pickup:
		return
	if body == null or not body.is_in_group("player"):
		return
	var is_dead: bool = bool(body.get("_is_dead")) if body.has_method("get") else false
	if is_dead:
		return
	_collected = true
	monitoring = false
	GameManager.add_gold(max(amount, 1))
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.18, 1.18), 0.08)
	tween.tween_property(self, "modulate:a", 0.0, 0.12)
	tween.tween_callback(queue_free)