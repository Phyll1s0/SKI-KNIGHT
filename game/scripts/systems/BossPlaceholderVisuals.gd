extends RefCounted

static func _new_image(size: Vector2i) -> Image:
	var image: Image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 0.0, 0.0, 0.0))
	return image

static func _fill_rect(image: Image, x0: int, y0: int, x1: int, y1: int, color: Color) -> void:
	var min_x: int = maxi(min(x0, x1), 0)
	var min_y: int = maxi(min(y0, y1), 0)
	var max_x: int = mini(max(x0, x1), image.get_width())
	var max_y: int = mini(max(y0, y1), image.get_height())
	for y in range(min_y, max_y):
		for x in range(min_x, max_x):
			image.set_pixel(x, y, color)

static func _to_texture(image: Image) -> Texture2D:
	return ImageTexture.create_from_image(image)

static func make_frozen_guard_body() -> Texture2D:
	var image: Image = _new_image(Vector2i(48, 64))
	_fill_rect(image, 12, 8, 36, 58, Color(0.69, 0.83, 0.97, 1.0))
	_fill_rect(image, 8, 18, 40, 48, Color(0.45, 0.60, 0.79, 1.0))
	_fill_rect(image, 16, 10, 32, 18, Color(0.88, 0.95, 1.0, 1.0))
	_fill_rect(image, 18, 24, 22, 28, Color(1.0, 1.0, 1.0, 1.0))
	_fill_rect(image, 26, 24, 30, 28, Color(1.0, 1.0, 1.0, 1.0))
	_fill_rect(image, 19, 25, 21, 27, Color(0.08, 0.12, 0.2, 1.0))
	_fill_rect(image, 27, 25, 29, 27, Color(0.08, 0.12, 0.2, 1.0))
	_fill_rect(image, 20, 34, 28, 38, Color(0.82, 0.90, 1.0, 1.0))
	_fill_rect(image, 10, 50, 18, 62, Color(0.33, 0.46, 0.64, 1.0))
	_fill_rect(image, 30, 50, 38, 62, Color(0.33, 0.46, 0.64, 1.0))
	return _to_texture(image)

static func make_frozen_guard_shield() -> Texture2D:
	var image: Image = _new_image(Vector2i(28, 44))
	_fill_rect(image, 4, 4, 24, 40, Color(0.76, 0.90, 1.0, 0.95))
	_fill_rect(image, 7, 8, 21, 36, Color(0.42, 0.61, 0.85, 0.95))
	_fill_rect(image, 10, 12, 18, 32, Color(0.90, 0.97, 1.0, 0.95))
	return _to_texture(image)

static func make_ice_lynx_body() -> Texture2D:
	var image: Image = _new_image(Vector2i(64, 40))
	_fill_rect(image, 10, 12, 48, 28, Color(0.85, 0.92, 0.98, 1.0))
	_fill_rect(image, 20, 8, 40, 18, Color(0.66, 0.78, 0.92, 1.0))
	_fill_rect(image, 46, 10, 58, 18, Color(0.72, 0.84, 0.96, 1.0))
	_fill_rect(image, 50, 8, 56, 12, Color(0.94, 0.97, 1.0, 1.0))
	_fill_rect(image, 14, 26, 20, 38, Color(0.55, 0.67, 0.83, 1.0))
	_fill_rect(image, 26, 26, 32, 38, Color(0.55, 0.67, 0.83, 1.0))
	_fill_rect(image, 36, 26, 42, 38, Color(0.55, 0.67, 0.83, 1.0))
	_fill_rect(image, 2, 18, 12, 22, Color(0.70, 0.82, 0.96, 1.0))
	_fill_rect(image, 4, 14, 10, 18, Color(0.56, 0.69, 0.86, 1.0))
	_fill_rect(image, 50, 12, 54, 16, Color(0.08, 0.12, 0.2, 1.0))
	return _to_texture(image)

static func make_snow_king_body() -> Texture2D:
	var image: Image = _new_image(Vector2i(64, 80))
	_fill_rect(image, 16, 8, 48, 70, Color(0.78, 0.90, 1.0, 1.0))
	_fill_rect(image, 10, 18, 54, 52, Color(0.48, 0.62, 0.84, 1.0))
	_fill_rect(image, 22, 6, 42, 16, Color(0.94, 0.97, 1.0, 1.0))
	_fill_rect(image, 18, 0, 24, 8, Color(0.86, 0.94, 1.0, 1.0))
	_fill_rect(image, 30, 0, 36, 8, Color(0.86, 0.94, 1.0, 1.0))
	_fill_rect(image, 22, 24, 28, 30, Color(1.0, 1.0, 1.0, 1.0))
	_fill_rect(image, 36, 24, 42, 30, Color(1.0, 1.0, 1.0, 1.0))
	_fill_rect(image, 24, 26, 27, 29, Color(0.08, 0.12, 0.2, 1.0))
	_fill_rect(image, 37, 26, 40, 29, Color(0.08, 0.12, 0.2, 1.0))
	_fill_rect(image, 24, 56, 30, 78, Color(0.36, 0.48, 0.68, 1.0))
	_fill_rect(image, 34, 56, 40, 78, Color(0.36, 0.48, 0.68, 1.0))
	return _to_texture(image)

