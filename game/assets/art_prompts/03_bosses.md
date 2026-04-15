# Boss 角色 Spritesheet 生成指南
# 包含：Boss1 冰川雪豹（IceLynx）、Boss2 冻结守卫（FrozenGuard）、Boss3 雪山之王（SnowKing）

---

# ═══════════════════════════════════════════════════════════
# BOSS 1 — 冰川雪豹（IceLynx）
# ═══════════════════════════════════════════════════════════
# 文件：game/assets/sprites/enemies/bosses/ice_lynx_sheet.png
# 规格：64×64px 每帧，横向排列，共 38 帧，总图尺寸 2432×64px

## 角色外观描述

**造型定位**：野性冰雪猎豹，低重心扑击型猛兽，充满压迫感与速度感
**体型**：四足兽，身长约 56px，肩高约 28px，尾巴长 20px
**配色**：蓝白冰色皮毛（斑纹），眼睛在二阶段变红
**细节**：
- 皮毛：白底（#E8F0FF），蓝灰斑纹（#4E7CA1），下腹更白
- 爪子：锋利冰晶质感（#B8D8FF 透明感），各「爪」2~3px 宽
- 尾巴：毛茸茸，末端有冰晶结晶体（5px 蓝白粒子）
- 眼睛：Phase1 黄色（#E8C87A），Phase2 火红色（#E84040）

## 色板

| 用途         | 颜色     |
|-------------|---------- |
| 皮毛主色     | #E8F0FF  |
| 斑纹/阴影    | #4E7CA1  |
| 深阴影       | #1A2E42  |
| 爪子/冰晶    | #B8D8FF  |
| 眼睛 P1      | #E8C87A  |
| 眼睛 P2      | #E84040  |
| 轮廓线       | #2A2A33  |

## 基础 AI Prompt 前缀

```
pixel art game boss sprite sheet, 64x64px per frame, transparent background,
no antialiasing, hard pixel edges, side view 2D platformer,
ice lynx snow leopard boss enemy, quadruped feline beast,
icy-white fur with blue-grey spots and markings,
long crystal tail with ice shards at tip, sharp ice claw toes,
yellow predator eyes, low prowling hunting stance,
palette: #E8F0FF #4E7CA1 #1A2E42 #B8D8FF #E8C87A #2A2A33,
pixel art, dangerous boss monster, Cave Story boss style,
```

---

## 动画 1：idle（蓄势潜伏）

**帧数**：4 帧 | **FPS**：8 | **循环**：是

**完整 AI Prompt**：
```
pixel art boss sprite sheet, 64x64px per frame, 4 frames horizontal, transparent background,
ice snow leopard idle stance, low crouching predator posture,
belly nearly touching ground, weight forward on front paws,
tail slowly swishing side to side: frame 1 center, frame 2 right, frame 3 center, frame 4 left,
body breathing slightly: ribcage subtle expansion/contraction 1-2px,
yellow eyes scanning left (both eyes visible from profile),
tail tip ice crystals glinting with 1px highlight shift each frame,
tense coiled energy, ready to pounce but holding still,
white fur with blue-grey spots, sharp ice claw highlights on front paws,
pixel art, #2A2A33 outline, dangerous but beautiful wild cat
```

---

## 动画 2：approach（逼近奔跑）

**帧数**：6 帧 | **FPS**：12 | **循环**：是

**完整 AI Prompt**：
```
pixel art boss sprite sheet, 64x64px per frame, 6 frames horizontal, transparent background,
ice snow leopard running toward target facing right,
galloping gait with all 4 legs cycling, big cat run animation,
low sleek body position, ears pinned back in aggression,
frame 1-2: front legs extended forward and back legs pushed off,
frame 3: airborne moment - all 4 paws off ground body stretched long,
frame 4-5: front legs landing, body compressing, back legs swinging forward,
frame 6: back legs landing, body stretching as front legs launch,
long sweeping strides, powerful muscle movement visible in limbs,
white fur rippling, spots blurring with speed, tail streaming behind,
yellow eyes fixed ahead, claws catching light each landing frame,
pixel art, #2A2A33 outline, fierce predator run cycle
```

---

## 动画 3：pounce_windup（扑击蓄力）

**帧数**：4 帧 | **FPS**：10 | **循环**：否

