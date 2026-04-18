# Tapistry iso pixel art guide

Convention and workflow for drawing 32×32 iso pixel-art sprites that sit
naturally on the Tapistry grass block. Applies to `BuildingPixelView.swift`
sprites and their rendering in `VillageGridView.swift`.

---

## 1. The iso grid

Tapistry uses **2:1 isometric** projection (a.k.a. dimetric). Every edge on
the grass block — top-face diamond edges and the side-face top edges — runs
at slope **±0.5**: 2 screen pixels horizontal per 1 screen pixel vertical.

### Direction naming convention (global)

Use the same direction terms for both a full block cell and a sub-cell.

| Korean term | Canonical edge |
|---|---|
| 앞쪽 | 남동쪽변 (SE edge) |
| 뒤쪽 | 북서쪽변 (NW edge) |
| 왼쪽 | 남서쪽변 (SW edge) |
| 오른쪽 | 북동쪽변 (NE edge) |

Do not switch naming by context. One vocabulary only.

| Slope | Direction on screen | Matches block edge |
|---|---|---|
| `+0.5` | down-right (or up-left) | SW face top edge (left, lighter brown) |
| `-0.5` | up-right (or down-left) | SE face top edge (right, darker brown) |

Sprites that *don't* follow this slope look bolted on rather than set into
the scene.

---

## 2. 9-point geometry framework

Every building is abstracted into 9 key points:

```
             Peak                    ← roof apex (1 point)
              /│\
             / │ \
           NW'  NE'                  ← wall top (4 corners)
          /│\  /│\
         / │ \/ │ \
       SW' │ /\ │ SE'
        \  │/  \│  /
         \ NW  NE /
          \/    \/                   ← wall base / ground footprint (4 corners)
          SW   SE
```

- **Ground diamond** (4 corners): the building's footprint where it meets
  the ground. All four edges slope ±0.5.
- **Top diamond** (4 corners): where walls meet roof. Same shape as ground
  diamond, just raised by wall height `H`.
- **Peak**: roof apex above the top diamond's center.

Because ground and top diamonds share the same shape, every wall is a
**parallelogram** (not a trapezoid).

### Peak placement

For the visible outer roof edges to have slope ±0.5:

```
peak_x ≈ 18.5   (for a sprite with seam around col 12-13)
peak_y ≈ 15.75 - H   where H = wall height in rows
```

Round to integer pixels. The result is usually close but not exactly ±0.5
on both sides when the building isn't a perfect square in 3D — the axis
with the longer span will be slightly off. Pick the more visible side to
match exactly.

---

## 3. Color / character convention

Standard characters used in sprite rows (match keys in the `colors:` dict):

| Char | Meaning | Typical SpriteColors entry |
|---|---|---|
| `R` | 앞쪽벽(SE면) roof (brighter) | `roof` |
| `r` | 왼쪽벽(SW면) roof (shadowed) | `roofDark` |
| `W` | 앞쪽벽(SE면) wall trim / top edge | `wallDark` |
| `n` | 앞쪽벽(SE면) wall body | `wall` |
| `E` | 왼쪽벽(SW면) wall trim / top edge | `plankDark` |
| `e` | 왼쪽벽(SW면) wall body | `wallDark` |
| `X` / `x` | Window | `window` / `windowDark` |
| `D` / `d` / `h` | Door / frame / knob | `door` / `doorLight` / `shopSign` |
| `C` / `c` | Chimney body / cap shadow | `chimney` / `chimneyDark` |
| `K` | Base / foundation trim | `plankDark` |
| `P` / `p` | Wood plank / shadow | `plank` / `plankDark` |
| `.` | Empty / sky | (not rendered) |

앞쪽벽(SE면) brightness > 왼쪽벽(SW면) brightness로 유지.
SE 카메라 기준 앞쪽이 밝고 왼쪽이 그림자.

---

## 4. Step-by-step workflow

When converting a flat sprite into iso, go in this order. Build, render,
and commit after each step so you can revert cleanly.

