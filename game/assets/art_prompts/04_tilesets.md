# 地形瓦片集生成指南
# 包含 5 套地图的完整 tileset，每套覆盖所有必要 tile 类型
# 所有 Tileset：16×16px per tile，PNG，无透明背景（完全填充）

---

## Tileset 通用规则

- **每块**：16×16px，完全填充（无透明），相邻 tile 颜色自然过渡
- **排列**：单行横向排列，每套 tileset 约 8~12 种 tile 组成一行
- **样式**：无抗锯齿，1px 轮廓，像素硬边
- **光源**：统一左上角 45° 光源（所有套统一）
- **Godot 接入**：每套 .png 导入后在 TileSet 编辑器中设置物理层、斜坡法线等

---

## Tile 类型字典（所有套共用类型名）

| 类型         | 编号 | 碰撞            | 描述                              |
|-------------|------|----------------|-----------------------------------|
| ground_top  | 0    | 上表面          | 主要地面，玩家站立的标准地块       |
| ground_fill | 1    | 全体            | 地面内部填充（无上表面高光）       |
| slope_l     | 2    | 斜面↗           | 左斜坡（从左低到右高，↗方向）      |
| slope_r     | 3    | 斜面↘           | 右斜坡（从左高到右低，↘方向）      |
| platform    | 4    | 仅上边缘（8px） | 可跳穿的薄板平台                   |
| wall_l      | 5    | 全体            | 左侧实心墙面（内侧朝右）           |
| wall_r      | 6    | 全体            | 右侧实心墙面（内侧朝左）           |
| ceiling     | 7    | 下表面          | 天花板/悬空地板底面                |
| ice_patch   | 8    | 无（叠加层）    | 冰滑覆盖层，叠在 ground_top 上    |
| bg_detail_a | 9    | 无              | 装饰背景瓦块 A（悬挂物/积雪）      |
| bg_detail_b | 10   | 无              | 装饰背景瓦块 B（不同方向积雪）     |
| corner_tl   | 11   | 局部            | 左上内角过渡                       |

---

# ═══════════════════════════════════════════════════════════
# Tileset 1 — 雪山入口（TestMap / TestMap）
# ═══════════════════════════════════════════════════════════
# 文件：game/assets/tilemaps/snow_entrance_tileset.png
# 情感：清晨雪山，明亮轻快，冒险开始的新鲜感
# 主色调：#D8EAF5（白雪蓝影），明亮白，蓝灰阴影

## 色板

| 用途         | 颜色     |
|-------------|---------- |
| 雪面主色     | #D8EAF5  |
| 雪面阴影     | #8AAED0  |
| 土/石基础    | #4E7CA1  |
| 深基础阴影   | #1A2E42  |
| 雪白高光     | #FFFFFF  |
| 轮廓线       | #2A2A33  |

## 完整 AI Prompt（12 tiles 单行）

```
pixel art tileset sprite sheet, 16x16px per tile, 12 tiles in a single horizontal row,
no transparent background (all tiles fully filled), no antialiasing,
cold winter mountain entrance tileset, bright morning snow palette,

tile 0 (ground_top): snow-covered ground tile, white snow surface on top 4px (#D8EAF5 with #FFFFFF sparkle),
mid section solid ice-blue stone (#4E7CA1), 1px dark outline top edge,
light from top-left, snow curve gentle on top,

tile 1 (ground_fill): solid stone block interior, #4E7CA1 main with diagonal shadow lines,
no snow cap, purely structural dark fill tile,

tile 2 (slope_l): 45-degree slope rising right to left, snow on angled surface,
snow follows the diagonal, stone body below,

tile 3 (slope_r): 45-degree slope falling right to left, snow on angled surface mirror of tile 2,

tile 4 (platform): thin floating platform 4px thick, snow on top 2px (#FFFFFF),
wood or stone plank body (#4E7CA1), underside dark (#1A2E42),

tile 5 (wall_l): vertical wall face looking right, rough stone texture with horizontal crack lines,
left edge shadowed, right edge lighter,

tile 6 (wall_r): vertical wall face looking left, mirror of tile 5,

tile 7 (ceiling): underside of ground block, shadowed (#1A2E42 dominant), rough stone texture,
icicle tips optional 1-2px hanging down,

tile 8 (ice_patch): semi-transparent blue overlay tile, #B8D8FF with 60% fill,
diagonal hash pattern showing ice shininess, corner rounded to show it's a natural patch,

tile 9 (bg_detail_a): decorative background snow mound/drift, no collision,
soft snow pile shape against darker backdrop, purely visual,

tile 10 (bg_detail_b): small icicle formation hanging, 2-3 icicles of varying height,
#B8D8FF icicle with #FFFFFF tip,

tile 11 (corner_tl): concave inner corner tile, snow curling at junction of ground and wall,

pixel art, sharp pixel edges, Cave Story tileset style, snowy mountain ledge platformer aesthetic
```