**完整 AI Prompt**：
```
pixel art boss sprite sheet, 64x64px per frame, 4 frames horizontal, transparent background,
ice snow leopard pounce windup, coiling for massive leap,
frame 1: beginning to crouch, haunches lowering,
frame 2: fully crouched, back arched high (HUMP upward), front low, rear legs compressed,
frame 3: body tension maximum, claws gripping ground,
small ice cracks 3px under claw points on ground level area,
eyes wide and locked on target,
frame 4: hold tension, single frame pause with slight body shiver (quivering muscles),
readable and telegraphed windup, player must react to this,
white fur tense, fur standing slightly, ice tail raised,
pixel art, #2A2A33 outline
```

---

## 动画 4：pounce_air（腾空扑击）

**帧数**：5 帧 | **FPS**：16 | **循环**：否
**第 3 帧**：空中判定帧，前爪接触玩家时触发伤害

**完整 AI Prompt**：
```
pixel art boss sprite sheet, 64x64px per frame, 5 frames horizontal, transparent background,
ice snow leopard mid-pounce airborne attack facing right,
frame 1: just launched, body fully stretched diagonal (head-forward, tail-back), explosive start,
all 4 legs completely extended like an arrow,
frame 2: peak of arc, body level, front claws spread wide and leading,
frame 3 IMPACT: front claws swiping downforward, spread claw attack, DAMAGE FRAME,
5px claw slash marks in #B8D8FF appear in front of claws,
body slightly compressed for impact,
frame 4: follow through, body angled past horizontal, below peak,
frame 5: landing trajectory, front paws nearly at ground, bracing for landing,
dynamic airborne predator, speed lines 4px behind body,
white fur, ice claws glinting, yellow eyes locked down on target,
pixel art, #2A2A33 outline, dramatic airborne boss attack
```

---

## 动画 5：recover（落地恢复）

**帧数**：3 帧 | **FPS**：10 | **循环**：否

**完整 AI Prompt**：
```
pixel art boss sprite sheet, 64x64px per frame, 3 frames horizontal, transparent background,
ice snow leopard landing and recovering after pounce,
frame 1: both front paws hitting ground, body fully compressed (squash), snow dust burst 6px wide,
frame 2: body bouncing up slightly from impact, shaking head, gathering footing,
frame 3: back fully on all 4 legs, stable but slightly winded, brief vulnerable moment,
landing snow particles: 4-6 white #FFFFFF pixels scattering outward from paw impact,
brief moment of recovery before next attack, slight openness in posture,
white fur, ice claws,
pixel art, #2A2A33 outline
```

---

## 动画 6：melee_windup（近爪蓄力）

**帧数**：3 帧 | **FPS**：12 | **循环**：否

**完整 AI Prompt**：
```
pixel art boss sprite sheet, 64x64px per frame, 3 frames horizontal, transparent background,
ice snow leopard rearing up on hind legs for claw swipe,
frame 1: beginning to rear, front paws lifting off ground, rising,
frame 2: fully reared on haunches, front paws raised high overhead, claws spread wide,
body at 70 degree angle from ground, looming over target,
frame 3: front paw pulled back, coiling for horizontal swipe, claws glowing ice blue #B8D8FF,
intimidating raised pose, large silhouette, threatening windup,
pixel art, #2A2A33 outline
```

---

## 动画 7：melee（爪击）

**帧数**：3 帧 | **FPS**：18 | **循环**：否
**第 2 帧**：判定帧

**完整 AI Prompt**：
```
pixel art boss sprite sheet, 64x64px per frame, 3 frames horizontal, transparent background,
ice snow leopard swiping claw attack facing right,
frame 1: claws drawn back at peak, about to swipe,
frame 2 DAMAGE FRAME: single front paw swiped horizontally forward, fully extended,
5 claw slash lines in blue-white #B8D8FF extending 10px from claw tips,
claw marks like 5 parallel diagonal lines, ice energy on each claw,
frame 3: claw swept past, arm lowering, landing back on all 4s,
fast and brutal swipe motion, clear reading of danger zone,
pixel art, #2A2A33 outline
```

---

## 动画 8：hurt（受击）

**帧数**：2 帧 | **FPS**：14 | **循环**：否

