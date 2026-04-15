# Phase 1 测试 — 最小美术集快速生成指南
# 目标：生成 2 张 PNG → 接入 Godot → 可视化测试游戏基础流程
# 预计时间：生成约 30min，Godot 接入约 20min

---

## 需要生成的文件（共 2 张）

| 优先级 | 文件                            | 尺寸         | 帧数 | 用途                   |
|------|--------------------------------|-------------|------|------------------------|
| 1    | sprites/player/player_sheet.png | 336×48px    | 7帧  | 玩家角色 idle+run+ski+attack+hurt+dead |
| 2    | sprites/enemies/snowman_sheet.png | 128×48px  | 4帧  | 雪人兵 walk+attack+hurt+dead           |

> 说明：TestMap 地形目前用几何碰撞体（StaticBody2D），暂不需要瓦片贴图。
> UI 占位符由 ColorRect 实现，暂时够用。

---

# ═══════════════════════════════════════════════════════
# 图 1：player_sheet.png
# 336×48px（7帧 × 48px，横向排列）
# ═══════════════════════════════════════════════════════

## 帧序表（左到右顺序）

| 帧编号 | 帧含义   | 动画名（Godot AnimationPlayer 用）|
|--------|---------|-----------------------------------|
| 0      | idle    | "idle"                            |
| 1      | run     | "run"                             |
| 2      | ski     | "ski"                             |
| 3      | attack  | "attack"                          |
| 4      | hurt    | "hurt"                            |
| 5      | dead    | "dead"                            |
| 6      | jump    | "jump"                            |

## AI Prompt（直接复制使用）

```
pixel art game character sprite sheet,
7 frames total in a single horizontal row, 48x48px per frame, total 336x48px,
transparent PNG background, no antialiasing, hard pixel edges,
young girl ski knight character, side view facing right,
blue-white ski suit, round ice-blue helmet, warm golden ski goggles,
ice short sword in right hand, dark outline #2A2A33,
palette: #B8D8FF #4E7CA1 #1A2E42 #E8C87A #FFFFFF #2A2A33,

frame 0 (idle): standing relaxed, sword at hip, weight balanced,
frame 1 (run): mid-stride, right foot forward, arms pumping, leaning forward slightly,
frame 2 (ski): aerodynamic crouch, body leaning 30 degrees forward, arms back, no foot movement,
frame 3 (attack): sword extended forward horizontal at chest height, arm fully extended right,
blue-white slash arc 3px in front of sword tip,
frame 4 (hurt): body jolted back 3px, arms thrown back, white flash impression,
2 red hit sparks #E84040 near torso,
frame 5 (dead): lying flat horizontal, sword dropped, eyes closed,
frame 6 (jump): body in air, knees bent up, sword held overhead,

each frame clearly shows a distinct readable pose with good silhouette,
pixel art, Cave Story character style, 2D platformer sprite sheet
```

---

# ═══════════════════════════════════════════════════════
# 图 2：snowman_sheet.png
# 128×48px（4帧 × 32px 宽，横向排列）
# ═══════════════════════════════════════════════════════

## 帧序表

| 帧编号 | 帧含义  | 动画名     |
|--------|--------|-----------|
| 0      | walk   | "walk"    |
| 1      | attack | "attack"  |
| 2      | hurt   | "hurt"    |
| 3      | dead   | "dead"    |

## AI Prompt（直接复制使用）

```
pixel art game enemy sprite sheet,
4 frames in a single horizontal row, 32x48px per frame, total 128x48px,
transparent PNG background, no antialiasing, hard pixel edges,
snowman soldier enemy, round white snow body (two snowballs stacked),
dark blue military cap with brim, orange carrot nose, black button eyes,
holding ice club weapon in right twig arm, facing right,
palette: #E8F0FF #8AAED0 #1A2E42 #FF7030 #2A2A33,

frame 0 (walk): one foot forward in waddling pose, body upright, weapon at side,
frame 1 (attack): ice club raised and swung forward, body leaning into strike,
frame 2 (hurt): body flashing white #FFFFFF, shifted back 2px, carrot askew,
frame 3 (dead): melting into snow pile, shape collapsed downward, buttons scattered,

cute but menacing cartoon snowman, pixel art, Cave Story enemy style
```

