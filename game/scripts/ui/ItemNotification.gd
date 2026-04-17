extends CanvasLayer
# ItemNotification — 装备/技能获得时的全屏提示
# 显示物品名称和描述，自动淡入淡出

@onready var panel: PanelContainer = $Panel
@onready var item_name_label: Label = $Panel/VBox/ItemName
@onready var description_label: Label = $Panel/VBox/Description

var _is_showing: bool = false
var _done_callback: Callable = Callable()

func _ready() -> void:
	layer = 99
	panel.modulate.a = 0.0
	hide()

func is_showing() -> bool:
	return _is_showing

func show_notification(item_name: String, description: String, done_callback: Callable = Callable()) -> void:
	if _is_showing:
		return
	_is_showing = true
	_done_callback = done_callback
	item_name_label.text = item_name
	description_label.text = description
	show()
	
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	# 淡入
	tween.tween_property(panel, "modulate:a", 1.0, 0.4)
	# 停留
	tween.tween_interval(2.5)
	# 淡出
	tween.tween_property(panel, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func():
		hide()
		_is_showing = false
		if _done_callback.is_valid():
			_done_callback.call()
	)
