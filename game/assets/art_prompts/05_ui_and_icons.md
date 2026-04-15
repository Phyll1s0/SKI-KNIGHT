# UI 图标 & 装备图标生成指南
# 包含：HUD 图标、装备图标、场景交互物、特效 Sprite

---

# ═══════════════════════════════════════════════════════════
# 一、HUD 图标（scenes/ui/HUD.tscn 接入）
# ═══════════════════════════════════════════════════════════

## 1.1 hp_icon.png — 16×16px，单帧

**用途**：血量条左侧图标
**接入**：HUD.tscn → HPIcon（TextureRect）
**外观**：红心形图案，中央有雪花纹路，冷暖对比强（爱心暖，雪花冷）

**完整 AI Prompt**：
```
pixel art UI icon, 16x16px, transparent background, no antialiasing,
heart health icon with winter snow theme,
red heart shape #E84040 with white snowflake pattern #FFFFFF inside heart,
1px #2A2A33 outline around heart, small #B8D8FF highlight at upper-left of heart,
clean and readable at small size, no drop shadow,
pixel art game HUD icon, platformer health icon
```

---

## 1.2 exp_icon.png — 16×16px，单帧

**用途**：经验值条左侧图标
**接入**：HUD.tscn → EXPIcon（TextureRect）

**完整 AI Prompt**：
```
pixel art UI icon, 16x16px, transparent background, no antialiasing,
experience star icon, 5-pointed star shape,
ice blue color #B8D8FF main, #FFFFFF center highlight, #4E7CA1 shadow side of star,
1px #2A2A33 outline, star oriented with one point straight up,
small sparkle effect: 2 single pixel highlights near star tips,
clean sharp star, game XP icon, cold blue crystal star
```

---

## 1.3 skill_cooldown_icon.png — 24×24px，单帧（+overlay）

**用途**：技能槽背景图标（冰刃技能）
**接入**：HUD.tscn → SkillSlot → SkillIcon

**完整 AI Prompt**：
```
pixel art UI skill icon, 24x24px, transparent background, no antialiasing,
ice blade skill icon, crescent blade silhouette,
main blade shape angled at 45 degrees (upper-left to lower-right),
ice blue #B8D8FF with #FFFFFF sharp edge highlight 1px on upper edge of blade,
cold blue glow aura 1px around entire blade shape (#4E7CA1 soft border),
#2A2A33 outer outline, inner blade has subtle refraction detail,
frozen element magic skill icon, pixel art game ability icon
```

---

## 1.4 minimap_icons — 8×8px each，3 variants

**接入**：HUD.tscn → Minimap → 各标注点

**完整 AI Prompt（3 图标单行排列，总 24×8px）**：
```
pixel art minimap icons, 8x8px per icon, 3 icons horizontal row, transparent background,
no antialiasing, very small pixel icons for game minimap:
icon 1 PLAYER: bright yellow dot #E8C87A with 1px white outline, 5x5 circle, readable on dark map,
icon 2 SAVE POINT: small flag shape, #4E7CA1 flag #FFFFFF flag pole, 6x7px shape,
icon 3 PORTAL: small swirl/circle, #B8D8FF ring with dark center, pulsing feel in 1 frame,
all icons readable at 8x8 minimum size, high contrast for minimap overlay,
pixel art, minimal detail while maintaining recognition
```

---

# ═══════════════════════════════════════════════════════════
# 二、装备图标（equipment icons）
# ═══════════════════════════════════════════════════════════
# 所有装备图标：24×24px，透明背景，白色 1px 描边（在深色 HUD 背景下）

## 通用 AI Prompt 前缀

```
pixel art equipment icon, 24x24px, transparent background, no antialiasing,
3px empty border around edges, centered subject,
1px white #FFFFFF outer outline for visibility on dark UI background,
#2A2A33 inner detail outline, winter skiing gear theme, collectible item icon style,
```

---

## 2.1 helmet.png — 头盔（HELMET slot）

**完整 AI Prompt**：
```
pixel art equipment icon, 24x24px, transparent background,
ski helmet front view, round dome helmet shape,
pale ice blue main #4E7CA1, highlight #B8D8FF at upper-left curve,
shadow #1A2E42 on right side, chin guard visible at bottom,
ventilation line 1px on side, no visor (goggles are separate item),
clean side-forward 3/4 view of ski helmet, 1px white border,
pixel art collectible item icon
```

---

## 2.2 goggles_1.png — 护目镜一级

**完整 AI Prompt**：
```
pixel art equipment icon, 24x24px, transparent background,
ski goggles icon, double-lens goggle shape viewed from slight angle,
round twin lenses, frame color #1A2E42 dark rubber rim,
lens color: warm amber/orange #E8C87A (tinted lens), #FFFFFF small glare point top-right of lens,
elastic strap visible at side edges as 2px dark strap lines,
first tier goggles - functional but basic looking,
1px white border, pixel art, game item icon
```

