# Phase 2 — 第二幕所需美术生成指南
# 包含：雪人兵重新生成 + 炮台 + 冰球弹丸
# 生成顺序：先雪人兵 → 炮台 → 冰球
#
# ══════════════════════════════════════════════════════
# 图片放置说明（生成完直接放这里，不需要在 Godot 里做任何设置）
# ══════════════════════════════════════════════════════
#
#   game/assets/sprites/enemies/snowman_sheet.png   ← 覆盖旧文件  128×48px  4帧
#   game/assets/sprites/enemies/turret_sheet.png    ← 新建        128×32px  4帧
#   game/assets/sprites/enemies/iceball_sheet.png   ← 新建         16×16px  1帧
#
# 脚本和场景文件已全部配置好，图片扔进去即生效，不用在编辑器里操作。

---

# ══════════════════════════════════════════════════════
# 资源 1：雪人兵 重新生成（覆盖旧文件）
# ══════════════════════════════════════════════════════
# 文件：game/assets/sprites/enemies/snowman_sheet.png
# 放入路径：直接覆盖现有的 snowman_sheet.png
#
# 尺寸：128×48px（4帧 × 32×48px，横向排列）
#
# ⚠️ 重要：脚本 SnowmanSoldier.gd 使用帧索引：
#   frame 0 = walk（巡逻行走）
#   frame 1 = attack（攻击挥棒）
#   frame 2 = hurt（受击反应）
#   frame 3 = dead（死亡融化）
#
# 必须按此顺序，4 个姿势各 1 帧，不能全是走路帧

## 完整 AI Prompt（直接复制）

```
pixel art enemy sprite sheet, 32x48px per frame, 4 frames horizontal strip,
transparent background, no antialiasing, hard pixel edges, 2D platformer side view,
snowman soldier enemy, round white snow body two segments (large bottom, small top),
dark blue military cap with brim, orange carrot nose, black button eyes,
holding ice club weapon in right twig arm,
palette: #E8F0FF #8AAED0 #1A2E42 #FF7030 #2A2A33,

frame 0 (WALK - left foot forward): walking patrol pose facing right,
body weight on right foot, left foot stepped forward,
slight rightward body tilt 5 degrees, weapon held casually at side,

frame 1 (ATTACK - club fully swung): melee attack pose facing right,
ice club arm fully extended forward at waist level, impact position,
body leaning forward 15 degrees committed to swing,
3px white impact star pixels in front of club tip,

frame 2 (HURT - knocked back): taking damage reaction facing right,
body pushed back 4px, arms thrown rearward,
carrot nose tilted from impact, cap askew 10 degrees,
3 red damage pixels #E84040 near center body,
brief pained expression suggested by eye pixels shifting,

frame 3 (DEAD - melted pile): death state,
collapsed into small snow mound on ground level (bottom 20px only),
cap lying flat beside mound, weapon half-sunk in snow,
2px water puddle on each side of mound,
all snowman volume reduced to a simple rounded pile,
upper snow ball gone completely,

pixel art, Cave Story enemy style, #2A2A33 outline, 4 distinct states clearly readable
```

---

# ══════════════════════════════════════════════════════
# 资源 2：冰球炮台（IceTurret）
# ══════════════════════════════════════════════════════
# 文件：game/assets/sprites/enemies/turret_sheet.png
# 放入路径：game/assets/sprites/enemies/turret_sheet.png（新文件）
#
# 尺寸：128×32px（4帧 × 32×32px，横向排列）
#
# 脚本帧索引（IceTurret.gd）：
#   frame 0 = idle    （待机，炮口低亮度）
#   frame 1 = charge  （充能，炮口高亮，玩家可见即将开火）
#   frame 2 = fire    （开火，炮口爆闪，子弹生成）
#   frame 3 = dead    （死亡，炮管碎裂）
#
# 炮台整体外观：
#   下层：厚重锚固底座（#1A2E42），有锚钉螺栓感
#   中层：六角形冰蓝主机箱（#4E7CA1），表面有冰层纹
#   上层：圆柱形炮管朝右伸出，炮口内有发光

## 完整 AI Prompt（直接复制）

```
pixel art game enemy sprite sheet, 32x32px per frame, 4 frames horizontal strip,
transparent background, no antialiasing, hard pixel edges,
ice cannon turret, frozen mechanical weapon, facing right, stationary object,

COMMON STRUCTURE (all 4 frames share this base shape):
bottom 8px: thick anchor base plate #1A2E42, 2px anchor bolt heads on left and right,
mid 14px: chunky hexagonal machine body #4E7CA1, 2 thin horizontal ice-strata crack lines,
top-left highlight 1px #9EE0F0, right face shadow #2A4A6E,
small 2px icicle drip from bottom-right corner of body,
barrel: 4px diameter horizontal tube pointing right from mid-right of body to x=31,
#2A2A33 1px outline on all external edges,

frame 0 (IDLE): barrel opening has dim glow, innermost 2px #4E7CA1 only,
no extra brightness, machine is dormant but armed,

frame 1 (CHARGE): barrel glowing brightly, building energy,
innermost 2px #FFFFFF bright white,
outer ring 4px #B8D8FF blue halo around barrel tip,
2px energy particle dots scattered near barrel mouth (1-2 loose pixels in #9EE0F0),
body slightly brighter modulation to suggest power draw,

frame 2 (FIRE): maximum brightness explosion at barrel tip,
5px starburst muzzle flash at barrel tip: center #FFFFFF, outer points #B8D8FF,
barrel pushed back 1px (recoil), body shaking 1px downward,
small smoke/frost puff 3px wide #B8D8FF semi-circle just outside barrel tip,

frame 3 (DEAD): barrel shattered - barrel pixels replaced by angular ice shard fragments,
4-5 ice fragment triangles in #B8D8FF and #4E7CA1 radiating outward from barrel area,
body has large crack #1A2E42 diagonal line across machine body,
base intact but tilted 2px, overall silhouette collapsed and broken,

pixel art, Cave Story enemy style, cold mechanical turret, 4 clearly distinct states
```

## 在 Godot 中接入
不需要手动操作，场景文件已配置好，放入图片后 Godot 自动识别。

---

# ══════════════════════════════════════════════════════
# 资源 3：冰球弹丸（IceBall）
# ══════════════════════════════════════════════════════
# 文件：game/assets/sprites/enemies/iceball_sheet.png
# 放入路径：game/assets/sprites/enemies/iceball_sheet.png（新文件）
#
# 尺寸：16×16px，单帧（1张静态图）
#
# 脚本在运动中自动旋转（rotation = direction.angle()），不需要旋转帧

## 完整 AI Prompt（直接复制）

```
pixel art game projectile sprite, 16x16px, transparent background,
no antialiasing, hard pixel edges,
solid ice ball sphere, perfect round compact shape,
lit from upper-left:
  upper-left 6px area: #B8D8FF (bright lit face),
  center-right area: #4E7CA1 (mid tone),
  lower-right area: #1A2E42 (deep shadow),
  1px #FFFFFF specular highlight dot at upper-left (10 o'clock position),
#2A2A33 thin 1px outer outline,
no flat faces, no cracks, smooth frozen sphere,
cold dangerous blue, small but clearly readable as a projectile,
pixel art, enemy bullet sprite, 16x16 must be clearly a ball shape
```

---

# ══════════════════════════════════════════════════════
# 生成完成后
# ══════════════════════════════════════════════════════
#
# 把三张图放进对应路径，直接运行游戏即可，不需要在 Godot 编辑器里做任何额外操作。