static func make_ice_cat_body() -> Texture2D:
	var image: Image = _new_image(Vector2i(56, 32))
	_fill_rect(image, 10, 10, 38, 22, Color(0.76, 0.88, 1.0, 1.0))
	_fill_rect(image, 22, 6, 40, 16, Color(0.58, 0.72, 0.90, 1.0))
	_fill_rect(image, 38, 8, 48, 16, Color(0.82, 0.92, 1.0, 1.0))
	_fill_rect(image, 42, 4, 46, 8, Color(0.92, 0.96, 1.0, 1.0))
	_fill_rect(image, 8, 22, 12, 30, Color(0.42, 0.54, 0.72, 1.0))
	_fill_rect(image, 18, 22, 22, 30, Color(0.42, 0.54, 0.72, 1.0))
	_fill_rect(image, 30, 22, 34, 30, Color(0.42, 0.54, 0.72, 1.0))
	_fill_rect(image, 0, 14, 10, 18, Color(0.56, 0.70, 0.88, 1.0))
	_fill_rect(image, 40, 10, 43, 13, Color(0.08, 0.12, 0.2, 1.0))
	return _to_texture(image)

static func make_armored_ice_bear_body() -> Texture2D:
	var image: Image = _new_image(Vector2i(64, 64))
	_fill_rect(image, 14, 10, 50, 56, Color(0.75, 0.86, 0.97, 1.0))
	_fill_rect(image, 10, 18, 54, 42, Color(0.43, 0.56, 0.74, 1.0))
	_fill_rect(image, 18, 6, 42, 18, Color(0.90, 0.95, 1.0, 1.0))
	_fill_rect(image, 12, 20, 22, 38, Color(0.26, 0.34, 0.48, 1.0))
	_fill_rect(image, 42, 20, 52, 38, Color(0.26, 0.34, 0.48, 1.0))
	_fill_rect(image, 23, 24, 29, 30, Color(1.0, 1.0, 1.0, 1.0))
	_fill_rect(image, 35, 24, 41, 30, Color(1.0, 1.0, 1.0, 1.0))
	_fill_rect(image, 25, 26, 28, 29, Color(0.08, 0.12, 0.2, 1.0))
	_fill_rect(image, 37, 26, 40, 29, Color(0.08, 0.12, 0.2, 1.0))
	_fill_rect(image, 18, 48, 24, 62, Color(0.31, 0.41, 0.58, 1.0))
	_fill_rect(image, 40, 48, 46, 62, Color(0.31, 0.41, 0.58, 1.0))
	return _to_texture(image)

static func make_avalanche_giant_body() -> Texture2D:
	var image: Image = _new_image(Vector2i(80, 96))
	_fill_rect(image, 18, 10, 62, 86, Color(0.84, 0.92, 1.0, 1.0))
	_fill_rect(image, 8, 24, 72, 60, Color(0.57, 0.70, 0.88, 1.0))
	_fill_rect(image, 24, 4, 56, 18, Color(0.94, 0.97, 1.0, 1.0))
	_fill_rect(image, 14, 28, 28, 54, Color(0.30, 0.40, 0.55, 1.0))
	_fill_rect(image, 52, 28, 66, 54, Color(0.30, 0.40, 0.55, 1.0))
	_fill_rect(image, 28, 30, 36, 38, Color(1.0, 1.0, 1.0, 1.0))
	_fill_rect(image, 44, 30, 52, 38, Color(1.0, 1.0, 1.0, 1.0))
	_fill_rect(image, 31, 33, 35, 37, Color(0.08, 0.12, 0.2, 1.0))
	_fill_rect(image, 47, 33, 51, 37, Color(0.08, 0.12, 0.2, 1.0))
	_fill_rect(image, 28, 70, 38, 94, Color(0.38, 0.50, 0.68, 1.0))
	_fill_rect(image, 42, 70, 52, 94, Color(0.38, 0.50, 0.68, 1.0))
	return _to_texture(image)