1. **Pick the 9 points**. Sketch ground diamond, top diamond, peak on
   graph paper or a throwaway render. Verify every edge is ±0.5.
2. **Slope the wall bottoms**. 앞쪽벽(SE면) base should slope -0.5 from
   seam to outer-SW; 왼쪽벽(SW면) base should slope +0.5 from seam to
   outer-NE.
3. **Slope the wall tops**. Match the same ±0.5 slopes so the wall
   becomes a proper parallelogram, and both walls share the same
   top-row at the seam.
4. **Place the peak**. Use the formula above. Draw the single peak
   pixel.
5. **Fill the roof**. Two triangles (왼쪽/SW slope and 앞쪽/SE slope) sharing the
   peak-to-seam-top edge. 왼쪽 uses `r`, 앞쪽 uses `R`. Let the eave
   overhang the wall outer corners if pure triangle geometry leaves
   gaps (a 1–2 column overhang at the eave row is acceptable).
6. **Fill the walls**. Use `W`/`E` for outer and top trim, `n`/`e` for
   body. Seam column (col 12 왼쪽 / col 13 앞쪽 for our standard) gets
   trim on both sides.
7. **Add door and windows**. Keep them small — at `subObjectSize /
   32 ≈ 0.75pt` per pixel, 3-wide windows and 3-4-wide doors are about
   the limit for readable details. Place door reaching the wall base;
   windows above door level.
8. **Add chimney** (optional). Place so its base emerges from a roof
   slope, not floating in sky.
9. **Set `spriteBaselineRows`** in `VillageGridView.swift`. Value =
   number of trailing empty rows at the bottom of the 32×32 grid. The
   renderer uses this to compensate so the *visual* bottom (not the
   bounding-box bottom) lands on the sub-cell anchor.
10. **Disable shear** for the sprite. Add the building's id to the
    `case "<id>": return 0` branch in `isoShearY(for:)`. The SwiftUI
    shear transform is meant for flat sprites; iso-native sprites
    already bake perspective into the pixels and must not be sheared
    again.
11. **Check for overflow**. Render the sprite in-app and see if
    content spills out of the sub-cell diamond. If the *lower* edges
    (closest to camera) overflow, shift the entire content up-right
    inside the 32×32 grid — the upper-right can spill into neighboring
    cells without looking wrong.

---

## 5. Sub-cell rendering

- Each sprite is rendered at `subObjectSize = blockSize / 3`. For our
  default `blockSize = 72`, that's 24pt square, with `0.75pt` per pixel.
- Sub-cell diamond is `blockSize/3` wide × `blockSize/6` tall.
- The sprite's *visual* bottom anchors at the sub-cell's bottom vertex
  (the front-most iso point of that cell).
- Shadow / 3-D hint is drawn for non-iso sprites only. Iso-native sprites
  handle depth inside the pixel data and don't need the SwiftUI shadow.

---

## 6. Known limitations

- **Asymmetric footprint**: when east-west span ≠ north-south span in
  3D, the pyramid peak cannot give exactly ±0.5 on both outer edges.
  Accept ≈ 0.5 on the larger side.
- **Corner gaps**: the pyramid-roof triangle won't cover wall corners
  that sit outside its projection. Eave overhang or a small "sky gap"
  at the NE / SW corners is the usual trade-off.
- **Animation integration**: existing per-building animations (windmill
  blades, well water shimmer, chimney smoke) reference sprite
  coordinates — update `chimneyCenterX` and similar fields when you
  move features.
- **Hand-drawing cost**: each building takes ~1.5–3 hours of careful
  pixel work. Auto-generating sprites from geometry alone tends to
  look jagged; hand-placed pixels with geometric guides look better.

---

## 7. Reference: completed sprites

