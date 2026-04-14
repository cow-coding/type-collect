# TypeVillage Pivot — Context Document

## Overview

**Pivot direction**: `CapCha` (keyboard keycap gacha collection) → `TypeVillage` (keyboard-typing-powered village builder).

Typing keystrokes is still the core input, but instead of dropping keycaps to collect, each keystroke awards XP that levels up a tiny village shown in a 4×4 isometric grid inside the menu bar popover.

**Branch**: `feat/village-pivot`
**Not merged to main yet** — will merge only when pivot is complete.

---

## Journey (what happened today)

### Phase 1 — Keyboard Assembly attempt (rolled back)

The original CapCha plan was a **Keyboard Assembly** feature: mount collected keycaps onto a TKL keyboard view.

- Designed 3D voxel keycaps, 5 sets × 6 rarities = 30 sprites via OpenAI `gpt-image-1`
- Hit the OpenAI billing hard-limit after 5 images; filled the remaining 25 via PIL HSV hue shift
- Built 90 width-variant sprites via 9-slice stretch (wide / xwide / space)
- SwiftUI `KeySlotView` iterated several times: flat box → sprite image → tapered Cherry profile
- **Decision: spec out.** SwiftUI-rendered keycaps looked janky; sprite stretching looked like "flat pancakes" on wider keys. Assembly feature didn't feel valuable enough to keep iterating.
- **Rolled back** to `main`-equivalent state. All assembly files, 120 voxel keycap assets deleted.

### Phase 2 — Village pivot design

Agreed concepts after brainstorming:
- Keystroke → XP → level-up → unlocks new building
- Menu bar popover (280px wide) shows a tiny 4×4 isometric grid
- One tile has **3 stackable layers**: `ground` + `object` + `decoration`
- Aesthetic: cute / charming (Animal Crossing-lite), with some animated elements so the village isn't static
- Keep keyboard monitoring but treat it as an input tap, not the whole game loop

### Phase 3 — Implementation (current state of branch)

#### Project rename
- `CapCha/` → `TypeVillage/`
- `CapChaApp.swift` → `TypeVillageApp.swift` (struct name too)
- Bundle ID: `com.capcha.app` → `com.typevillage.app`
- App Support dir: `~/Library/Application Support/CapCha/` → `.../TypeVillage/`
- `xcodegen` config (`project.yml`) updated; `*.xcodeproj` regenerated
- Old `TypeCollect.xcodeproj` (stale) deleted

#### Core model (new)
- `Models/VillageState.swift` — ObservableObject with XP, level, 4×4 grid, unlocks, persistence to `village.json`
- `Models/VillageTile.swift` — `VillageTile { ground, object, decoration }` + `TileLayer` enum
- `Models/BuildingCatalog.swift` — 10 building types with `LocalizedString` names
- `Models/Localization.swift` — `AppLanguage` enum (en/ko) + `LocalizedString` + `L10n` namespace

#### Views (new)
- `Views/Village/VillageGridView.swift` — isometric 4×4 grid, per-tile selection with yellow diamond glow
- `Views/Village/GrassBlockView` — pure SwiftUI `Canvas` isometric grass block (top + L/R faces, grass edge strip)
- `Views/Village/BuildingPixelView.swift` — placeholder emoji renderer (size = 0.8 × block)
- `Views/Village/BuildingPickerView.swift` — tile-tap popover, 3-layer tabs, unlocked / locked sections
- `Views/Village/LevelUpToast.swift` — level-up popover bubble anchored to menu bar status item (⭐ + `Lv.N → Lv.N+1` + unlocked building chips)

#### Reworked
- `MenuBarContentView` — header + (XP bar OR permission banner) + grid + `#if DEBUG` level buttons + footer (Settings / Quit)
- `SettingsView` — Language segmented picker (English / 한국어), Launch at login, Show notifications, About
- `AppSettings` — added `@Published var language` with system-default fallback
- `AppState` — wires `keystrokeMonitor.totalCount` delta into `village.addXP`; still monitors + saves stats, but drop engine / collection is idle (old CapCha code preserved, not wired to Village yet)

---

## Level / XP Table

1 keystroke = 1 XP.

| Lv | Cum XP | Unlock | Layer | Animated? |
|----|--------|--------|-------|-----------|
| 1  | 0      | 🌳 Tree (나무)       | object     | ✅ |
| 2  | 100    | 🌸 Flowers (꽃밭)    | ground     |    |
| 3  | 300    | 🪵 Fence (울타리)    | decoration |    |
| 4  | 500    | —                    |            |    |
| 5  | 800    | 🏠 House (나무집)    | object     | ✅ |
| 6  | 1,100  | —                    |            |    |
| 7  | 1,500  | 🪨 Stone Path (돌길) | ground     |    |
| 8  | 2,500  | 💡 Lamp (가로등)     | decoration | ✅ |
| 9  | 3,200  | —                    |            |    |
| 10 | 4,000  | 🪣 Well (우물)       | object     | ✅ |
| 11 | 5,000  | —                    |            |    |
| 12 | 6,000  | 🌱 Farm (텃밭)       | object     | ✅ |
| 13 | 7,500  | —                    |            |    |
| 14 | 9,000  | —                    |            |    |
| 15 | 10,000 | 🏪 Shop (상점)       | object     | ✅ |
| 16–19 | 12k–18.5k | —             |            |    |
| 20 | 20,000 | 🌾 Windmill (풍차)   | object     | ✅ |