---

# ═══════════════════════════════════════════════════════════
# Tileset 2 — 冰川迷宫（GlacierMaze）
# ═══════════════════════════════════════════════════════════
# 文件：game/assets/tilemaps/glacier_maze_tileset.png
# 情感：神秘幽蓝，冰透感，危险但美丽的迷宫
# 主色调：#6EC4D8（蓝绿冰面），透明质感

## 色板

| 用途         | 颜色     |
|-------------|---------- |
| 冰面高光     | #9EE0F0  |
| 冰面主色     | #6EC4D8  |
| 冰面中阴影   | #4E7CA1  |
| 冰面深影     | #1A2E42  |
| 透明感高光   | #FFFFFF（1~2px）|
| 轮廓线       | #2A2A33  |

## 完整 AI Prompt

```
pixel art tileset sprite sheet, 16x16px per tile, 12 tiles horizontal row,
no transparent background, no antialiasing,
glacial ice maze tileset, deep blue-green translucent ice aesthetic,
magical underground glacier feel, cool teal-blue palette,

tile 0 (ground_top): thick ice plate top surface, #9EE0F0 top with #FFFFFF 1px sheen line,
mid ice body #6EC4D8, base #4E7CA1, visible bubble/air pocket 2px circle inside ice body (cosmetic),

tile 1 (ground_fill): solid ice block, internal refraction effect: diagonal lighter stripe 1px inside,
ice is not uniform - has slight internal optical texture,

tile 2 (slope_l): ice ramp slope left-rising-right, smooth ice incline surface,
glassy surface with single highlight line along slope top, no snow (too cold),

tile 3 (slope_r): mirrored slope_l,

tile 4 (platform): thin ice shelf, slightly darker than wall ice to show it's load-bearing,
clear drip icicle 2px on underside corner, glassy sheen on top surface,

tile 5 (wall_l): glacial wall face, vertical ice wall with visible internal freeze layers,
1-2 horizontal band lines (natural ice strata), cold blue tones,

tile 6 (wall_r): mirror of wall_l,

tile 7 (ceiling): ceiling ice, icicle tips 1-3px hanging in variety of lengths,
icicle color #9EE0F0 tip, #6EC4D8 body,

tile 8 (ice_patch): extra-slippery ice patch, bright glossy overlay,
#FFFFFF diagonal line pattern suggesting extra smoothness, brighter than regular ice,

tile 9 (bg_detail_a): background ice crystal formation, 4-corner spike cluster,
purely decorative frozen crystal growing from wall, deep blue variant,

tile 10 (bg_detail_b): air bubble column frozen in ice, 3 stacked circles in ice interior,

tile 11 (corner_tl): smooth concave ice corner, naturally curved junction, no rough edges,

pixel art, Cave Story ice world, slippery hazard aesthetic, crystalline blue-green tones
```

---

# ═══════════════════════════════════════════════════════════
# Tileset 3 — 暴风雪高地（BlizzardHighlands）
# ═══════════════════════════════════════════════════════════
# 文件：game/assets/tilemaps/blizzard_tileset.png
# 情感：灰白暴风，能见度低，压迫感强，危机四伏
# 主色调：#B0BEC5（暴风灰），白色积雪堆叠

## 色板