---

## 2.3 goggles_2.png — 护目镜二级（升级版）

**完整 AI Prompt**：
```
pixel art equipment icon, 24x24px, transparent background,
upgraded ski goggles, more advanced design than tier 1,
twin lens goggles with side wing pieces added (aerodynamic side flaps +2px each side),
lens color: deep blue-purple gradient #4060FF to #B8D8FF (magical tech lens),
inner #FFFFFF bright glow point inside lens suggests active HUD display,
frame: #4E7CA1 metallic, not rubber, upgraded material,
small electric arc 2px lines near wing tips in #FFFFFF,
clearly superior to tier 1, glowing magical feeling,
1px white border, pixel art, upgraded item icon
```

---

## 2.4 snowboard_upgrade.png — 升级雪板

**完整 AI Prompt**：
```
pixel art equipment icon, 24x24px, transparent background,
snowboard side profile view, flat board seen from slight angle,
board shape: long narrow oval from side, slight tip-up at front end,
main board color: #4E7CA1 blue surface with white stripe graphic #FFFFFF running lengthwise,
board edges: #1A2E42 metal edge visible as 1px line along bottom,
binding straps: 2 small strap bumps on top of board in #2A2A33,
metallic trim highlights: #B8D8FF along board rails (upgraded metal edge version),
1px white border, pixel art, equipment upgrade icon, skiing gear
```

---

## 2.5 suit.png — 高级雪服

**完整 AI Prompt**：
```
pixel art equipment icon, 24x24px, transparent background,
advanced ski suit chest/torso piece viewed slightly from front,
folded/laid flat presentation style (jacket laid flat),
main suit color: deep blue #1A2E42, with ice blue #B8D8FF accent stripes down sleeves,
two glowing #4060FF circuit-like line details on chest (technology integrated suit),
fur collar visible at neck in white #E8F0FF fluffy texture (3px wide fur cluster pixels),
zipper detail 2px line down center front,
clearly the best suit, premium winter tech gear look,
1px white border, pixel art, final tier equipment icon
```

---

## 2.6 SkillPickup Icon — skill_gate_icon.png — 32×32px

**用途**：SkillGate 上显示的技能图标（提示玩家解锁技能）
**接入**：scenes/systems/SkillGate.tscn → Icon Sprite2D

**完整 AI Prompt**：
```
pixel art floating skill gate icon, 32x32px, transparent background,
glowing question mark or ice blade emblem, collectible skill indicator,
outer ring: circular border 2px in #B8D8FF with 4 small 1px star notches at cardinal points,
inner area: ice blade silhouette in #B8D8FF, crescent shape at angle,
glow effect: 2px very faint outer brim #4E7CA1 around entire icon,
this floats above a gate/door indicating a skill will be unlocked,
magical and inviting, slightly animated feel (single frame, but glowing quality),
pixel art, 2D platformer skill unlock icon
```

---

# ═══════════════════════════════════════════════════════════
# 三、场景交互物 Sprites
# ═══════════════════════════════════════════════════════════

## 3.1 portal.png — 32×32px，4 帧动画（传送门）

**接入**：scenes/systems/Portal.tscn → Sprite2D（AnimationPlayer 循环）

**完整 AI Prompt**：
```
pixel art animated portal sprite sheet, 32x32px per frame, 4 frames horizontal,
transparent background, no antialiasing,
magical swirling portal to next area, circular vortex design,
outer ring: #4E7CA1 solid ring 2px, inner swirling region,
4 frames show clockwise rotation of swirl:
frame 1: swirl at 0 degrees, 3 curved spiral arms emanating from center in #B8D8FF,
frame 2: swirl rotated 90 degrees clockwise,
frame 3: 180 degrees,
frame 4: 270 degrees,
center has bright #FFFFFF core point (destination light),
outer glow 1px: #B8D8FF faint ring around entire portal,
enchanting magical doorway, cold and beckoning,
pixel art, game portal sprite, looping rotation animation
```

---

## 3.2 savepoint.png — 32×32px，4 帧（存档点旗帜）

**接入**：scenes/systems/SavePoint.tscn → Sprite2D

**完整 AI Prompt**：
```
pixel art animated save point sprite, 32x32px per frame, 4 frames horizontal,
transparent background, no antialiasing,
checkpoint flag waving in wind, classic game save point flag style,
flag pole: white thin pole #E8F0FF 2px wide, centered-left in frame, full height,
flag attached to pole top: flag body #4E7CA1 with #FFFFFF star or S symbol,
4 frames show flag waving right:
frame 1: flag straight out horizontal,
frame 2: flag end curling upward slightly,
frame 3: flag center curved, wave visible,
frame 4: flag settling back to near-straight,
light snow particles 1-2px randomly placed near flag (wind effect),
inviting and safe-feeling, sanctuary marker in dangerous world,
pixel art, game save point sprite, looping flag animation
```