| Sprite | Status | Notes |
|---|---|---|
| `house` | iso-native ✓ | Peak (18, 9), chimney cols 10-11 on 왼쪽(SW) roof |
| `fence` | iso-native ✓ | Rails slope -0.5, shifted up-right to avoid ground overflow |
| `tree` | billboard | Stays flat — iso convention for tall elements |
| `lamp` | billboard | Same as tree |
| `flowers` / `stone_path` | ground layer | Diamond-clipped, no slopes needed |
| `shop` | flat, todo | Similar to house — redraw when needed |
| `well` | flat, todo | Circular shapes → diamond approximation |
| `farm` | flat, todo | Ground-level, mostly a sheared texture |
| `windmill` | flat, todo | Blade rotation complicates iso redraw |

---

## 8. Per-element animation (Canvas rendering)

For animations that need to move individual elements within a sprite
(not just transform the whole sprite), bypass `PixelSpriteView` and
draw directly into a `Canvas` inside a `TimelineView(.animation)`.

Pattern used for flowers wind sway (see `FlowersGroundView`):

1. **Hardcode element positions** once, by reading the sprite grid.
   For flowers, a 5-pixel cross at `(col, row)` with a color char:

   ```swift
   private static let flowers: [(col: Int, row: Int, color: Character)] = [
       (2, 3, "y"), (10, 3, "p"), (19, 3, "w"), (27, 3, "u"), …
   ]
   ```

2. **Split static vs. animated layers** in the Canvas pass:

   ```swift
   // Static background — iterate the sprite, draw only non-animated cells.
   for (r, row) in Sprites.flowersGround.rows.enumerated() {
       for (c, ch) in row.enumerated() {
           guard ch == "G" || ch == "g" else { continue }  // grass only
           // fill pixel rect
       }
   }

   // Animated elements — draw at base position + per-element offset.
   for (i, f) in Self.flowers.enumerated() {
       let phase = Double(i) * 0.4                     // stagger each element
       let sway  = maxSway * sin(t * 2π/period + phase)
       // draw element at (f.col × px + sway, f.row × px)
   }
   ```

3. **Give each element its own phase** via `Double(index) * phaseStep`.
   Without this the whole patch moves in lockstep — reads as sprite
   translation rather than per-element animation, which was the exact
   problem before we switched away from `.offset(x:)`.

4. **Amplitude and period**: keep sway amplitude below ~1 pixel for
   ground textures. A full-pixel swing is already very visible at
   `0.75pt/pixel`. Period 4–6 s reads as "산들바람"; faster looks
   frantic.

5. **Clip after drawing**. Apply `.frame` + `.clipShape(DiamondMask())`
   on the `Canvas` view so animated pixels that sway past the diamond
   edge get cut cleanly, not exposed as rectangular overdraw.

Things this approach is good for:
- Scattered decorative elements (flowers, grass, sprouts, snowflakes)
- Water surface ripples (multiple highlight points)
- Lanterns / lamps flickering at different phases

Things it's **not** good for:
- Rigid structural elements (walls, roofs) — use static pixel art
- Animations that need a specific art-directed shape — use frame
  sprites / flipbook instead

See `FlowersGroundView` for the reference implementation.

---

## 9. Progressive-iteration guidance

When in doubt, go in small steps:

- Change one thing at a time (wall bottom slope, then top slope, then
  peak, then roof).
- Build and render after each change. The visual often tells you
  something the math didn't.
- Don't be afraid to `git revert` — `feat/village-pivot-polish-2` has
  several revert commits from iterations that went sideways. The final
  path always came from undoing and trying again.
- Big one-shot rewrites ("fix everything at once") almost always break
  because coupling between wall geometry, roof, door position, and
  baseline offset is tighter than it looks.

---

## 10. 48×48 workflow and rules

Use this when upgrading sprites from 32×32 to 48×48.

### Core principles

- Keep the same **2:1 iso geometry** (`±0.5` edge slopes). Do not
  redesign perspective from scratch during scale-up.
- Preserve the approved silhouette first, then add detail in a second pass.
- Keep iso-native structures (`house`, `shop`, `fence`) at
  `isoShearY(for:) == 0`.

### Authoring checklist (48×48)

