extends "res://scripts/systems/BaseMap.gd"

const _REMOVED_SAVEPOINT_XS: Array[float] = [1200.0, 2630.0]
const _REMOVED_SAVEPOINT_TOLERANCE: float = 96.0
const _SAFE_RESPAWN_Y: float = 656.0

func _ready() -> void:
	_correct_removed_savepoint2_respawn_if_needed()
	super._ready()

func _correct_removed_savepoint2_respawn_if_needed() -> void:
	if not _is_removed_savepoint2_respawn(GameManager.respawn_position):
		return
	GameManager.respawn_position = _get_safe_respawn_after_removed_savepoint2()
	SaveSystem.save()

func _is_removed_savepoint2_respawn(respawn_position: Vector2) -> bool:
	for savepoint_x in _REMOVED_SAVEPOINT_XS:
		if absf(respawn_position.x - savepoint_x) <= _REMOVED_SAVEPOINT_TOLERANCE:
			return true
	return false

func _get_safe_respawn_after_removed_savepoint2() -> Vector2:
	var save_point := get_node_or_null("SavePoint1") as Node2D
	if save_point != null:
		return Vector2(save_point.global_position.x, _SAFE_RESPAWN_Y)
	return Vector2(200.0, _SAFE_RESPAWN_Y)

