extends Node
# SoundManager — Autoload
# 占位框架：挂载实际音频文件后替换 null；所有 play_* 调用在文件不存在时静默跳过

# ── 音效槽 ────────────────────────────────────────────────────
# 每个槽一个专用 AudioStreamPlayer（避免同帧多音效互相打断）
@onready var _player_attack:  AudioStreamPlayer = $PlayerAttack
@onready var _player_hurt:    AudioStreamPlayer = $PlayerHurt
@onready var _player_jump:    AudioStreamPlayer = $PlayerJump
@onready var _enemy_hurt:     AudioStreamPlayer = $EnemyHurt
@onready var _enemy_die:      AudioStreamPlayer = $EnemyDie
@onready var _skill_iceblade: AudioStreamPlayer = $SkillIceBlade
@onready var _portal:         AudioStreamPlayer = $Portal
@onready var _pickup:         AudioStreamPlayer = $Pickup
@onready var _music:          AudioStreamPlayer = $Music

# ── 音乐槽（5 张地图 + 主菜单） ──────────────────────────────
# key: 场景文件名（不含路径和扩展名）, value: 资源路径
const MUSIC_MAP: Dictionary = {
	"MainMenu":          "res://assets/sounds/music/main_menu.ogg",
	"TestMap":           "res://assets/sounds/music/snow_entrance.ogg",
	"GlacierMaze":       "res://assets/sounds/music/glacier_maze.ogg",
	"BlizzardHighlands": "res://assets/sounds/music/blizzard.ogg",
	"IceCave":           "res://assets/sounds/music/ice_cave.ogg",
	"SnowyPeak":         "res://assets/sounds/music/snowy_peak.ogg",
}

# ── 工具 ─────────────────────────────────────────────────────
func _play(player: AudioStreamPlayer) -> void:
	if player and player.stream != null:
		player.play()

func play_player_attack()  -> void: _play(_player_attack)
func play_player_hurt()    -> void: _play(_player_hurt)
func play_player_jump()    -> void: _play(_player_jump)
func play_enemy_hurt()     -> void: _play(_enemy_hurt)
func play_enemy_die()      -> void: _play(_enemy_die)
func play_skill_iceblade() -> void: _play(_skill_iceblade)
func play_portal()         -> void: _play(_portal)
func play_pickup()         -> void: _play(_pickup)

func play_music_for_scene(scene_name: String) -> void:
	var path: String = MUSIC_MAP.get(scene_name, "")
	if path.is_empty():
		_music.stop()
		return
	var stream: AudioStream = load(path) if ResourceLoader.exists(path) else null
	if stream == null:
		return   # 文件尚未制作，静默跳过
	if _music.stream == stream and _music.playing:
		return   # 已在播放同一首，不重置
	_music.stream = stream
	_music.play()

func stop_music() -> void:
	_music.stop()
