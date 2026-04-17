extends Control

const INTRO_DURATION := 5.0
const FADE_IN_DURATION := 0.8
const FADE_OUT_DURATION := 0.8
const INTRO_FONT_SIZE := 34
const INTRO_GLYPH_SPACING := 2
const GAME_SCENE_PATH := "res://scenes/maps/IntroCabin.tscn"

@onready var intro_label: Label = $IntroLabel

func _ready() -> void:
	_apply_text_style()
	intro_label.modulate.a = 0.0

	var fade_in := create_tween()
	fade_in.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	fade_in.tween_property(intro_label, "modulate:a", 1.0, FADE_IN_DURATION)
	await fade_in.finished

	var hold_duration: float = max(INTRO_DURATION - FADE_IN_DURATION - FADE_OUT_DURATION, 0.0)
	if hold_duration > 0.0:
		await get_tree().create_timer(hold_duration).timeout

	var fade_out := create_tween()
	fade_out.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	fade_out.tween_property(intro_label, "modulate:a", 0.0, FADE_OUT_DURATION)
	await fade_out.finished

	SceneManager.go_to(GAME_SCENE_PATH)

func _apply_text_style() -> void:
	intro_label.add_theme_font_size_override("font_size", INTRO_FONT_SIZE)
	if ThemeDB.fallback_font == null:
		return
	var spaced_font := FontVariation.new()
	spaced_font.base_font = ThemeDB.fallback_font
	spaced_font.spacing_glyph = INTRO_GLYPH_SPACING
	intro_label.add_theme_font_override("font", spaced_font)