| 用途         | 颜色     |
|-------------|---------- |
| 雪面灰白     | #D0DCE4  |
| 石面暴风灰   | #B0BEC5  |
| 岩石深灰     | #6A7A88  |
| 岩石暗影     | #2A3A48  |
| 雪峰白       | #FFFFFF  |
| 轮廓线       | #2A2A33  |

## 完整 AI Prompt

```
pixel art tileset sprite sheet, 16x16px per tile, 12 tiles horizontal row,
no transparent background, no antialiasing,
blizzard highlands tileset, storm-battered rocky mountain terrain,
grey-white palette, heavy snow accumulation on all horizontal surfaces,
low visibility windy mountain pass atmosphere,

tile 0 (ground_top): weathered stone top with wind-blown snow 3px piled (#FFFFFF/#D0DCE4),
stone surface rough and grey-brown (#B0BEC5), heavy texture,
windswept effect: snow skewed slightly right 1-2px as if blown,

tile 1 (ground_fill): dense grey stone fill, rough quarry-texture cross lines,
cold and hard stone in grey-blue tones, no frills,

tile 2 (slope_l): rocky slope with snow collected in crevices,

tile 3 (slope_r): mirrored slope,

tile 4 (platform): storm-worn wooden platform plank or stone shelf,
boards (if wood): horizontal gray planks with nail dots, snow on top,
extra snow buildup at plank edges, clearly hazardous,

tile 5 (wall_l): exposed cliff face, rough and craggy, diagonal crack lines,
howling wind effect implied by slight diagonal texture lines in stone,

tile 6 (wall_r): mirrored wall,

tile 7 (ceiling): underside of overhanging rock, grey and rough,
no icicles (too windy), flat rough stone,

tile 8 (ice_patch): wind-packed ice sheet, more opaque than glacier version,
grey-tinted ice, #B0BEC5 tinted, still slightly shiny,

tile 9 (bg_detail_a): snow drift pile decorative, windswept shape curved right,

tile 10 (bg_detail_b): exposed rock protrusion from snow, darker stone visible,

tile 11 (corner_tl): rough rocky inner corner, uneven and natural,

pixel art, grim mountain atmosphere, Cave Story challenging zone aesthetic, grey storm palette
```

---

# ═══════════════════════════════════════════════════════════
# Tileset 4 — 地下冰窟（IceCave）
# ═══════════════════════════════════════════════════════════
# 文件：game/assets/tilemaps/ice_cave_tileset.png
# 情感：深邃黑暗，冰晶发光，神秘危险的地下世界
# 主色调：#1A2050（洞窟深蓝），#4060FF（冰晶发光）

## 色板

| 用途         | 颜色     |
|-------------|---------- |
| 洞窟主色     | #1A2050  |
| 洞窟次色     | #2A3268  |
| 发光蓝       | #4060FF  |
| 发光高光     | #6080FF  |
| 晶洞白光     | #B8D8FF  |
| 轮廓线       | #2A2A33  |

## 完整 AI Prompt

```
pixel art tileset sprite sheet, 16x16px per tile, 12 tiles horizontal row,
no transparent background, no antialiasing,
underground ice cave tileset, dark cavern with bioluminescent ice crystals,
deep dark blue-purple palette with glowing ice accents,
ancient mysterious underground atmosphere,

tile 0 (ground_top): dark cave floor, flat frozen surface, deep blue-black (#1A2050),
faint #4060FF glow streak 1px on top surface suggesting ice glow,
small crystal node 2px grown from surface right edge,

tile 1 (ground_fill): solid dark cave rock, near-black with subtle purple-blue undertone,
minimal texture, very dark and heavy,

tile 2 (slope_l): dark cave slope, occasional glowing crystal growth on slope face,

tile 3 (slope_r): mirrored slope,

tile 4 (platform): dark cave ledge with ice crystal growth underneath,
2-3 small ice crystals 3px hanging from ledge underside, emitting 1px glow,

tile 5 (wall_l): cave wall with embedded ice crystal vein,
large crystal cluster visible inside wall, #4060FF glowing (3×4px cluster),
dark wall surrounds it,

tile 6 (wall_r): mirrored wall with different crystal placement,

tile 7 (ceiling): cave ceiling, stalactite icicles 3-5px hanging,
glowing tips #6080FF on stalactite ends,

tile 8 (ice_patch): glowing ice floor patch, strongly lit from within,
#4060FF pulsing center with #B8D8FF surrounding, obviously magical,

tile 9 (bg_detail_a): background crystal cluster, large 5-6px crystal formation,
multi-point transparent ice with inner glow, purely decorative,

tile 10 (bg_detail_b): cave fungus / ice moss clump (decorative only),
pale blue-white color, soft irregular pixel shape,

tile 11 (corner_tl): cave corner with crystal vein running through the junction,

pixel art, dark dungeon atmosphere, mysterious cave world, glowing crystal accents,
Cave Story hidden area aesthetic, deep cold underground
```

