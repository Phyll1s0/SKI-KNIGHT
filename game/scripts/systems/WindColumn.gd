extends Area2D
# WindColumn — 垂直风柱/上升气流，用于高地和顶峰的路线变化

@export var lift_speed: float = -520.0
@export var horizontal_force: float = 0.0
@export var max_horizontal_speed: float = 560.0

var _bodies: Array[CharacterBody2D] = []

func _ready() -> void:
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, true)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _physics_process(delta: float) -> void:
	for body in _bodies.duplicate():
		if not is_instance_valid(body):
			_bodies.erase(body)
			continue
		body.velocity.y = minf(body.velocity.y, lift_speed)
		if not is_zero_approx(horizontal_force):
			body.velocity.x = clampf(
				body.velocity.x + horizontal_force * delta,
				-max_horizontal_speed,
				max_horizontal_speed
			)

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D and body.is_in_group("player") and not _bodies.has(body):
		_bodies.append(body)

func _on_body_exited(body: Node) -> void:
	if body is CharacterBody2D:
		_bodies.erase(body)