1. Start from the existing approved sprite geometry (ground/top diamonds + peak).
2. Scale to 48×48 while preserving wall and roof edge slopes.
3. Add detail only after geometry is stable (roof highlight, window split, door trim).
4. Validate dimensions:
   each sprite must have exactly 48 rows, and each row must be 48 chars.
5. Count trailing empty rows (bottom `.` rows) for baseline compensation.
6. Update `spriteBaselineRows` in `VillageGridView.swift` using:
   `round(trailingEmptyRows * 32.0 / 48.0)`.
7. Build and render in-app; verify:
   the visual bottom touches the sub-cell anchor,
   lower/front edges do not float,
   and only acceptable upper-right overflow exists.

### Practical notes for this codebase

- `subObjectSize` remains based on a 32-reference scale in the current renderer,
  so 48×48 sprites require explicit baseline conversion.
- If a new 48×48 sprite appears tilted or bolted on, rollback to the last
  approved geometry and re-apply detail incrementally.

---

## 11. 쿼터뷰 관점 원칙

도트를 찍을 때 코드 레이어나 렌더링 로직이 아니라, **카메라에서 보이는 최종
이미지**를 기준으로 판단한다.

### 핵심 규칙

1. **보이는 그대로 찍는다.** "이 픽셀이 어떤 레이어에 속하는가"가 아니라
   "쿼터뷰 카메라에서 이 위치에 무엇이 보이는가"로 결정한다.
2. **바깥에서 본다.** 건물 내부 바닥이나 천장 면은 보이지 않는다. 보이는
   것은 지붕, 벽, 그리고 벽 위에 얹힌 구조물뿐이다.
3. **위에 있으면 보인다.** 1층 지붕 위에 2층 박스가 있으면, 지붕 면 위로
   2층 벽이 자연스럽게 보인다 — "뚫고 내려온" 것이 아니라 위에 있으니까
   보이는 것이다.

### 다층 건물 (stacked box)

2층 이상 건물은 각 층을 독립적인 iso 박스로 취급한다.

1. **1층 박스를 먼저 완성한다.** 9-point 프레임워크로 ground diamond →
   walls → top face(지붕). 지붕 색은 건물 컨셉에 맞춘다 (카페 = 초록).
2. **1층 지붕을 "땅"으로 간주하고**, 그 위에 동일한 원칙으로 2층 박스를
   그린다. 2층 footprint는 1층보다 작을 수 있다 (setback 구조).
3. **각 층의 모든 edge는 ±0.5 slope를 따른다.** 층간 경계에서도 예외 없음.
4. **쿼터뷰로 보이는 대로 합성한다.** 1층 지붕 다이아몬드 위에 2층 벽이
   겹치면 그대로 2층 벽을 찍는다. 지붕 픽셀을 "보존"할 필요 없다.

### 예시: 카페 (1F 초록지붕 + 2F 소형 박스)

```
Row 18: ..................EEeeeeeeEnnnnnnnnnn...........  ← 2F 벽 (지붕 아래)
Row 19: ..................EEeeeeeeEnnnnnnnaaAA..........  ← 2F 벽 + 1F 지붕 시작
Row 20: ................AAaaeeeeeeEnnnnnnaaaaaaAA.......  ← 1F 지붕 위에 2F 벽 보임
Row 21: ..........EEeeAAaaaaaannnnEnnnnaaaaaaaaaaAA.....  ← 1F 벽 + 지붕 + 2F seam
Row 23: ..........AAaaaaaaaaaaaaaaEaaaaaaaaaaAAnnnn.....  ← 1F 지붕 + seam 꼭지
```

초록(A/a) = 1층 지붕, e/E/n = 2층 벽이 지붕 위에 보이는 것.

---

## 12. 도트 작업 실행 체크리스트 (MANDATORY)

**이 체크리스트는 도트를 찍는 모든 작업에서 반드시 따라야 한다.
한 항목이라도 건너뛰면 안 된다.**

### Phase 1: 기하학 정의 (피처보다 먼저)

