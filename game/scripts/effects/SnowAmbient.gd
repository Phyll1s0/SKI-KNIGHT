extends GPUParticles2D

const TOP_MARGIN: float = 56.0
const SIDE_PADDING: float = 96.0
const BOX_HEIGHT: float = 32.0
const MIN_VIEWPORT_WIDTH := "display/window/size/viewport_width"
const MIN_VIEWPORT_HEIGHT := "display/window/size/viewport_height"

var _material_ref: ParticleProcessMaterial = null

func _ready() -> void:
	_material_ref = process_material as ParticleProcessMaterial
	var viewport: Viewport = get_viewport()
	if viewport != null:
		viewport.size_changed.connect(_refresh_layout)
	_refresh_layout()

func _refresh_layout() -> void:
	var viewport_rect: Rect2 = get_viewport_rect()
	var size: Vector2 = viewport_rect.size
	var min_width: float = float(ProjectSettings.get_setting(MIN_VIEWPORT_WIDTH, 1280))
	var min_height: float = float(ProjectSettings.get_setting(MIN_VIEWPORT_HEIGHT, 720))
	size.x = maxf(size.x, min_width)
	size.y = maxf(size.y, min_height)
	position = Vector2(size.x * 0.5, -TOP_MARGIN)
	visibility_rect = Rect2(
		-size.x * 0.5 - SIDE_PADDING,
		-TOP_MARGIN - 80.0,
		size.x + SIDE_PADDING * 2.0,
		size.y + TOP_MARGIN + 220.0
	)
	amount = maxi(int(size.x / 4.0), 260)
	if _material_ref != null:
		_material_ref.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
		_material_ref.emission_box_extents = Vector3(size.x * 0.5 + SIDE_PADDING, BOX_HEIGHT, 1.0)
