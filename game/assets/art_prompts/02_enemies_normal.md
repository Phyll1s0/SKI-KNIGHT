# 普通敌人 Spritesheet 生成指南
# 包含：雪人兵（SnowmanSoldier）、冰球炮台（IceTurret）、冰球弹丸（IceBall）

---

# ═══════════════════════════════════════════════════════════
# 敌人 A：雪人兵（SnowmanSoldier）
# ═══════════════════════════════════════════════════════════
# 文件：game/assets/sprites/enemies/snowman_sheet.png
# 规格：32×48px 每帧，横向排列，共 20 帧，总图尺寸 640×48px

## 角色外观描述

**造型定位**：圆滚滚的雪人形态改造成士兵，可爱但危险
**整体配色**：白色雪体，深蓝军帽，橙色萝卜鼻，黑色扣子眼
**体型**：两节雪球叠成（下大上小），双臂是短树枝但手持武器
**装备**：头戴 #1A2E42 深蓝军帽（有帽檐），右手持冰棒球棍或雪铲
**特征**：行走时摇摇晃晃，攻击时整个身体前冲，死亡时融化

## 色板（最多 6 色）

| 用途         | 颜色     |
|-------------|---------- |
| 雪体主色     | #E8F0FF  |
| 雪体阴影     | #8AAED0  |
| 轮廓线       | #2A2A33  |
| 军帽/武器    | #1A2E42  |
| 萝卜鼻       | #FF7030  |
| 眼睛/扣子    | #2A2A33（同轮廓）|

## 基础 AI Prompt 前缀

```
pixel art game enemy sprite sheet, 32x48px per frame, transparent background,
no antialiasing, hard pixel edges, 2D platformer side view,
snowman soldier enemy character, round white snow body two segments,
dark blue military cap with brim, orange carrot nose, black button eyes,
holding ice mace/club weapon in right twig arm,
cute but menacing cartoon snowman design,
palette: #E8F0FF #8AAED0 #1A2E42 #FF7030 #2A2A33,
pixel art, Cave Story enemy style,
```

---

## 动画 1：walk（巡逻行走）

**起始列**：0，**帧数**：4，**FPS**：10，**循环**：是

**完整 AI Prompt**：
```
pixel art enemy sprite sheet, 32x48px per frame, 4 frames horizontal,
transparent background, snowman soldier walking patrol facing right,
frame 1: neutral stance, right foot slightly forward, body upright,
body tilts 3 degrees right with waddling motion,
frame 2: weight shifted, body wobbles left 3 degrees, feet closer together,
frame 3: left foot forward, body tilting right again (mirrored from frame 1),
frame 4: feet together again completing waddle cycle,
ice club weapon swinging slightly with body movement,
snowman waddle walk, cute and bouncy motion, slight body squish on weight-bearing frames,
white round snow body, dark blue military cap, carrot nose visible,
pixel art, #2A2A33 outline, 2D platformer enemy sprite
```

---

## 动画 2：chase（快速追击）

**起始列**：4，**帧数**：6，**FPS**：14，**循环**：是

**完整 AI Prompt**：
```
pixel art enemy sprite sheet, 32x48px per frame, 6 frames horizontal,
transparent background, snowman soldier running to chase player facing right,
faster and more frantic version of walk, body leaning forward 15 degrees,
arms (twig arms) pumping forward, weapon raised and ready,
feet moving faster with less ground contact between frames,
body slightly compressed vertically during fast run (eagerness/aggression),
military cap tilting back slightly from speed,
6-frame run cycle with clear stride rhythm,
white round snow body, dark blue cap, carrot nose, black buttons,
pixel art, #2A2A33 outline, Cave Story style enemy
```

---

## 动画 3：attack（挥棒攻击）

**起始列**：10，**帧数**：4，**FPS**：14，**循环**：否
**第 3 帧**：判定帧（代码触发伤害）

