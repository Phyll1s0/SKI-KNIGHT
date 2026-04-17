extends Control

const INTRO_DURATION := 10.0
const GAME_SCENE_PATH := "res://scenes/maps/TestMap.tscn"

@onready var intro_label: Label = $IntroLabel

func _ready() -> void:
	intro_label.modulate.a = 0.0
	var fade_in := create_tween()
	fade_in.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	fade_in.tween_property(intro_label, "modulate:a", 1.0, 0.8)

	await get_tree().create_timer(INTRO_DURATION).timeout
	SceneManager.go_to(GAME_SCENE_PATH)