**完整 AI Prompt**：
```
pixel art boss sprite sheet, 64x64px per frame, 2 frames horizontal, transparent background,
ice snow leopard hit reaction,
frame 1: white full-body flash, entire sprite briefly #FFFFFF (invincibility frame),
3-4 red hit particles #E84040 at impact area, body flinching backward 3px,
frame 2: body returning, shaking head in anger, slight color recovering,
boss damage reaction, brief but visible, conveys hurt without losing intimidation,
pixel art, #2A2A33 outline
```

---

## 动画 9：dead（死亡）

**帧数**：6 帧 | **FPS**：9 | **循环**：否（最后帧定格）

**完整 AI Prompt**：
```
pixel art boss sprite sheet, 64x64px per frame, 6 frames horizontal, transparent background,
ice snow leopard death animation,
frame 1: staggering, legs buckling, body tilting, head lowered,
frame 2: collapsing, front legs failing, falling sideways to left,
frame 3: lying on side, legs still twitching slightly, eyes closed,
frame 4: body beginning to crystallize/freeze, ice crystal pixels appearing (8-10px total)
on fur edges in #B8D8FF, fur texture hardening into ice,
frame 5: half crystallized, fur replaced by jagged ice surface,
frame 6 HOLD: fully crystallized into ice statue, lying on side, still pose,
brief pale ice glow aura 2px around statue, then fades (2 small sparkle pixels),
poignant powerful death, monster becoming part of the glacier,
pixel art, #2A2A33 outline
```

---

## 动画 10：phase2_intro（二阶段觉醒）

**帧数**：4 帧 | **FPS**：8 | **循环**：否

**完整 AI Prompt**：
```
pixel art boss sprite sheet, 64x64px per frame, 4 frames horizontal, transparent background,
ice snow leopard phase 2 transformation intro,
frame 1: standing still, trembling, eyes still yellow but flickering,
frame 2: head snapping up, eyes turning from yellow to bright red #E84040,
fur standing up all over body, body crackling with red energy lines (2px cracks glowing red),
frame 3: letting out silent roar (mouth open wide, sharp teeth visible),
ice aura explodes outward: 6-8 ice shard pixels in #B8D8FF radiating from body,
eyes fully red and glowing,
frame 4: settle into aggressive low prowl, red eyes scanning, aura dissipated but more intense,
dramatic power awakening moment, clear visual change marking phase 2,
pixel art, #2A2A33 outline
```

---

# ═══════════════════════════════════════════════════════════
# BOSS 2 — 冻结守卫（FrozenGuard）
# ═══════════════════════════════════════════════════════════
# 文件：game/assets/sprites/enemies/bosses/frozen_guard_sheet.png
# 规格：64×80px 每帧，横向排列，共 40 帧，总图尺寸 2560×80px
# 附加：shield_intact.png（32×40px，3帧）、shield_broken.png（32×40px，4帧）

## 角色外观描述

**造型定位**：高大重甲守卫，古代冰雪帝国的遗留战士，方正威严
**体型**：人形，比玩家高出两倍，宽拦厚重，64×80px 画布（身体约 44×72px）
**配色**：
- 铠甲主色：铁灰蓝（#2A4A62）
- 铠甲高光：冰蓝（#B8D8FF）
- 铠甲阴影：深蓝黑（#0A1A28）
- 护盾：纯透明冰块感，前方圆形
- 面罩：封闭式T形缝隙，红色眼光从缝中透出（#E84040 - 细1px）
- 武器：双手持大型冰锤，锤头 32×24px

## 色板

| 用途         | 颜色     |
|-------------|---------- |
| 铠甲主色     | #2A4A62  |
| 铠甲高光     | #B8D8FF  |
| 最深阴影     | #0A1A28  |
| 护盾冰蓝     | #4E7CA1（80% 不透明）|
| 护盾高光     | #B8D8FF  |
| 眼缝红光     | #E84040  |
| 轮廓线       | #2A2A33  |

---

## 动画 1：march（重甲踏步）

**帧数**：6 帧 | **FPS**：10 | **循环**：是

**完整 AI Prompt**：
```
pixel art game boss sprite sheet, 64x80px per frame, 6 frames horizontal, transparent background,
large armored ice guardian marching forward facing right,
massive armored knight with rounded ice-blue plate armor,
tall imposing figure, centered ice shield held in front (left arm),
large ice war hammer carried at side in right arm,
heavy ground-shaking walk cycle, armor plates clanking implied by slight jitter,
frame 1-2: right leg lifting, shield steady, hammer swings slightly,
frame 3: right foot planted, body weight transfer,
frame 4-5: left leg lifting, heavier shuffle, body sway 2px,
frame 6: left foot planted completing stride,
small snow settling pixels under each footfall,
blue-grey iron armor, ice blue highlights on armor edges and shield,
T-slit visor with faint red glow inside,
pixel art, #2A2A33 outline, imposing knight march
```