---

# ═══════════════════════════════════════════════════════════
# Tileset 5 — 雪山顶峰（SnowyPeak）
# ═══════════════════════════════════════════════════════════
# 文件：game/assets/tilemaps/snowy_peak_tileset.png
# 情感：白银极寒，史诗高空，纯洁与终极考验
# 主色调：#E8F0FF（白银），#2A3A5A（高对比深影）

## 色板

| 用途         | 颜色     |
|-------------|---------- |
| 极雪白       | #F0F6FF  |
| 雪面冷白     | #E8F0FF  |
| 岩石蓝灰     | #4E6A8A  |
| 岩石深影     | #2A3A5A  |
| 极光/天光    | #B8D8FF  |
| 轮廓线       | #2A2A33  |

## 完整 AI Prompt

```
pixel art tileset sprite sheet, 16x16px per tile, 12 tiles horizontal row,
no transparent background, no antialiasing,
snowy mountain peak tileset, extreme altitude final zone,
high contrast white silver snow against dark shadow rock,
epic clean final area palette, pure and deadly cold atmosphere,

tile 0 (ground_top): pristine deep snow covering, #F0F6FF top with #FFFFFF sparkle 1px,
sharp contrast where snow meets dark rock below (#2A3A5A),
strong light from above (at peak, sky is bigger), bright top surface,

tile 1 (ground_fill): blue-grey solid mountain rock, dense and ancient feeling,
subtle horizontal layering lines (ancient stone compression), very dark,

tile 2 (slope_l): dramatic ski slope with perfect powder snow,
smooth clean surface, single highlight line along slope top,

tile 3 (slope_r): mirrored perfect powder ski slope,

tile 4 (platform): narrow mountain ledge, minimal snow on top (wind blown most off),
dark rock exposed, small snow clump at right edge only,

tile 5 (wall_l): sheer cliff face, smooth exposure suggesting wind erosion,
white frost streaks running vertically down cliff face,

tile 6 (wall_r): mirrored cliff,

tile 7 (ceiling): underside of overhanging snow cornice, large icicle 4-5px,
snow cornice edge visible: overhanging snow blob shape with icicle tip,

tile 8 (ice_patch): glassy summit ice, ultra-hard compressed glacial ice,
high sheen: two bright white diagonal lines on #4E6A8A surface suggesting extreme hardness,

tile 9 (bg_detail_a): summit snow drift carved by wind, crescent moon shape,
aerodynamic wind-sculpted snow, horizontal flowing direction,

tile 10 (bg_detail_b): exposed mountain rock formation, dramatic sharp edge rock spire 2px wide,

tile 11 (corner_tl): clean sharp corner where cliff meets snow ledge,

pixel art, dramatic high altitude finale, Cave Story final zone, pristine extreme cold
```

---

## 生成建议

1. 每套 tileset 先生成包含所有 12 tile 的单行图，然后逐一检查
2. 关键检查点：`ground_top`（站立地面）与 `slope_l/r`（斜坡）必须在视觉上明显区分
3. `ice_patch`（冰滑区）需与 `ground_top` 有清晰视觉差异，让玩家能预判滑行
4. 导入 Godot 后，记得为 `slope_l` 和 `slope_r` 设置正确的 PhysicsLayer 和 slope normal
5. `bg_detail` 类型的瓦块导入后需在 TileSet 中标记为"无碰撞"
