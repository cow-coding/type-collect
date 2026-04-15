# Tapistry iso pixel art guide

Convention and workflow for drawing 32×32 iso pixel-art sprites that sit
naturally on the Tapistry grass block. Applies to `BuildingPixelView.swift`
sprites and their rendering in `VillageGridView.swift`.

---

## 1. The iso grid

Tapistry uses **2:1 isometric** projection (a.k.a. dimetric). Every edge on
the grass block — top-face diamond edges and the side-face top edges — runs
at slope **±0.5**: 2 screen pixels horizontal per 1 screen pixel vertical.

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
| `R` | South roof (brighter) | `roof` |
| `r` | East roof (shadowed) | `roofDark` |
| `W` | South wall trim / top edge | `wallDark` |
| `n` | South wall body | `wall` |
| `E` | East wall trim / top edge | `plankDark` |
| `e` | East wall body | `wallDark` |
| `X` / `x` | Window | `window` / `windowDark` |
| `D` / `d` / `h` | Door / frame / knob | `door` / `doorLight` / `shopSign` |
| `C` / `c` | Chimney body / cap shadow | `chimney` / `chimneyDark` |
| `K` | Base / foundation trim | `plankDark` |
| `P` / `p` | Wood plank / shadow | `plank` / `plankDark` |
| `.` | Empty / sky | (not rendered) |

Keep south-face brightness > east-face brightness so the SE-camera
lighting reads naturally (south catches more light, east is in shadow).

---

## 4. Step-by-step workflow

When converting a flat sprite into iso, go in this order. Build, render,
and commit after each step so you can revert cleanly.

1. **Pick the 9 points**. Sketch ground diamond, top diamond, peak on
   graph paper or a throwaway render. Verify every edge is ±0.5.
2. **Slope the wall bottoms**. South wall base should slope -0.5 from
   seam to outer-SW; east wall base should slope +0.5 from seam to
   outer-NE.
3. **Slope the wall tops**. Match the same ±0.5 slopes so the wall
   becomes a proper parallelogram, and both walls share the same
   top-row at the seam.
4. **Place the peak**. Use the formula above. Draw the single peak
   pixel.
5. **Fill the roof**. Two triangles (east and south slopes) sharing the
   peak-to-seam-top edge. East uses `r`, south uses `R`. Let the eave
   overhang the wall outer corners if pure triangle geometry leaves
   gaps (a 1–2 column overhang at the eave row is acceptable).
6. **Fill the walls**. Use `W`/`E` for outer and top trim, `n`/`e` for
   body. Seam column (col 12 east / col 13 south for our standard) gets
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
| `house` | iso-native ✓ | Peak (18, 9), chimney cols 10-11 on east roof |
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