---

## 动画 2：spin_windup（旋转攻击蓄力）

**帧数**：4 帧 | **FPS**：10 | **循环**：否

**完整 AI Prompt**：
```
pixel art boss sprite sheet, 64x80px per frame, 4 frames horizontal, transparent background,
armored ice guardian winding up for spin attack,
frame 1: raising ice hammer with both hands, shield tucked close,
frame 2: hammer fully raised to maximum height overhead,
frame 3: beginning to spin body, feet planted, torso starting rotation,
hammer at 2 o'clock position in spin path,
frame 4: fully committed to spin, body at 90 degree rotation, hammer at 3 o'clock,
ice trail 3px behind hammer head as it begins path,
heavy metal movement, telegraphing the danger spin coming,
pixel art, #2A2A33 outline
```

---

## 动画 3：spinning（旋转中）

**帧数**：6 帧 | **FPS**：16 | **循环**：是（循环直到旋转结束）

**完整 AI Prompt**：
```
pixel art boss sprite sheet, 64x80px per frame, 6 frames horizontal, transparent background,
armored ice guardian actively spinning in place with hammer,
full body spin with hammer extended outward at arm length,
hammer at different angles each frame completing 360 degree rotation path,
frame 1-6: hammer sweeps full circle clockwise as seen from side view,
armor plates appear front-facing and back-facing in successive frames,
ice energy trail 5px wide following hammer path in #B8D8FF color,
feet staying planted but body fully rotating,
dangerous spinning zone impression, unstoppable momentum,
pixel art, #2A2A33 outline, spin attack loop
```

---

## 动画 4：slam_windup（跳跃砸地蓄力）

**帧数**：4 帧 | **FPS**：10 | **循环**：否

**完整 AI Prompt**：
```
pixel art boss sprite sheet, 64x80px per frame, 4 frames horizontal, transparent background,
armored ice guardian leaping slam attack windup,
frame 1: crouching deeply, hammer pulling back and down,
frame 2: massive jump squat, body fully compressed,
frame 3: launching upward, legs extended downward, hammer raised overhead,
leaving ground with small snow explosion at feet 6px wide,
frame 4: peak of rise, hammer at highest point, body hanging in air,
silhouette of imposing armor looming overhead with hammer ready,
pixel art, #2A2A33 outline
```

---

## 动画 5：slam_land（砸地落下）

**帧数**：4 帧 | **FPS**：14 | **循环**：否
**第 2 帧**：范围伤害判定帧（冲击波）

**完整 AI Prompt**：
```
pixel art boss sprite sheet, 64x80px per frame, 4 frames horizontal, transparent background,
armored ice guardian crashing down with hammer slam,
frame 1: falling fast, hammer leading downward, body fully extended,
frame 2 IMPACT FRAME: hammer hitting ground with enormous force,
shockwave ring 16px wide radiating outward from impact point at ground level (3 concentric arcs in #B8D8FF),
ground crack pixels: 8px of debris scatter in both directions,
body fully compressed into ground by impact,
frame 3: shockwave dissipating (fading arc pixels), body straightening from impact,
frame 4: standing upright, hammer raised slightly from rebound,
tiny ice shards settling around feet,
massive destructive impact, screen should shake (handled by code),
pixel art, #2A2A33 outline, dramatic ground slam
```

---

## 动画 6：stagger（护盾碎裂硬直）

**帧数**：5 帧 | **FPS**：8 | **循环**：否

**完整 AI Prompt**：
```
pixel art boss sprite sheet, 64x80px per frame, 5 frames horizontal, transparent background,
armored ice guardian staggering after shield destroyed,
frame 1: massive hit impact, body thrown backward 4px from force,
frame 2: shield explosion - shield shattering into 8-10 ice crystal fragments
flying outward in #B8D8FF and #4E7CA1, scattered in radial pattern,
guardian's left arm now empty and raised in confusion/pain,
frame 3: guardian reeling, legs unsteady, stumbling heavy step backward,
frame 4-5: slow recovery, straightening posture, now vulnerable without shield,
left arm now hangs at side (no shield), posture more aggressive,
this reveals the phase 2 vulnerable state - no shield exposed armor,
pixel art, #2A2A33 outline, dramatic shield break moment
```