Empty levels (4, 6, 9, 11, 13, 14, 16–19) still fire level-up toast but with no unlock chip.

---

## Building Layer Rules

- `ground` — covers the grass top face (flowers, stone path). Replaces default grass visual.
- `object` — the main building; one per tile (tree, house, etc.)
- `decoration` — goes on top / around (fence, lamp)

**Data model supports all 3 layers today; rendering currently only draws the `object` layer.** Ground + decoration rendering is TODO.

---

## Rendering Details

### Isometric grid layout
- `blockSize = 64` (was 56; bumped for better hit targets)
- Tile offset: `x = (col - row) * halfW`, `y = (col + row) * quarterH`
- Draw order sorted by `row + col` ascending so foreground tiles z-order on top
- Hit area limited to the diamond top face via `.contentShape(TopFaceDiamondHitArea())` to avoid rectangular overlap between adjacent tiles

### Selection highlight
- Yellow diamond fill + pulsing stroke on top face
- `topFaceOffsetY = -blockSize / 8` to align with the grass top face within the centered ZStack

### Object placement
- Emoji scaled to 0.8 × blockSize
- Drop-shadow + spring bounce animation on `onChange(of: objectId)` — 0.1 → 1.0 scale

### Level-up toast
- `NSPopover` anchored to the status item button (mirrors the old CapCha drop-notification pattern — the earlier free-floating `NSWindow` toast caused crashes)
- Shows `Lv.from → Lv.to`; if unlocks exist, stays longer (4.5s vs 3.0s) and lists unlock chips

### Menu bar icon
- 16×16 pixel-art house (simple roof overhang + chimney, no window since the earlier window version read as a face)
- Rendered as `template` image (single-color auto-tint)

---

## Localization

- `AppLanguage` = `.english | .korean`
- `AppSettings.language` defaults to `AppLanguage.systemDefault` (Locale-derived)
- `LocalizedString { en, ko }` struct + `.resolve(lang)` method
- `L10n` namespace holds all UI strings + `BuildingType.name` uses it
- Views observe `AppSettings.shared` and read `settings.language`; switching in Settings is instant
- Picker in Settings: segmented control with `English` / `한국어`

---

## DEBUG affordances

`MenuBarContentView` under `#if DEBUG`:
- `Lv1` / `Lv5` / `Lv10` / `Lv20` — jump directly to level (resets XP to cumulative threshold)
- `+100XP` — increment and trigger level-up if crossing threshold

`VillageState` methods exposed only in `#if DEBUG`:
- `setLevel(_ targetLevel: Int)`
- `unlockAll()` (sets XP to 20,000)

---

## Known gaps / next steps

1. **Ground layer rendering** — `flowers`, `stone_path` placed in data but not drawn on top face yet
2. **Decoration layer rendering** — `fence`, `lamp` placed in data but not drawn
3. **Pixel art for buildings** — currently placeholder emojis; plan is SwiftUI Canvas pixel painting (arrays of color chars) like the grass block, with simple animations (tree sway, windmill rotation, chimney smoke, lamp flicker)
4. **Project name** — `TypeVillage` is a working title. Finalize before merging to `main`.
5. **Drop engine / CollectionView** — old CapCha code still in tree (`Core/DropEngine`, `Views/Collection/*`) but not reachable from UI. Decide: delete, or keep as optional mode.
6. **Welcome onboarding** — copy still partly references the old concept.

---

## File map

**Added on this branch:**
- `TypeVillage/Models/VillageState.swift`
- `TypeVillage/Models/VillageTile.swift`
- `TypeVillage/Models/BuildingCatalog.swift`
- `TypeVillage/Models/Localization.swift`
- `TypeVillage/Views/Village/VillageGridView.swift`
- `TypeVillage/Views/Village/BuildingPixelView.swift`
- `TypeVillage/Views/Village/BuildingPickerView.swift`
- `TypeVillage/Views/Village/LevelUpToast.swift`
- `docs/pivot-context.md` (this file)

**Meaningfully changed:**
- `TypeVillage/App/TypeVillageApp.swift` (renamed, wires level-up hook, drops collection window)
- `TypeVillage/App/AppState.swift` (owns `VillageState`, feeds keystroke delta to `addXP`)
- `TypeVillage/Models/AppSettings.swift` (language)
- `TypeVillage/Persistence/StorageManager.swift` (directory name)
- `TypeVillage/Views/MenuBarContentView.swift` (rebuilt around village)
- `TypeVillage/Views/SettingsView.swift` (language picker, About trimmed)
- `project.yml` (name / bundle / version reset to 0.1.0)
- `TypeVillage/Resources/Assets.xcassets/MenuBarIcon.imageset/*` (house icon)

**Renamed in bulk:**
- All `CapCha/**` → `TypeVillage/**`

**Stale / to decide:**
- `TypeVillage/Core/DropEngine.swift`, `SessionTracker.swift` — drop logic retained but not consumed
- `TypeVillage/Views/Collection/*` — old collection UI, unreachable
- `TypeVillage/Views/DropToastView.swift` — old keycap toast (different from `LevelUpToast`)
