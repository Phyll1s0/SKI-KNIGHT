# 玩家角色 Spritesheet 生成指南
# 文件：game/assets/sprites/player/player_sheet.png
# 规格：48×48px 每帧，横向排列，共 44 帧，总图尺寸 2112×48px

---

## 角色外观描述（所有动画共用）

**角色定位**：青少年滑雪骑士，轻盈矫捷，充满冒险感
**整体配色**：蓝白主色调滑雪服，暖金护目镜镜片作为视觉焦点
**服装细节**：
- 头部：圆顶冰蓝滑雪头盔（#4E7CA1 主色，#B8D8FF 高光），白色颈巾
- 眼部：护目镜，镜片 #E8C87A 暖金，外框 #2A2A33
- 上身：冰蓝连体滑雪服，胸口有白色三角 logo
- 手：白色连指手套，持有冰制短剑（剑身 #B8D8FF，剑柄 #1A2E42）
- 下身：深蓝滑雪裤，腿侧有白色条纹
- 脚：黑色滑雪靴（#1A2E42），固定在雪板上时可见雪板蓝色板面

---

## 基础 AI Prompt（每个动画 prompt 开头必须包含此段）

```
pixel art game sprite sheet, 48x48px per frame, transparent background,
no antialiasing, hard pixel edges, side view 2D platformer,
young ski knight character, blue-white ski suit, golden ski goggles,
ice sword in right hand, dark blue outline #2A2A33, limited 6-color palette:
#B8D8FF #4E7CA1 #1A2E42 #E8C87A #FFFFFF #2A2A33,
Cave Story character style, cold winter theme,
```

---

## 动画 1：idle（站立呼吸）

**文件位置**：spritesheet 第 0 列起，共 4 帧（合计 192×48px）
**FPS**：8，**循环**：是

**动作描述**：
角色直立站立，双腿微开同肩宽，冰剑收于腰侧斜向下握持。
每隔约 0.5 秒做一次轻微呼吸：胸口上下浮动 2px，肩膀随之微微抬落。
第3帧眼镜镜片有一个微弱的光泽闪烁（高光点 1px 明亮→暗）。

**完整 AI Prompt**：
```
pixel art game sprite sheet, 48x48px per frame, 4 frames horizontal layout,
transparent background, no antialiasing,
young ski knight standing idle, relaxed pose, breathing animation,
blue-white ski suit, golden goggles with lens glint on frame 3,
ice short sword held loosely at hip pointing downward,
frame 1: neutral standing, frame 2: chest slightly raised 2px,
frame 3: chest fully raised goggles glint visible, frame 4: chest returning down,
subtle life in the character, feet together, weight balanced,
dark #2A2A33 outline 2px, palette: #B8D8FF #4E7CA1 #1A2E42 #E8C87A #FFFFFF,
pixel art platformer style, Cave Story aesthetic
```

**逐帧说明**：
- Frame 1：标准站姿，基准帧，头部在 Y=6
- Frame 2：胸部上移 1px，肩膀略抬，剑尖微翘
- Frame 3：胸部上移 2px（最高点），护目镜右侧 1px 白色高光亮起
- Frame 4：胸部回落 1px，护目镜高光消失，接回 Frame 1

---

## 动画 2：run（地面跑步）

**文件位置**：spritesheet 第 4 列起，共 6 帧（合计 288×48px）
**FPS**：12，**循环**：是

**动作描述**：
面朝右方的快跑动作，步频较高，双臂前后摆动，冰剑在右手随摆动。
脚掌在接触地面时有轻微压缩（腿微弯），腾空瞬间身体拉长。
适度的卡通夸张感，不要写实跑步。