**完整 AI Prompt**：
```
pixel art enemy sprite sheet, 32x48px per frame, 4 frames horizontal,
transparent background, snowman soldier melee attack facing right,
frame 1 WINDUP: ice club raised high overhead, body leaning back, clearly preparing to strike,
snowman body stretched slightly upward with effort,
frame 2 SWING: club beginning downward arc, body twisting forward, weight shifting,
frame 3 HIT FRAME: club fully swung forward at waist height, impact position,
3px white impact star/burst pixels in front of club tip (#FFFFFF),
body fully committed to swing, forward lean,
frame 4 RECOVERY: club lowered, body returning to upright, brief pause,
exaggerated windup and follow-through, readable attack silhouette,
white snow body, dark blue cap, carrot nose,
pixel art, #2A2A33 outline, 2D platformer attack animation
```

---

## 动画 4：hurt（受击）

**起始列**：14，**帧数**：2，**FPS**：12，**循环**：否

**完整 AI Prompt**：
```
pixel art enemy sprite sheet, 32x48px per frame, 2 frames horizontal,
transparent background, snowman soldier taking damage facing right,
frame 1: white flash frame, all body pixels #FFFFFF (invincibility flash),
body knocked back 3px, arms thrown backward,
carrot nose tilted from impact, cap askew,
3 red damage particles #E84040 near impact point,
frame 2: body returning forward, still slightly shifted, snowflake cracks on body,
brief pain reaction, hat still tilted,
white snow body with damage indication, cute but hurting,
pixel art, #2A2A33 outline
```

---

## 动画 5：dead（死亡融化）

**起始列**：16，**帧数**：4，**FPS**：10，**循环**：否（最后帧保持）

**完整 AI Prompt**：
```
pixel art enemy sprite sheet, 32x48px per frame, 4 frames horizontal,
transparent background, snowman soldier melting and dying facing right,
frame 1: staggering, club dropping from twig arms, body tilting badly,
frame 2: upper snow ball is sliding off lower ball, cap falling,
melting effect: snow body losing circular shape, dripping 2px downward,
frame 3: upper ball mostly melted into lower ball, just a mound now,
carrot nose fallen to side, buttons scattered as separate pixels,
frame 4 HOLD: small melted snow mound on ground, 2px puddle pixels on each side,
cap lying flat beside the mound, weapon half-buried in snow mound,
cute sad death, all melted into snow heap, no blood,
pixel art, #2A2A33 outline, comedic demise
```

---

# ═══════════════════════════════════════════════════════════
# 敌人 B：冰球炮台（IceTurret）
# ═══════════════════════════════════════════════════════════
# 文件：game/assets/sprites/enemies/turret_sheet.png
# 规格：32×32px 每帧，横向排列，共 12 帧，总图尺寸 384×32px

## 角色外观描述

**造型定位**：固定炮台形态，不移动，机械感+冰雪感混合
**结构**：底座（方形锚固在地面，#1A2E42）+ 主炮身（圆柱体，#4E7CA1）+ 炮口（圆形开口，#B8D8FF 内壁）
**特征**：炮口对准玩家方向（代码处理旋转），发射时有明显的充能闪光

## 色板

| 用途         | 颜色     |
|-------------|---------- |
| 主炮身       | #4E7CA1  |
| 炮身高光     | #B8D8FF  |
| 底座/暗部    | #1A2E42  |
| 轮廓线       | #2A2A33  |
| 充能发光     | #FFFFFF  |

---

## 动画 1：idle（待机震动）

**起始列**：0，**帧数**：2，**FPS**：4，**循环**：是

**完整 AI Prompt**：
```
pixel art game object sprite sheet, 32x32px per frame, 2 frames horizontal,
transparent background, ice turret stationary object, mechanical ice cannon,
square dark base anchored to ground (#1A2E42), cylindrical ice-blue cannon body (#4E7CA1),
round barrel opening facing right with blue-white glow inside,
frame 1: neutral position, faint light inside barrel,
frame 2: barrel shifted 1px up, single bright pixel inside barrel,
subtle idle hum/vibration, machine is armed and ready,
no legs, no face, purely mechanical weapon object,
palette: #4E7CA1 #B8D8FF #1A2E42 #2A2A33 #FFFFFF,
pixel art, 2D platformer turret sprite, compact readable silhouette
```

---

## 动画 2：aim（瞄准转向）

**起始列**：2，**帧数**：4，**FPS**：12，**循环**：否