- [ ] **9-point 좌표를 명시적으로 정의한다.**
  모든 건물에 대해 NW, NE, SW, SE (ground), NW', NE', SW', SE' (top),
  Peak 좌표를 숫자로 적는다. 다층이면 층별로.
- [ ] **모든 edge가 ±0.5 slope인지 검증한다.**
  `Δcol / Δrow = ±2` 또는 vertical(Δcol=0).
  검증 스크립트를 돌려서 확인. 눈대중 금지.
- [ ] **각 row의 좌변/우변/seam 위치를 계산한다.**
  이 값이 피처 배치의 절대 경계가 된다.

### Phase 2: 벽 채우기

- [ ] **골격 내부만 채운다.**
  Phase 1에서 계산한 경계 안에서만 문자를 배치한다.
  - 왼쪽벽(SW면): `좌변 ~ seam` 범위
  - 앞쪽벽(SE면): `seam ~ 우변` 범위
- [ ] **edge slope 재검증한다.** 채운 후에도 ±0.5 유지 확인.

### Phase 3: 피처 추가 (창문, 문, 지붕 디테일)

- [ ] **한 번에 하나의 피처만 추가한다.**
  창문 → 검증 → 문 → 검증 → 벽돌 → 검증. 한꺼번에 금지.
- [ ] **피처는 기하학 경계 안에서 기존 문자를 교체하는 방식으로만 넣는다.**
  `put(row, col, string)` 같은 절대좌표 덮어쓰기 금지.
  대신: "Row N의 앞쪽벽(SE면)은 col A~B → 그 안의 `n`을 `X`, `D`로 교체".
- [ ] **다층 합성은 overpaint로 처리한다.**
  윗층/앞층이 보이는 위치는 아래 픽셀을 덮어쓴다.
  "아래 레이어 보존"을 위해 `.`로 지우는 루프를 만들지 않는다.
- [ ] **교체 후 해당 row의 좌변/우변이 변하지 않았는지 확인한다.**
  피처가 경계를 밀어내면 안 된다.
- [ ] **edge slope 재검증한다.**

### Phase 4: 최종 검증

- [ ] 전체 48 rows × 48 chars 확인.
- [ ] 모든 외곽 edge ±0.5 slope 확인 (L자 단차 점프 제외).
- [ ] trailing empty rows 세고 `spriteBaselineRows` 계산.
- [ ] 이미지 렌더링해서 쿼터뷰에서 자연스러운지 눈으로 확인.
- [ ] `isoShearY` = 0 설정 확인.

### 위반 시 대응

피처 추가 중 edge slope가 깨지면:
1. 해당 피처를 **즉시 revert**한다.
2. 경계를 다시 확인한다.
3. 경계 안에 맞게 피처를 축소/조정한 뒤 재시도한다.

**절대로 "피처가 좀 삐져나왔지만 괜찮겠지"로 넘어가지 않는다.**

---

## 13. 쿼터뷰/아이소 기하 학습 추가 반영 (2026-04-16)

충돌 시 이 섹션 규칙을 우선 적용한다.

- 픽셀 판단 기준은 "레이어 의미"가 아니라 "쿼터뷰 카메라에서 실제로 보이는 결과"다.
- 다층은 층별 독립 iso 박스로 모델링한다.
  1층 완성 → 1층 지붕을 2층의 ground로 간주 → 2층 박스 배치 순서를 고정한다.
- 각 단계에서 기하를 먼저 확정하고 디테일은 나중에 넣는다.
  9-point/경사 검증 전에는 간판·차양·창문 같은 피처를 추가하지 않는다.
- 피처 추가는 "경계 내 문자 교체"만 허용한다.
  절대좌표 문자열 삽입/삭제로 외곽 경계를 움직이는 방식은 금지한다.
- 픽셀 결손(holes) 방지를 위해 광역 `.` 초기화/삭제 패턴은 금지한다.
  필요한 위치만 최소 범위로 덮어쓴다.