**完整 AI Prompt**：
```
pixel art game sprite sheet, 48x48px per frame, 6 frames horizontal,
transparent background, young ski knight running fast facing right,
arms pumping front and back, ice sword in right hand swinging with arm,
frame 1: left foot forward right foot back, frame 2: both feet near together airborne,
frame 3: right foot forward left foot back, frame 4: weight on right foot knee bent,
frame 5: both feet near together second airborne, frame 6: left foot strikes ground knee bent,
slight body lean forward 10 degrees, energetic run cycle,
blue-white ski suit lines follow body motion, goggles glint steady,
pixel art, dark #2A2A33 outline, palette: #B8D8FF #4E7CA1 #1A2E42 #E8C87A #FFFFFF,
Cave Story style, 2D platformer sprite
```

**逐帧说明**：
- Frame 1：左脚前蹬，右脚后踢，右臂前摆（剑向前）
- Frame 2：双脚离地腾空，身体略压缩
- Frame 3：右脚前蹬，左脚后踢，左臂前摆
- Frame 4：右脚着地，膝盖弯曲，重心偏低 2px
- Frame 5：再次腾空
- Frame 6：左脚着地缓冲

---

## 动画 3：ski（高速滑雪）

**文件位置**：spritesheet 第 10 列起，共 6 帧（合计 288×48px）
**FPS**：14，**循环**：是

**动作描述**：
雪板贴地高速滑行姿势，上身前倾约 30°，双膝微弯吸收地形起伏。
双臂后展，冰剑指向后方，雪板可见（脚下蓝色细长板）。
身体重心低，每 2~3 帧有 1px 上下弹动（模拟雪面不平）。
速度感：服装在身后有 2px 的"速度线"尾迹残影（用高亮色 #B8D8FF）。

**完整 AI Prompt**：
```
pixel art game sprite sheet, 48x48px per frame, 6 frames horizontal,
transparent background, young ski knight skiing at high speed facing right,
body leaned forward 30 degrees aerodynamic racing crouch,
knees bent, arms swept back, ice sword pointing backward,
blue ski board visible under both feet, slight snow spray pixels at board edge,
speed lines 2px trailing from back of character in #B8D8FF color,
body bobs up and down 1-2px between frames for terrain bounce feel,
frame 1-2: body compressed low, frame 3-4: slight upward float,
frame 5-6: compressed again as board hits surface,
blue-white ski suit with motion feel, goggles with wind impression,
pixel art, #2A2A33 outline, palette: #B8D8FF #4E7CA1 #1A2E42 #E8C87A #FFFFFF,
Cave Story style, cold winter 2D platformer sprite
```

---

## 动画 4：jump_rise（起跳+上升）

**文件位置**：spritesheet 第 16 列起，共 3 帧
**FPS**：10，**循环**：否（播放一次）

**完整 AI Prompt**：
```
pixel art game sprite sheet, 48x48px per frame, 3 frames horizontal,
transparent background, young ski knight jumping upward facing right,
frame 1 ANTICIPATION: body squished down 3px, knees deeply bent, arm pulled back, loading energy,
frame 2 LAUNCH: body fully extended upward, legs straight, arms thrown up, character stretched 3px taller,
frame 3 RISING: body in mid-air tucked position, knees slightly bent, sword raised overhead,
squash and stretch exaggeration, clear silhouette at each frame,
ice sword catching light as it rises, snow particles 4px below feet on frame 2 (kick-off),
blue-white ski suit, golden goggles, pixel art, #2A2A33 outline, Cave Story style
```

---

## 动画 5：jump_fall（下落）

**文件位置**：spritesheet 第 19 列起，共 2 帧
**FPS**：8，**循环**：是（循环直到落地）

**完整 AI Prompt**：
```
pixel art game sprite sheet, 48x48px per frame, 2 frames horizontal,
transparent background, young ski knight falling downward facing right,
frame 1: body slightly spread, arms out for balance, legs bent below,
sword pointing downward at angle, looking down, cape if any flowing upward,
frame 2: body more tucked, speed slightly compressed vertically,
sense of downward momentum, hair/scarf flowing upward,
2 small white pixel wind lines above character head indicating speed,
blue-white ski suit, golden goggles, pixel art, #2A2A33 outline
```