---

## 3.3 spawn_indicator.png — 24×24px，2 帧（出生点指示）

**完整 AI Prompt**：
```
pixel art spawn point indicator, 24x24px, 2 frames horizontal, transparent background,
glowing down-arrow indicator showing spawn/respawn location,
down-pointing arrow shape #B8D8FF, simple bold design,
frame 1: arrow at normal brightness,
frame 2: arrow slightly brighter with 1px outer glow pulse,
gentle pulsing glow to indicate spawn location,
pixel art, minimal design, clearly an arrow pointing down
```

---

## 3.4 cable_car.png — 48×32px，单帧（缆车厢体）

**接入**：scenes/systems/CableCar.tscn → Sprite2D

**完整 AI Prompt**：
```
pixel art object sprite, 48x32px, transparent background, no antialiasing,
cable car gondola side view, ski resort cable car cabin,
boxy gondola shape 40×28px, light blue-grey body (#B0BEC5),
two windows visible on side: rectangular 8×6px windows with #B8D8FF glass tint,
window frame #1A2E42,
roof slightly darker than sides, #8AAED0,
mounting hook on top: small rectangular hook piece 4×4px attached to top center,
wheel/pulley implied: 2px dark circle at top center where cable attaches,
snow sitting on top of cable car roof 2px #FFFFFF pile,
distinct transporty mechanical feel, ski resort industrial aesthetic,
pixel art, 2D platformer object, functional visual design
```

---

# ═══════════════════════════════════════════════════════════
# 四、特效 Sprites（scenes/effects/）
# ═══════════════════════════════════════════════════════════

## 4.1 hit_effect_sprite.png — 16×16px，4帧（命中特效种子图）

**用途**：HitEffect 粒子系统的纹理基础（单颗粒子形状）
**接入**：scenes/effects/HitEffect.tscn → Particles2D.texture

**完整 AI Prompt**：
```
pixel art particle texture, 16x16px, transparent background,
single hit effect splash particle, star burst shard shape,
4-pointed angular star #FFFFFF center, #B8D8FF body, #4E7CA1 outline,
centered in 16x16 canvas, 6x6px total size of particle shape,
this small graphic will be duplicated and scattered for hit effect particle system,
clean sharp shard shape, not round, angular,
pixel art, particle sprite, ice impact shard texture
```

---

## 4.2 snow_flake_sprite.png — 8×8px，2帧（雪花环境粒子）

**用途**：SnowAmbient 粒子系统的纹理
**接入**：scenes/effects/SnowAmbient.tscn → Particles2D.texture

**完整 AI Prompt**：
```
pixel art snowflake particle texture, 8x8px per frame, 2 frames horizontal, transparent background,
simple 6-pointed snowflake outline, minimal pixel art style,
frame 1: full #FFFFFF snowflake outline, 6 points radiating from center,
center dot 1px, 3 main arms 3px with 1px branches,
frame 2: same snowflake slightly smaller/dimmer #B8D8FF for variation,
both frames: snowflake fits in 6x6 area centered in 8x8 canvas,
particle texture for ambient falling snow effect, very simple,
pixel art, atmospheric particle sprite
```

---

## 4.3 attack_trail_sprite.png — 16×8px，单帧（攻击残影粒子）

**用途**：AttackTrail 粒子系统纹理
**接入**：scenes/effects/AttackTrail.tscn → Particles2D.texture

**完整 AI Prompt**：
```
pixel art slash trail particle texture, 16x8px, transparent background,
single arc slash particle, elongated curved slash mark,
left side thin, right side thicker tapered arc shape (like a speed line),
color: #B8D8FF left end fading to #FFFFFF right end,
left 4px: 1 pixel wide, right 4px: 3 pixels wide, smooth taper,
this shape will be instanced many times in an arc pattern for sword trail,
pixel art, attack trail texture, sword slash particle
```

---

## 生成建议

1. **图标批量生成**：HUD 图标和装备图标较小（16~24px），建议在 AI 生成时放大4x生成（64~96px），然后手动缩小至目标尺寸并在 Godot 设置 Filter=Nearest
2. **一致性检查**：所有装备图标应使用相同的光源方向和轮廓风格
3. **传送门/旗帜**：动画类 sprite 建议逐帧检查过渡是否流畅
4. **粒子纹理**：对粒子系统的纹理，外形的可读性比颜色更重要（因为颜色在 ParticlesMaterial 中可调）
