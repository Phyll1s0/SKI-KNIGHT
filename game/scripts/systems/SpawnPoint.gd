extends Marker2D
# SpawnPoint — 玩家出生点
# 地图加载完成后，BaseMap._ready() 会找到 SceneManager 指定的 spawn_point 并移动玩家

@export var point_name: String = "DefaultSpawn"

func _ready() -> void:
	add_to_group("spawn_point")