---

## 动画 7：hurt（受击）

**帧数**：2 帧 | **FPS**：14 |  **循环**：否

**完整 AI Prompt**：
```
pixel art boss sprite sheet, 64x80px per frame, 2 frames horizontal, transparent background,
armored ice guardian taking damage hit reaction,
frame 1: full body white flash #FFFFFF, body shifted back 2px from impact force,
frame 2: color returning, armor showing fresh crack mark 2px line on chest plate,
heavy armor flinch, minimal because it's a tank boss,
crack marks accumulate - each hurt frame adds 1 more crack line to armor,
design intention: armor looks progressively more damaged at low HP,
pixel art, #2A2A33 outline
```

---

## 动画 8：dead（崩解倒地）

**帧数**：6 帧 | **FPS**：9 | **循环**：否（最后帧定格）

**完整 AI Prompt**：
```
pixel art boss sprite sheet, 64x80px per frame, 6 frames horizontal, transparent background,
armored ice guardian death sequence,
frame 1: losing balance, lurching forward, hammer tip hitting ground,
frame 2: falling to knees, massive body beginning to topple forward,
frame 3: chest plate cracking open, ice interior exposed (glowing white),
armor faceplating forward, crash imminent,
frame 4: fully fallen face-down, armor pieces scattering as separate pixels (6-8 pieces),
frame 5: ice frost spreading from beneath armor, crystallizing outward,
armor freezing solid, ice spreading 10px radius from fallen body,
frame 6 HOLD: fully frozen in fallen position, ice plate covering,
small final pixel sparkles (2-3) then still,
grandiose warrior death, powerful but defeated,
pixel art, #2A2A33 outline
```

---

## 附：护盾 Sprites（独立文件）

### shield_intact.png — 32×40px，3 帧动画（光泽循环）

**完整 AI Prompt**：
```
pixel art game object sprite, 32x40px per frame, 3 frames horizontal, transparent background,
ice shield / circular ice buckler, semi-transparent blue ice material,
concentric ring design visible through ice surface,
main color #4E7CA1 body with inherent translucency implied by lighter interior,
#B8D8FF highlight lines along upper edge and left rim,
frame 1: standard specular highlight at upper-left (2x3px bright patch),
frame 2: highlight slightly dimmed, middle of cycle,
frame 3: highlight shift slightly right, light source shift effect,
shield is healthy and intact, no cracks,
pixel art, #2A2A33 thin outline, magical ice protection item
```

### shield_broken.png — 32×40px，4 帧（破裂特效）

**完整 AI Prompt**：
```
pixel art game object sprite, 32x40px per frame, 4 frames horizontal, transparent background,
ice shield shattering destruction animation,
frame 1: large crack appearing - diagonal crack line from top to bottom, bright white crack outline,
frame 2: crack widening, 2 secondary cracks branching off, bright shatter energy in cracks #FFFFFF,
frame 3: explosive shatter - shield explodes into 7-8 angular ice shards,
each shard 2-4px, flying radially outward in #B8D8FF and #4E7CA1,
frame 4: shards dispersed, only 3 small debris pixels remaining, mostly empty space,
satisfying destruction breakup, cold ice material shattering,
pixel art, #2A2A33 outline
```

---

# ═══════════════════════════════════════════════════════════
# BOSS 3 — 雪山之王（SnowKing）
# ═══════════════════════════════════════════════════════════
# 文件：game/assets/sprites/enemies/bosses/snow_king_sheet.png
# 规格：96×96px 每帧，横向排列，共 66 帧，总图尺寸 6336×96px

## 角色外观描述

**造型定位**：最终Boss，古老雪山神王，巨大威严，兼具王族气派与自然之怒
**体型**：人形巨人，96×96px 画布（身体约 72×88px），比守卫更高
**整体配色**：纯白冰雪王者，银灰铠甲，深蓝披风，金色王冠
**细节**：
- 王冠：金色（#E8C87A），六齿，每齿末端冰晶蓝宝石
- 面部：半遮挡面甲，寒白肤色（#E8F0FF），深邃眼睛（#1A2E42），二阶段眼睛白色+红瞳
- 披风：深蓝（#1A2E42），被风吹扬，边缘有白色霜花图案
- 铠甲：银白（#E8F0FF 高光，#4E7CA1 中调），胸口雪花图案浮雕
- 武器：双手能量化，可凝聚成冰拳/暴风/冰锤（依状态变化）

