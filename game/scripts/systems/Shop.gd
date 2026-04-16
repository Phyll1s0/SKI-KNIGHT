extends Area2D
# Shop — 商人/铁匠 NPC
# 玩家进入范围后显示 [F] 提示，按 F 开/关购买面板

@export var shop_name: String = "冰川迷宫·铁匠商人"
@export_enum("MERCHANT:0", "WORKSHOP:1") var shop_role: int = 0

const ROLE_MERCHANT := 0
const ROLE_WORKSHOP := 1

@onready var prompt_label: Label  = $PromptLabel
@onready var shop_panel: Panel    = $ShopCanvas/ShopPanel
@onready var gold_label: Label    = $ShopCanvas/ShopPanel/VBox/GoldRow/GoldAmount
@onready var title_label: Label   = $ShopCanvas/ShopPanel/VBox/Title
@onready var close_tip: Label     = $ShopCanvas/ShopPanel/VBox/CloseTip

@onready var btn_helmet:  Button  = $ShopCanvas/ShopPanel/VBox/HelmetRow/BuyBtn
@onready var lbl_helmet:  Label   = $ShopCanvas/ShopPanel/VBox/HelmetRow/StatusLbl
@onready var btn_suit:    Button  = $ShopCanvas/ShopPanel/VBox/SuitRow/BuyBtn
@onready var lbl_suit:    Label   = $ShopCanvas/ShopPanel/VBox/SuitRow/StatusLbl
@onready var btn_board:   Button  = $ShopCanvas/ShopPanel/VBox/BoardRow/BuyBtn
@onready var lbl_board:   Label   = $ShopCanvas/ShopPanel/VBox/BoardRow/StatusLbl
@onready var btn_goggles: Button  = $ShopCanvas/ShopPanel/VBox/GogglesRow/BuyBtn
@onready var lbl_goggles: Label   = $ShopCanvas/ShopPanel/VBox/GogglesRow/StatusLbl

var _player_nearby: bool = false
var _open: bool = false

func _ready() -> void:
	add_to_group("shop")
	# 只感知玩家 (layer 2)
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, true)
	prompt_label.visible = false
	shop_panel.visible   = false
	title_label.text = "⚒  " + shop_name
	GameManager.gold_changed.connect(_refresh_ui)
	KeybindManager.bindings_changed.connect(_refresh_input_hints)
	_refresh_input_hints()

func _process(_delta: float) -> void:
	# 用 Input 轮询，绕过 CanvasLayer GUI 对事件的拦截
	if Input.is_action_just_pressed("interact") and _player_nearby:
		_toggle_shop()
	elif Input.is_action_just_pressed("ui_cancel") and _open:
		_toggle_shop()

func _toggle_shop() -> void:
	_open = not _open
	shop_panel.visible = _open
	if _open:
		_refresh_ui()

func _refresh_input_hints() -> void:
	prompt_label.text = "[%s] 购物" % KeybindManager.get_display_text("interact")
	close_tip.text = "[ %s ] 开/关   [ %s ] 关闭" % [
		KeybindManager.get_display_text("interact"),
		KeybindManager.get_display_text("ui_cancel")
	]

