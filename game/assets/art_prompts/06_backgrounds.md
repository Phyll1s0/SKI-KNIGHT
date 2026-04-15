# 背景层（视差滚动）生成指南
# 每张地图 2~3 层视差背景，宽度跟随地图，高度统一 720px
# 渲染在 CanvasLayer(layer=-1)，通过 ParallaxBackground 实现自动偏移

---

## 背景层通用规则

- **格式**：PNG-32，含 Alpha（天空部分透明或为纯色背景）
- **尺寸**：宽度 = 地图总宽 ÷ 视差因子（layer-2 约 600px，layer-1 约 1200px），高度 720px
- **排列**：可横向无缝拼接（左右两端颜色/内容可吻合），ParallaxBackground 设置 motion_mirroring
- **风格**：比前景更模糊/更简化，主要靠色块和剪影区分层次；NOT pixel detail，而是像素色块
- **提示**：生成时可先生成 1200×720px，然后水平缩放到所需宽度

---

# ═══════════════════════════════════════════════════════════
# 地图 1 — TestMap（雪山入口）背景层
# ═══════════════════════════════════════════════════════════
# 情感：清晨第一缕阳光照在雪山，温暖的期待感，冒险出发点

## Layer -2（远景山脉，视差比例极慢 0.1x）

**画布尺寸**：600×720px（将被 ParallaxBackground 平铺）

**完整 AI Prompt**：
```
pixel art background layer, 600x720px, horizontal seamless tileable,
mountain range silhouette far background, cold dawn palette,
sky gradient: top #0A1A2E dark pre-dawn blue → mid #2A4A6E dawn blue → bottom #6A8AAE morning haze,
3-4 mountain peaks silhouette in deep blue-grey #1A2E42 in middle distance,
peaks have pure white snow caps #E8F0FF with #B8D8FF transition,
gentle morning glow from upper-right: slight #E8D0A0 warm tint on rightmost peak tops,
clouds: 3-4 wispy horizontal cloud streaks in #D0DCE4 mid-sky,
NO detailed texture - this is far background, blobs and silhouettes only,
seamlessly tileable left-right, no hard edges at sides,
pixel art simplified background, 2D platformer far parallax layer
```

---

## Layer -1（中景树林/雪丘，视差比例 0.4x）

**画布尺寸**：1200×720px

**完整 AI Prompt**：
```
pixel art background layer, 1200x720px, horizontal seamless tileable,
winter forest and snow dunes middle-ground,
lower 300px: snow dune hills, white #D8EAF5 with blue shadow curves #8AAED0,
snow dunes gently rolling, 2-3 overlapping curves suggesting depth,
scattered pine/conifer trees silhouettes: 8-10 trees total across width,
tree silhouette: dark blue-green #1A2E42, simplified triangle shape,
some trees have snow on branches: #FFFFFF pixel blobs on upper branches,
upper 420px: gradient sky continuing from far layer, slightly lighter/warmer than far BG,
no outlines on background elements - pure color silhouettes,
parallax middle layer, slightly more detail than far layer but still simplified,
2D platformer mid parallax, winter forest silhouette, seamless horizontal tile
```

---

# ═══════════════════════════════════════════════════════════
# 地图 2 — GlacierMaze（冰川迷宫）背景层
# ═══════════════════════════════════════════════════════════
# 情感：幽蓝神秘，冰道迷宫，有什么古老的东西沉睡在冰下

## Layer -2（远景冰川，视差 0.1x）

**完整 AI Prompt**：
```
pixel art background layer, 600x720px, horizontal seamless tileable,
deep glacier interior far background, mysterious ice cave atmosphere,
deep blue-teal color gradient: top #0A0A20 near-black → mid #1A2A50 → bottom #1A3A5A,
frozen underground atmosphere, no sky visible,
3-4 massive ice column silhouettes in far distance: #1A3060 slightly lighter than background,
columns are wide at base, narrowing upward, glacial pillar shapes,
faint bioluminescent glow: scattered 1px light points in #4060FF across background
(10-15 scattered pixels suggesting distant crystal glow),
large ancient ice shelf suggested by horizontal band #1A3860 in upper third,
ominous beauty, vast underground ice world,
pixel art background, dark cave parallax layer, seamless tile
```

---

## Layer -1（近景冰柱群，视差 0.4x）

**完整 AI Prompt**：
```
pixel art background layer, 1200x720px, horizontal seamless tileable,
ice stalactite and stalagmite formations middle-ground,
lower 200px: stalagmites rising from bottom, 5-7 irregular spires,
spire color: #2A4A6E with #4E7CA1 facing-light edge,
tips: #B8D8FF sharp point with 1px #FFFFFF glint,
upper 200px: stalactites hanging from implied ceiling, 4-6 hanging icicle shapes,
same color scheme, pointing downward,
background fill: dark teal-black #0A1A30,
scattered glow points: 5-6 ice crystals in background gently glowing #4060FF (4px blob each),
no hard outlines - pure silhouette shapes,
pixel art mid parallax layer, ice cave columns, glowing crystal accents, seamless tile
```