**完整 AI Prompt**：
```
pixel art game object sprite sheet, 32x32px per frame, 4 frames horizontal,
transparent background, ice turret aiming animation,
barrel rotates from slightly low position to target direction (facing right-up diagonal),
mechanical rotation effect: gears/grind lines 1-2px near rotation joint,
frame 1: barrel pointing slightly downward-right,
frame 2: barrel horizontal right,
frame 3: barrel slightly upward-right,
frame 4: barrel locked at target angle, brief brightness pulse in barrel,
base remains fully stationary throughout, only barrel moves,
ice-blue cannon body, dark base, barrel glows brighter as it locks on,
pixel art, #2A2A33 outline, mechanical aiming motion
```

---

## 动画 3：fire（发射）

**起始列**：6，**帧数**：3，**FPS**：18，**循环**：否
**第 2 帧**：生成 IceBall 弹丸的时机

**完整 AI Prompt**：
```
pixel art game object sprite sheet, 32x32px per frame, 3 frames horizontal,
transparent background, ice turret firing projectile,
frame 1 CHARGE: barrel glowing brightly, 4-5 bright white pixels inside barrel opening,
barrel slightly pulled back 1px (recoil prep),
ice energy particles 2-3px around barrel mouth in #B8D8FF and #FFFFFF,
frame 2 FIRE: barrel at maximum brightness, projectile leaving barrel mouth (round ice ball just outside),
barrel at full forward position, muzzle flash: 3px star burst in #FFFFFF at barrel tip,
frame 3 RECOIL: barrel pushed back 2px from kick, brightness fading,
smoke/frost puff 4px wide at barrel tip in #B8D8FF semi-circle shape,
compact explosive action, fast and punchy,
pixel art, #2A2A33 outline, turret firing animation
```

---

## 动画 4：dead（破坏）

**起始列**：9，**帧数**：3，**FPS**：10，**循环**：否

**完整 AI Prompt**：
```
pixel art game object sprite sheet, 32x32px per frame, 3 frames horizontal,
transparent background, ice turret being destroyed,
frame 1: large crack appearing on barrel, 3px crack lines in #FFFFFF on #4E7CA1 body,
frame 2: barrel shattering, large ice chunk fragments (5-6 angular ice pieces) flying outward,
ice fragments in #B8D8FF and #4E7CA1, spreading in all directions,
base cracking also, sparks or small ice debris pixels,
frame 3: only broken base remains, scattered ice rubble pieces around it (5px wide pile),
barrel completely gone, base cracked open,
dramatic destruction, sharp ice fragmentation effect,
pixel art, #2A2A33 outline, satisfying destruction animation
```

---

# ═══════════════════════════════════════════════════════════
# 弹丸：冰球（IceBall）
# ═══════════════════════════════════════════════════════════
# 文件：game/assets/sprites/enemies/iceball_sheet.png
# 规格：16×16px 每帧，横向排列，共 8 帧（飞行旋转循环），总图尺寸 128×16px

**完整 AI Prompt**：
```
pixel art game projectile sprite sheet, 16x16px per frame, 8 frames horizontal,
transparent background, spinning ice ball projectile,
solid sphere of ice, not hollow, smooth round shape,
colors: #B8D8FF light face (lit side), #4E7CA1 mid tone, #1A2E42 shadow, #FFFFFF 1px specular highlight,
#2A2A33 thin outline,
8 frames show full 360 degree rotation of the sphere,
highlight and shadow position shifts each frame to simulate spin,
frame 1: highlight at upper-left 10 o'clock position,
frame 2: highlight at upper 12 o'clock, rotating clockwise,
frames 3-8: highlight continues rotating clockwise completing full spin,
clean sphere shape, cold blue tones, the ball is dangerous and frozen,
pixel art, small projectile sprite, compact and readable
```

---

## 生成建议

1. 先生成雪人兵的 `walk` 动画建立基础外观，用生成图作为后续动画的角色参考
2. 炮台各动画尺寸较小（32×32），适合 pixel art AI 工具精细生成
3. 冰球（16×16）极小，建议先生成 64×64 版本再缩小，或在 AI prompt 中明确要求"designed to look good at 16x16 pixels"
