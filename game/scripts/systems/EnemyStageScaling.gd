extends RefCounted

static func resolve_multiplier(node: Node) -> int:
	if node == null:
		return 1
	var inherited_multiplier: int = _resolve_map_multiplier(node)
	if inherited_multiplier > 0:
		return inherited_multiplier
	var path: String = _resolve_scene_path(node)
	if path.ends_with("BlizzardHighlands.tscn"):
		return 2
	if path.ends_with("IceCave.tscn"):
		return 3
	if path.ends_with("SnowyPeak.tscn"):
		return 4
	return 1

static func _resolve_map_multiplier(node: Node) -> int:
	var cursor: Node = node
	while cursor != null:
		var value = cursor.get("enemy_stage_multiplier")
		if typeof(value) == TYPE_INT and int(value) > 0:
			return int(value)
		cursor = cursor.get_parent()
	return 0

static func _resolve_scene_path(node: Node) -> String:
	var cursor: Node = node
	while cursor != null:
		if not cursor.scene_file_path.is_empty():
			return cursor.scene_file_path
		cursor = cursor.get_parent()
	var tree: SceneTree = node.get_tree()
	if tree != null and tree.current_scene != null:
		return tree.current_scene.scene_file_path
	return ""