---

# ═══════════════════════════════════════════════════════════
# 地图 3 — BlizzardHighlands（暴风雪高地）背景层
# ═══════════════════════════════════════════════════════════
# 情感：白茫茫一片，能见度极低，感觉随时有危险

## Layer -2（暴风雪模糊远山，视差 0.1x）

**完整 AI Prompt**：
```
pixel art background layer, 600x720px, horizontal seamless tileable,
blizzard storm background, near-whiteout visibility,
entire image dominated by grey-white blizzard fog,
color: near-uniform #B8C8D0 with subtle lighter #D0DCE4 horizontal streaks,
streaks suggest horizontal blowing snow and wind direction (left to right motion),
barely visible mountain silhouette in deep background: #8A9AB0 faint mass in center,
mountain almost invisible through storm, only slightly darker than surrounding fog,
upper sky: almost same grey-white, no clear sky-ground distinction,
oppressive and dangerous atmosphere, visibility nightmare,
pixel art background, whiteout storm, barely-visible far parallax, seamless tile
```

---

## Layer -1（雪雾颗粒层，视差 0.4x）

**完整 AI Prompt**：
```
pixel art background layer, 1200x720px, horizontal seamless tileable,
blizzard near-background snow particle and rock silhouette layer,
lower 300px: dark grey rocky outcrops silhouette #4A5A6A, jagged profiles,
snow accumulated on rocky tops: irregular white #D0DCE4 caps,
mid section: semi-transparent snow columns, 3-4 vertical dense snow streams
as diagonal streaks of dots/pixels (blowing direction 15 degrees from vertical),
snow streak color: #FFFFFF with varying opacity (simulated by pixel density),
scattered clusters of large snow pixels: 3-4px and 2-2px white blobs randomly placed,
feeling of thick snow flying past camera plane,
horizontal motion blur implied by pixel streaks,
pixel art mid parallax, blizzard particle layer, storm atmosphere, seamless tile
```

---

# ═══════════════════════════════════════════════════════════
# 地图 4 — IceCave（地下冰窟）背景层
# ═══════════════════════════════════════════════════════════
# 情感：最幽暗深邃的关卡，古老冰封遗迹，充满未知

## Layer -2（洞窟深邃黑暗，视差 0.1x）

**完整 AI Prompt**：
```
pixel art background layer, 600x720px, horizontal seamless tileable,
deep underground ice cavern far background, almost completely dark,
base color: #050510 near-black dark blue-black,
very faint cavern wall texture: subtle 1px irregular crack lines in #0A0A28,
glow sources: 6-8 scattered crystal clusters, each 2-3px blob in #4060FF,
creating small pools of dim blue light in the darkness,
the crystals are the only light source in this void,
one larger glow cluster 8px wide center-right (landmark crystal formation),
stalactite hints: 2-3 very dark shapes hanging from top #0A0A20 barely visible,
vast oppressive underground emptiness, far pixel art cave background, seamless tile
```

---

## Layer -1（冰晶发光近景，视差 0.4x）

**完整 AI Prompt**：
```
pixel art background layer, 1200x720px, horizontal seamless tileable,
ice cave mid-ground with prominent glowing crystal formations,
dark base #0A1428, slightly lighter than far background to create depth,
lower third: 4-5 large crystal spires growing from bottom edge,
crystals: #2A4888 body with #4060FF inner glow line and #6080FF tip,
each crystal 12-20px tall, varied heights and widths,
crystal glow halo: 2px faint #4060FF gradient around each crystal edge (softly implied),
upper portion: two stalactite crystal formations hanging from ceiling zone,
smaller crystals 6-8px, same color scheme,
wall-attached crystal vein: diagonal line of 4 crystal nodes connecting mid-left to upper-right,
mysterious, beautiful, dangerous atmosphere,
pixel art mid parallax, glowing cave crystals, bioluminescent ice aesthetic, seamless tile
```

---

## Layer 0（雾气装饰层，视差 0.7x，叠加效果）

**用途**：可选的前景雾气叠加，TileMapLayer z_index=1（画在地形前方，玩家后方）

**完整 AI Prompt**：
```
pixel art atmosphere overlay, 1200x400px, semi-transparent background (60% transparent base),
cold cave mist layer, wispy fog at ground level,
10-15 horizontal irregular fog wisps in near-white #D8E8FF with high transparency,
wisps are 3-8px tall, 40-80px long, irregular edges, horizontal motion implied,
randomly distributed across lower 400px of canvas,
this layer will be placed at ground level in the cave to add atmosphere depth,
pixel art, atmospheric mist, cave fog decoration, semi-transparent
```