---

# ═══════════════════════════════════════════════════════
# Godot 接入步骤（图片生成后按此操作）
# ═══════════════════════════════════════════════════════

## 步骤 1：导入设置

1. 将生成的 PNG 放入对应目录：
   - `game/assets/sprites/player/player_sheet.png`
   - `game/assets/sprites/enemies/snowman_sheet.png`
2. 在 Godot FileSystem 中找到这两个文件
3. 右键 → Import... → 确保以下设置：
   - **Compress Mode**: Lossless
   - **Filter**: **Nearest**（重要！保持像素锐利）
4. 点击 Reimport

---

## 步骤 2：设置 Player.tscn

1. 打开 `scenes/player/Player.tscn`
2. 选中 `Sprite2D` 节点：
   - `Texture` → 拖入 `player_sheet.png`
   - `Hframes` → 设为 **7**
   - `Vframes` → 设为 **1**
   - `Frame` → 初始值 0（idle 帧）
3. 在 Player.tscn 中**添加 AnimationPlayer 节点**（Add Child Node → AnimationPlayer）
4. 在 AnimationPlayer 中创建以下动画（每个动画只需 1 个轨道：Sprite2D.frame 的 IntTrack）：

| 动画名  | Sprite2D.frame 值 | 时长    | 循环  |
|--------|------------------|--------|-------|
| idle   | 0                | 0.5s   | ✓    |
| run    | 1                | 0.1s   | ✓    |
| ski    | 2                | 0.1s   | ✓    |
| attack | 3                | 0.3s   | ✗    |
| hurt   | 4                | 0.2s   | ✗    |
| dead   | 5                | 0.5s   | ✗    |
| jump   | 6                | 0.1s   | ✓    |

> 注意：此阶段每个动画只有 1 帧（`Hframes=7` 中各取一帧），后续替换完整 spritesheet 时再扩充帧数。

---

## 步骤 3：设置 SnowmanSoldier.tscn

1. 打开 `scenes/enemies/SnowmanSoldier.tscn`
2. 选中 `Sprite2D` 节点：
   - `Texture` → 拖入 `snowman_sheet.png`
   - `Hframes` → **4**
   - `Vframes` → **1**
3. 添加 `AnimationPlayer` 节点，创建 4 个动画（同上方式）：

| 动画名  | Sprite2D.frame | 时长   | 循环 |
|--------|----------------|--------|------|
| walk   | 0              | 0.4s   | ✓   |
| attack | 1              | 0.3s   | ✗   |
| hurt   | 2              | 0.15s  | ✗   |
| dead   | 3              | 0.5s   | ✗   |

4. 在 `scripts/enemies/SnowmanSoldier.gd` 中添加 AnimationPlayer 驱动（代码已预留 _update_sprite 钩子）

---

## 步骤 4：SnowmanSoldier.gd 接入动画（代码修改）

在 SnowmanSoldier.gd 的 `_ready()` 中添加获取 AnimationPlayer 的逻辑，并在各状态切换处播放对应动画。具体接入在你把图导入后我可以帮你写这段代码。

---

## 验证清单

- [ ] 运行游戏，玩家可见（不再是空白/红色矩形）
- [ ] 玩家移动时切换 run/ski 动画姿态
- [ ] 按攻击键播放 attack 帧
- [ ] 受伤闪白后回到 idle
- [ ] 雪人兵可见，行走显示 walk 帧
- [ ] 击中雪人兵显示 hurt 帧，死亡显示 dead 帧

---

## 完成后下一批（Phase 2 美术）

| 文件                                  | 详细 prompt 位置        |
|--------------------------------------|------------------------|
| sprites/enemies/turret_sheet.png     | 02_enemies_normal.md §3.2 |
| sprites/enemies/iceball_sheet.png    | 02_enemies_normal.md §弹丸 |
| sprites/ui/hp_icon.png               | 05_ui_and_icons.md §1.1 |
| sprites/ui/exp_icon.png              | 05_ui_and_icons.md §1.2 |
| tilemaps/snow_entrance_tileset.png   | 04_tilesets.md §Tileset 1 |