# _dummy 用于兼容 gold_changed(amount: int) 信号签名
func _refresh_ui(_dummy: int = 0) -> void:
	gold_label.text = "%d G" % GameManager.gold

	# ── 头盔 60G ─────────────────────────────────────────
	var h_has := EquipmentManager.has_equipment(EquipmentManager.Slot.HELMET)
	if h_has:
		lbl_helmet.text  = "✓ 已持有"
		btn_helmet.disabled = true
	elif GameManager.gold < 60:
		lbl_helmet.text  = "60 G  （金币不足）"
		btn_helmet.disabled = true
	else:
		lbl_helmet.text  = "60 G"
		btn_helmet.disabled = false

	if shop_role == ROLE_MERCHANT:
		lbl_suit.text = "需去工坊合成雪服"
		btn_suit.disabled = true
		lbl_board.text = "商人不升级雪板"
		btn_board.disabled = true
		lbl_goggles.text = "商人不升级雪镜"
		btn_goggles.disabled = true
		return

	# ── 高级雪服 100G + 雪服碎片 ─────────────────────────
	var s_has := EquipmentManager.has_equipment(EquipmentManager.Slot.SUIT)
	if s_has:
		lbl_suit.text  = "✓ 已合成"
		btn_suit.disabled = true
	elif not GameManager.has_suit_fragment:
		lbl_suit.text  = "100 G  （需击败Boss1获得碎片）"
		btn_suit.disabled = true
	elif GameManager.gold < 100:
		lbl_suit.text  = "100 G  （金币不足）"
		btn_suit.disabled = true
	else:
		lbl_suit.text  = "100 G  + 雪服碎片 ✓"
		btn_suit.disabled = false

	# ── 升级雪板 150G ─────────────────────────────────────
	var b_has := EquipmentManager.has_equipment(EquipmentManager.Slot.SNOWBOARD)
	if b_has:
		lbl_board.text  = "✓ 已升级"
		btn_board.disabled = true
	elif GameManager.gold < 150:
		lbl_board.text  = "150 G  （金币不足）"
		btn_board.disabled = true
	else:
		lbl_board.text  = "150 G"
		btn_board.disabled = false

	# ── 雪镜二级 80G + 升级零件 ──────────────────────────
	var g_lv: int = int(EquipmentManager.equipment_level[EquipmentManager.Slot.GOGGLES])
	if g_lv >= 2:
		lbl_goggles.text  = "✓ 已升级"
		btn_goggles.disabled = true
	elif g_lv < 1:
		lbl_goggles.text  = "80 G  （需先获得雪镜）"
		btn_goggles.disabled = true
	elif not GameManager.has_goggles_part:
		lbl_goggles.text  = "80 G  （需击败Boss2获得零件）"
		btn_goggles.disabled = true
	elif GameManager.gold < 80:
		lbl_goggles.text  = "80 G  （金币不足）"
		btn_goggles.disabled = true
	else:
		lbl_goggles.text  = "80 G  + 升级零件 ✓"
		btn_goggles.disabled = false

# ── 购买回调 ─────────────────────────────────────────────────
func _on_buy_helmet() -> void:
	if EquipmentManager.has_equipment(EquipmentManager.Slot.HELMET) or GameManager.gold < 60:
		return
	GameManager.add_gold(-60)
	var unlocked_level: int = int(EquipmentManager.unlocked_level.get(EquipmentManager.Slot.HELMET, 0))
	EquipmentManager.equip(EquipmentManager.Slot.HELMET, 1)
	# 首次购买时显示介绍
	if unlocked_level < 1:
		var notif: Dictionary = NotificationManager.get_equipment_description(EquipmentManager.Slot.HELMET, 1)
		NotificationManager.show_item_acquired(notif["name"], notif["desc"])
	_refresh_ui()

func _on_buy_suit() -> void:
	if not GameManager.has_suit_fragment or GameManager.gold < 100:
		return
	GameManager.add_gold(-100)
	GameManager.has_suit_fragment = false
	var unlocked_level: int = int(EquipmentManager.unlocked_level.get(EquipmentManager.Slot.SUIT, 0))
	EquipmentManager.equip(EquipmentManager.Slot.SUIT, 1)
	if unlocked_level < 1:
		var notif: Dictionary = NotificationManager.get_equipment_description(EquipmentManager.Slot.SUIT, 1)
		NotificationManager.show_item_acquired(notif["name"], notif["desc"])
	_refresh_ui()

func _on_buy_board() -> void:
	if EquipmentManager.has_equipment(EquipmentManager.Slot.SNOWBOARD) or GameManager.gold < 150:
		return
	GameManager.add_gold(-150)
	var unlocked_level: int = int(EquipmentManager.unlocked_level.get(EquipmentManager.Slot.SNOWBOARD, 0))
	EquipmentManager.equip(EquipmentManager.Slot.SNOWBOARD, 1)
	if unlocked_level < 1:
		var notif: Dictionary = NotificationManager.get_equipment_description(EquipmentManager.Slot.SNOWBOARD, 1)
		NotificationManager.show_item_acquired(notif["name"], notif["desc"])
	_refresh_ui()

func _on_buy_goggles() -> void:
	var g_lv: int = int(EquipmentManager.equipment_level[EquipmentManager.Slot.GOGGLES])
	if g_lv < 1 or not GameManager.has_goggles_part or GameManager.gold < 80:
		return
	GameManager.add_gold(-80)
	GameManager.has_goggles_part = false
	var unlocked_level: int = int(EquipmentManager.unlocked_level.get(EquipmentManager.Slot.GOGGLES, 0))
	EquipmentManager.upgrade(EquipmentManager.Slot.GOGGLES)
	if unlocked_level < 2:
		var notif: Dictionary = NotificationManager.get_equipment_description(EquipmentManager.Slot.GOGGLES, 2)
		NotificationManager.show_item_acquired(notif["name"], notif["desc"])
	_refresh_ui()

# ── 范围检测 ─────────────────────────────────────────────────
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_nearby = true
		prompt_label.visible = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_nearby = false
		prompt_label.visible = false
		_open = false
		shop_panel.visible = false