---

# ═══════════════════════════════════════════════════════════
# 地图 5 — SnowyPeak（雪山顶峰）背景层
# ═══════════════════════════════════════════════════════════
# 情感：极高处的孤独与壮阔，史诗感，最终决战前的寂静

## Layer -2（极光天空，视差 0.08x）

**完整 AI Prompt**：
```
pixel art background layer, 600x720px, horizontal seamless tileable,
extreme altitude mountain peak sky background, aurora borealis or star sky,
upper 400px: deep midnight blue-purple sky #0A0818,
star field: 20-25 single pixel #FFFFFF white dots scattered across sky, varied brightness
(some 2x2px slightly brighter, rest 1px),
aurora bands: 2-3 diagonal flowing bands #2A6A40 and #4A8A60 (green aurora) or
#3A2A6A #5A4A8A (purple aurora variant) - pick one,
aurora bands are 4-8px wide, gently curved horizontal orientation,
lower 320px: distant mountain range silhouette in deep navy #0A1428,
mountain peaks sharp and proud against the aurora sky,
pure white snow caps #E8F0FF glinting on peak tops,
epic lonely summit sky, pixel art far background, aurora night, seamless tile
```

---

## Layer -1（裸岩峭壁剪影，视差 0.35x）

**完整 AI Prompt**：
```
pixel art background layer, 1200x720px, horizontal seamless tileable,
dramatic rocky cliff silhouettes near-background, extreme altitude terrain,
lower 400px: massive rock cliff formations, sheer vertical faces,
cliff color: #1A2E42 dark blue-grey, facing surfaces #2A4A6A slightly lighter,
cliff edges sharp and geometric, not organic - ancient compressed stone,
snow streaks: 2-3 horizontal white #FFFFFF snow streaks across cliff faces
(windblown snow clinging to crevices),
rock surface: subtle horizontal compression layering lines 1px in slightly lighter tone,
upper portion transitions to sky from far layer,
scattered loose rock debris pixels at cliff bases: 3-4px angular fragments,
sense of immense scale and height, isolated and extreme,
pixel art mid parallax, cliff silhouette, epic summit terrain, seamless tile
```

---

## Layer でも-1.5（积雪平台中景，视差 0.5x，可选第三层）

**完整 AI Prompt**：
```
pixel art background layer, 1200x720px, horizontal seamless tileable,
mid-distance snow covered mountain ledges and cornices,
irregular horizontal plateau shapes filled with deep snow,
snow color: #E8F0FF top surface, blue shadow #8AAED0 on sides facing away from light,
3-4 overhanging snow cornice shapes: snow bulging out over edge, dramatic drooping,
between ledges: gaps showing sky/depth below,
small detail: one ledge has a partially buried ancient stone marker/ruin
(dark stone shape #1A2E42 half-covered by snow drift),
windswept and isolated, snow is compressed and solid at this altitude,
pixel art near-mid parallax, snowy mountain shelf, epic altitude scenery, seamless tile
```

---

## UI 背景：MainMenu.tscn 背景图

**文件**：`game/assets/ui/main_menu_bg.png`，**尺寸**：1280×720px（固定）

**完整 AI Prompt**：
```
pixel art game title screen background, 1280x720px, fixed size (NOT seamless),
dramatic snowy mountain landscape for game main menu,
composition: mountain peak center-right rising from bottom, snow storm at lower third,
sky: midnight blue-black with aurora borealis bands (blue-green #4A8A60 bands,
and deep purple highlights) filling upper 60%,
stars scattered across sky (30+ single pixels),
mountain: white silver peak #E8F0FF center, casting long shadow left,
foreground silhouette: dark ski slope and pine trees #0A1428 at very bottom,
atmospheric depth: 3-4 layers of mountain silhouettes getting lighter with distance,
mood: epic, lonely, cold beauty, inviting danger,
no text or UI elements (text will be overlaid by Godot),
pixel art, detailed game title background, wide 16:9 landscape, winter night epic scene
```

---

## 生成建议

1. 先生成**远景层**确认整体色调，再生成近景层确保层次感正确
2. **无缝拼接**测试：将生成图首尾拼接检查是否有明显接缝，若有则在 AI 中用 "seamless tile, both sides matching" 重新生成
3. **ParallaxBackground 设置**：在 Godot 中为每层设置 `scroll_scale`（far=0.1, mid=0.4, near=0.7）
4. **IceCave 雾气层**：导入后在材质设置中开启 Blend Mode = Add，并设置 Alpha 值约 0.4
5. **背景层不需要严格像素精度**：可以用普通 AI 图像生成工具（DALL-E/Midjourney）生成，给 Godot 后设置 Filter=Linear（不是 Nearest），视觉效果更柔和