---

## 动画 6：land（落地缓冲）

**文件位置**：spritesheet 第 21 列起，共 2 帧
**FPS**：12，**循环**：否（播放一次后接 idle/run）

**完整 AI Prompt**：
```
pixel art game sprite sheet, 48x48px per frame, 2 frames horizontal,
transparent background, young ski knight landing from jump facing right,
frame 1: impact moment - body fully squashed 4px shorter, knees deeply bent to floor,
arms low and wide for balance, snow burst particles 6px wide on each side of feet (4 white pixels),
frame 2: body recovering upward, knees straightening, small dust settling (2px particles near feet),
classic landing squash-stretch, exaggerated cartoon impact,
blue-white ski suit, golden goggles, pixel art, #2A2A33 outline, Cave Story style
```

---

## 动画 7：attack（站立攻击）

**文件位置**：spritesheet 第 23 列起，共 5 帧
**FPS**：18，**循环**：否

**动作描述**：
横向冰剑斩击。蓄力→挥出→判定→收势。
第 3 帧为判定帧（代码触发伤害），此帧剑身应处于最前方，并有 3px 蓝白色弧形特效。

**完整 AI Prompt**：
```
pixel art game sprite sheet, 48x48px per frame, 5 frames horizontal,
transparent background, young ski knight sword attack facing right,
frame 1 WINDUP: right arm pulled back behind head, body twisted left, weight on back foot,
ice short sword raised behind shoulder, single white motion line behind sword,
frame 2 SWING START: arm beginning forward swing, body rotating right, sword starting arc,
frame 3 HIT FRAME: arm fully extended forward, sword horizontal at chest height,
3px arc of blue-white slash effect #B8D8FF trailing behind blade,
body leaned into strike, this is the damage frame,
frame 4 FOLLOW THROUGH: sword past center continuing right, body overextended slightly,
frame 5 RECOVERY: arm lowering, body returning to neutral stance, sword back to hip,
ice sword #B8D8FF blade with #FFFFFF edge highlight, cold magic slash trail,
blue-white ski suit, golden goggles, pixel art, #2A2A33 outline, Cave Story style attack animation
```

---

## 动画 8：ski_attack（滑行中攻击）

**文件位置**：spritesheet 第 28 列起，共 4 帧
**FPS**：16，**循环**：否

**完整 AI Prompt**：
```
pixel art game sprite sheet, 48x48px per frame, 4 frames horizontal,
transparent background, young ski knight attack while skiing at speed facing right,
character maintains forward-leaning ski posture throughout,
frame 1: low ski crouch, sword pulled back while still leaning forward,
frame 2: sword thrust forward horizontally from the crouch position, impact frame,
blue-white slash arc in front of sword tip, feet still on ski board,
frame 3: sword extended held at height, momentum carrying forward,
frame 4: sword returning to hip, ski posture restored, snow spray at board,
combo of skiing speed momentum and quick sword strike, dynamic and aggressive,
blue-white ski suit, golden goggles, blue ski board, pixel art, #2A2A33 outline
```

---

## 动画 9：skill_cast（冰刃技能释放）

**文件位置**：spritesheet 第 32 列起，共 4 帧
**FPS**：14，**循环**：否

**动作描述**：
举起冰剑，剑身发光→向前投出冰刃能量弹。
第 2 帧剑身最亮（生成冰刃弹丸的时机）。