## 色板（8色，预算稍宽因是最终Boss）

| 用途         | 颜色     |
|-------------|---------- |
| 铠甲高光     | #E8F0FF  |
| 铠甲中调     | #4E7CA1  |
| 铠甲深影     | #1A2E42  |
| 王冠/装饰金   | #E8C87A  |
| 披风深蓝     | #1A2E42  |（复用）
| 冰能量/法术  | #B8D8FF  |
| 爆发能量     | #FFFFFF  |
| 轮廓线       | #2A2A33  |

---

## 动画 1：idle（王者伫立）

**帧数**：4 帧 | **FPS**：7 | **循环**：是

**完整 AI Prompt**：
```
pixel art final boss sprite sheet, 96x96px per frame, 4 frames horizontal, transparent background,
Snow King ancient ruler of the mountain standing proud and still,
massive armored figure with silver-white armor, flowing dark blue cape,
golden crown six-pointed with gemstones, face partially covered by visor,
cape slowly billowing in unseen wind:
frame 1: cape in neutral flowing position,
frame 2: cape edge lifted slightly upward (wind),
frame 3: cape at maximum flow, most dramatic position,
frame 4: cape settling back toward frame 1,
slight breathing in chest plate: 1-2px expansion each other frame,
golden crown catches light with subtle glint rotation across 4 frames,
cold and commanding presence, ancient evil ruler,
palette: #E8F0FF #4E7CA1 #1A2E42 #E8C87A #B8D8FF #2A2A33,
pixel art, #2A2A33 outline, Cave Story final boss aesthetic, imposing
```

---

## 动画 2：roam（缓步巡视）

**帧数**：6 帧 | **FPS**：10 | **循环**：是

**完整 AI Prompt**：
```
pixel art final boss sprite sheet, 96x96px per frame, 6 frames horizontal, transparent background,
Snow King slowly patrolling facing right, unhurried powerful walk,
each footstep confident and heavy, body barely swaying,
cape trailing and flowing behind with each step,
6-frame slow royal walk cycle, feet visible below flowing cape,
golden crown stable on head, slight ambient glow around crown center gemstone,
arms at sides slightly,
snow crystals 2px kicked up with each footfall at ground level,
presence commanding the space, no rush needed,
silver-white armor, dark blue cape with frost trim, golden crown,
pixel art, #2A2A33 outline, final boss walk
```

---

## 动画 3：charge_windup（冲锋蓄力）

**帧数**：5 帧 | **FPS**：10 | **循环**：否

**完整 AI Prompt**：
```
pixel art final boss sprite sheet, 96x96px per frame, 5 frames horizontal, transparent background,
Snow King charging attack windup, preparing massive rush,
frame 1: body lowering slightly, weight shifting to back leg,
frame 2: deep forward crouch, one arm pulling back (power stance),
frame 3: feet digging into snow, 4-6 cracks in ground beneath feet #B8D8FF,
frame 4: massive energy build-up: blue-white aura 4px radiating from entire body,
snow flying up around feet, crown glowing brighter,
frame 5: final charge coil, body at lowest point, everything screaming about to GO,
cape pressed back against body from force, maximum tension,
telegraphed and clearly readable dangerous move coming,
pixel art, #2A2A33 outline
```

---

## 动画 4：charging（冲锋中）

**帧数**：4 帧 | **FPS**：16 | **循环**：是（循环直到冲锋结束）

**完整 AI Prompt**：
```
pixel art final boss sprite sheet, 96x96px per frame, 4 frames horizontal, transparent background,
Snow King charging at extreme speed facing right,
body leaned 45 degrees forward, crown leading charge,
legs cycling in powerful run, cape fully horizontal behind from speed,
massive speed line aura: 8-10 horizontal lines 6px long trailing behind body in #B8D8FF,
ground snow being kicked up continuously (4px trail of snow pixels behind feet),
body slightly blurred impression from speed (2px duplicate ghost offset behind),
unstoppable momentum, dangerous and relentless,
loop of 4 frames with slight leg variation to maintain run cycle illusion,
pixel art, #2A2A33 outline, speed lines final boss charge
```

---

## 动画 5：charge_stop（急停扬雪）

**帧数**：4 帧 | **FPS**：12 | **循环**：否

**完整 AI Prompt**：
```
pixel art final boss sprite sheet, 96x96px per frame, 4 frames horizontal, transparent background,
Snow King skidding to halt after charge,
frame 1: still charging speed, foot planting for stop,
frame 2: both feet planted, body lurching forward from momentum, cape swinging forward,
large snow burst 12px wide at feet from sudden stop,
frame 3: body recovering backward, snow settling, cape falling back,
frame 4: full stop, standing straight, snow still drifting, crown slightly askew then correcting,
satisfying momentum stop, weight and power conveyed,
pixel art, #2A2A33 outline
```

---

## 动画 6：slam_windup（跳升蓄力）与 slam_air（腾空）

**slam_windup**：5 帧，10fps | **slam_air**：3 帧，12fps，**循环**：否

**完整 AI Prompt（slam_windup + slam_air 合并生成）**：
```
pixel art final boss sprite sheet, 96x96px per frame, 8 frames horizontal, transparent background,
Snow King massive ground slam in two phases:
WINDUP (frames 1-5):
frame 1: crouching down, cape spreading wide,
frame 2: coiling into deep squat, arms pulling back, tremendous compression,
frame 3-4: arms gathering blue-white energy into fists, particles swirling around hands,
both fists now glowing bright #B8D8FF with concentrated power,
frame 5: launching upward off ground, jump squat releasing,
AIR (frames 6-8):
frame 6: rising, arms raised, energy orbs on fists leaving light trails upward,
frame 7: peak hang time, body fully spread, fists overhead like a hammer,
frame 8: beginning rapid descent, fists pointing downward at target,
cape billowing in all directions during flight,
pixel art, #2A2A33 outline
```

---

## 动画 7：slam_land（砸地冲击）

**帧数**：5 帧 | **FPS**：13 | **循环**：否
**第 3 帧**：范围伤害判定

**完整 AI Prompt**：
```
pixel art final boss sprite sheet, 96x96px per frame, 5 frames horizontal, transparent background,
Snow King landing with devastating ground slam,
frame 1-2: falling fast, fists straight down, cape up, terminal velocity,
frame 3 IMPACT: fists hitting ground, massive explosion at impact point,
shockwave ring 24px wide radiating in #B8D8FF (3 concentric arcs getting lighter),
ground impact debris: 10-12 ice fragment pixels scattered to both sides,
full body squash on impact, cape explodes outward from shockwave,
frame 4: shockwave dissipating, body rising from squat, debris still airborne,
frame 5: standing, crown steady, arms lowering, debris settling around feet,
most powerful slam in the game, designed to be screen-shaking,
pixel art, #2A2A33 outline, final boss ultimate slam
```

---

## 动画 8：blizzard_cast（暴风雪召唤）

**帧数**：6 帧 | **FPS**：12 | **循环**：否

**完整 AI Prompt**：
```
pixel art final boss sprite sheet, 96x96px per frame, 6 frames horizontal, transparent background,
Snow King casting blizzard spell, raising both arms to the sky,
frame 1: arms beginning to rise from sides,
frame 2: arms at shoulder height, blue particles starting to gather above head,
frame 3: arms fully raised overhead, 6-8 ice particle cluster above hands (snowflake shapes),
frame 4: magical circle forming: circular rune pattern 20px diameter above raised arms in #B8D8FF,
frame 5: blizzard activating, rune shattering outward into 5 projectile directions (spread fan),
bright flash moment, snow vortex particles 6px around arms,
frame 6: arms lowering post-cast, trail of snowflakes still drifting,
regal magical attack, cold overwhelming power, ancient spellcasting aesthetic,
pixel art, #2A2A33 outline
```

---

## 动画 9：wind_burst（气流爆发）

**帧数**：5 帧 | **FPS**：15 | **循环**：否