**完整 AI Prompt**：
```
pixel art game sprite sheet, 48x48px per frame, 4 frames horizontal,
transparent background, young ski knight casting ice blade skill facing right,
frame 1: sword raised overhead both hands gripping, magical ice glow starting on blade,
small #B8D8FF sparkle pixels around sword (4-6 pixels),
frame 2 CAST FRAME: sword fully charged, blade glowing bright white #FFFFFF,
6-8 bright ice pixel particles around blade, this is where projectile spawns,
frame 3: sword thrust forward, bright ice energy leaves blade as projectile shape,
energy trail 5px long in #B8D8FF behind thrown projectile position,
frame 4: sword lowering, small remaining sparkles dissipating, return to ready stance,
magical ice ability feel, cold blue energy, not fire,
blue-white ski suit, golden goggles, pixel art, #2A2A33 outline, Cave Story magic attack
```

---

## 动画 10：hurt（受击）

**文件位置**：spritesheet 第 36 列起，共 3 帧
**FPS**：14，**循环**：否

**完整 AI Prompt**：
```
pixel art game sprite sheet, 48x48px per frame, 3 frames horizontal,
transparent background, young ski knight taking damage facing right,
frame 1 IMPACT: character hit from right side, body jerking left,
white flash overlay on character (all non-outline pixels briefly white #FFFFFF),
small red hit particles #E84040 3-4 pixels flying from impact point,
frame 2: body leaning backward in pain, arms thrown back, wincing expression,
character slightly shifted left 3px from impact force,
frame 3: character straightening, returning to position, red particles settling,
pain/damage reaction, brief involuntary movement,
blue-white ski suit, golden goggles, pixel art, #2A2A33 outline, invincibility flash implied
```

---

## 动画 11：dead（死亡）

**文件位置**：spritesheet 第 39 列起，共 5 帧
**FPS**：10，**循环**：否（最后一帧定格）

**完整 AI Prompt**：
```
pixel art game sprite sheet, 48x48px per frame, 5 frames horizontal,
transparent background, young ski knight death animation facing right,
frame 1: staggering backward, sword dropping from hand, legs giving way,
frame 2: beginning to fall, body tilting backward, sword hitting ground,
arms spread wide catching air, eyes closed/X expression,
frame 3: halfway fallen, torso at 45 degree angle, nearly horizontal,
frame 4: fully collapsed on ground, lying flat, arms at sides,
frame 5 HOLD: same as frame 4 but with 4-5 small snowflake pixels drifting up from body,
somber farewell pose, character at peace, not gory,
blue-white ski suit faded slightly on last frame, golden goggles still on,
pixel art, #2A2A33 outline, Cave Story death style, emotional not violent
```

---

## 단独 Sprite：冰刃弹丸（skill projectile）

**文件**：`game/assets/sprites/player/ice_blade_projectile.png`
**规格**：32×16px，4 帧动画（飞行旋转），单行排列

**完整 AI Prompt**：
```
pixel art game sprite sheet, 32x16px canvas per frame, 4 frames horizontal,
transparent background, flying ice blade projectile,
crescent moon shaped blade made of solid ice,
colors: #B8D8FF body, #FFFFFF sharp edge highlight, #4E7CA1 mid section, #2A2A33 outline,
frame 1: blade angled 0 degrees, flat horizontal flying right,
frame 2: blade angled 15 degrees, slight rotation,
frame 3: blade angled 30 degrees continuing spin,
frame 4: blade angled 45 degrees, full spin cycle,
small 2-3 pixel ice dust trail on left side of blade (behind it),
cold sharp magical feel, compact and readable at small size,
pixel art, Cave Story projectile style
```

---

## 生成建议

1. **分批生成**：先生成 idle 确认风格，再生成其余动画确保一致性
2. **固定种子**：在 AI 工具中记录首次满意结果的随机种子（seed），后续动画使用同一角色外观参考图
3. **参考图**：生成后续动画时，将已生成的 idle 图片作为角色参考输入（IP Adapter / image reference）
4. **验证**：将 spritesheet 导入 Godot，设置 AnimationPlayer 各帧时检查：
   - Sprite2D → Hframes = 帧数，Vframes = 1
   - 各 Animation 的 SpriteFrames track 帧序号是否正确