**完整 AI Prompt**：
```
pixel art final boss sprite sheet, 96x96px per frame, 5 frames horizontal, transparent background,
Snow King wind burst knockback attack facing right,
frame 1: inhaling, chest expanding, arms pulling back,
frame 2: full chest puff, arms at maximum drawback, wind particles gathering in front,
frame 3 BURST: single powerful arm thrust forward, massive wind release,
horizontal blast fan: 14px wide burst lines extending right from outstretched hand,
#B8D8FF wind gust lines 6-8 horizontal streaks,
frame 4: blast still expanding, arm fully extended, cape blowing back hard from force,
frame 5: arm lowering, wind settling into trailing particles,
forceful knockback attack, creates dangerous push zone,
pixel art, #2A2A33 outline
```

---

## 动画 10：phase2_rage（二阶段狂怒觉醒）

**帧数**：8 帧 | **FPS**：8 | **循环**：否

**完整 AI Prompt**：
```
pixel art final boss sprite sheet, 96x96px per frame, 8 frames horizontal, transparent background,
Snow King phase 2 rage awakening cutscene-like animation,
frame 1: one knee drops, clearly wounded, head lowered, cape settling,
frame 2: head slowly raising, crown cracked but still on (crack line on crown),
frame 3: eyes changing - now white iris with red pupils piercing glow,
red light #E84040 emitting from eye slits,
frame 4: slowly rising from knee, arms spread wide, power building,
frame 5: standing fully, massive blue-white energy aura exploding from body
(12px radius energy halo in #B8D8FF), snow avalanche begins from peaks above,
frame 6: armor cracking to reveal ice energy underneath (3-4 crack lines glowing #FFFFFF),
frame 7: full rage posture - cape shredding at edges into wind, crown cracked further,
pure wild energy emanating, completely changed from regal to wrathful,
frame 8: locked into rage stance, ready, terrifying,
most dramatic moment in the game, must convey the tone shift from ruler to pure force,
pixel art, #2A2A33 outline, climactic final boss phase 2
```

---

## 动画 11：hurt（受击）

**帧数**：2 帧 | **FPS**：14 | **循环**：否

**完整 AI Prompt**：
```
pixel art final boss sprite sheet, 96x96px per frame, 2 frames horizontal, transparent background,
Snow King taking hit damage, brief reaction,
frame 1: white flash entire body #FFFFFF, head snapping back slightly from force,
crown shifting momentarily, damage particles #E84040 4-5 pixel burst from impact,
frame 2: recovering, head returning, crown restoring,
even in phase 2: reaction is minimal, a king does not flinch much,
but crack accumulating on armor surface after many hits is acceptable design detail,
pixel art, #2A2A33 outline
```

---

## 动画 12：dead（最终死亡 三段式）

**帧数**：9 帧 | **FPS**：8 | **循环**：否（最后帧定格）

**完整 AI Prompt**：
```
pixel art final boss sprite sheet, 96x96px per frame, 9 frames horizontal, transparent background,
Snow King final death animation in three distinct phases (kneel, freeze, shatter):
PHASE A - KNEEL (frames 1-3):
frame 1: staggering, one arm dropping to ground for support, head bowing,
frame 2: both knees touching down, crown falling slowly from head (separate trajectory),
frame 3: fully kneeling, arm supporting on ground, head hanging, cape draped around,
PHASE B - FREEZE (frames 4-6):
frame 4: ice crystallization beginning at feet, creeping upward as visible color change to deep ice blue,
frame 5: ice encasement reaching torso, arm now frozen in support position,
frame 6: full body encased in ice, crown also frozen beside body,
all features preserved but entirely blue-white ice now,
PHASE C - SHATTER (frames 7-9):
frame 7: single crack line appearing across ice statue,
frame 8: multiple cracks branching, bright white light #FFFFFF emanating from cracks,
frame 9 HOLD: explosion of ice fragments (12-15 pieces in #B8D8FF and #4E7CA1),
scattered across full 96px canvas, beautiful crystalline finale,
then background to empty scattered fragments,
most dramatic death in the game, worthy of a final boss, bittersweet and powerful,
pixel art, #2A2A33 outline, emotional and epic
```

---

## 生成建议

**生成顺序推荐**：
1. `snow_king` idle 建立外观 → 用作所有后续参考图
2. `ice_lynx` idle 建立猫科外观 → 再做各攻击动画
3. `frozen_guard` march 建立重甲外观 → 护盾作为独立生成
4. Boss 死亡动画最复杂，建议逐帧手调
5. phase2 变化帧建议与 idle 做对比进行风格一致性检查
