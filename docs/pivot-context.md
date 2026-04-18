# Tapistry Product Context

> Historical note: this project started as `CapCha`, a keycap collection concept, and pivoted into **Tapistry**, a typing-powered village builder. The current product direction is now fixed as **Tapistry only**.

## Product summary

Tapistry is a macOS menu bar app where everyday typing powers the growth of a tiny isometric village.

- Typing grants XP.
- XP increases village level.
- Leveling unlocks new content.
- Typing also rolls coin rewards.
- Coins are spent to place buildings on a persistent 4×4 village grid.

The keyboard remains the base progression input, but the product is no longer a collectible keycap game. It is a single-product village builder with a privacy-first typing loop.

---

## Current architecture

### App shell

- `Tapistry/App/TapistryApp.swift`
  - Creates the menu bar status item and main popover.
  - Wires the level-up toast to the status item anchor.
  - Opens the first-launch onboarding window.

### Typing and progression

- `Tapistry/Core/KeystrokeMonitor.swift`
  - Counts global `keyDown` events via listen-only `CGEvent tap`.
- `Tapistry/App/AppState.swift`
  - Restores persisted typing stats.
  - Converts keystroke deltas into XP and daily counts.
  - Rolls coin drops and adds them to the village economy.

### Village state

- `Tapistry/Models/VillageState.swift`
  - Owns XP, level progression, cash, and the 4×4 tile grid.
  - Persists village data to `~/Library/Application Support/Tapistry/village.json`.
- `Tapistry/Models/VillageTile.swift`
  - Stores `ground` plus a 2×2 `subCells` matrix for `object` and `decoration`.
- `Tapistry/Models/BuildingCatalog.swift`
  - Defines unlock order, prices, animation flags, and layer type.

### UI

- `Tapistry/Views/MenuBarContentView.swift`
  - Renders the header, XP bar, cash bar, permission banner, village grid, and footer.
- `Tapistry/Views/Village/VillageGridView.swift`
  - Draws the 4×4 isometric map and per-tile placement state.
- `Tapistry/Views/Village/TileEditorView.swift`
  - Provides ground/object/decoration editing with sub-cell placement and coin spending.
- `Tapistry/Views/Village/BuildingPixelView.swift`
  - Contains the pixel-art sprite renderers and lightweight animations.
- `Tapistry/Views/Village/LevelUpToast.swift`
  - Shows localized level-up notifications from the menu bar icon.
- `Tapistry/Views/Onboarding/WelcomeView.swift`
  - Introduces the product concept and privacy guarantees on first launch.

### Settings and localization

- `Tapistry/Models/AppSettings.swift`
  - Stores launch-at-login, notifications, onboarding completion, and language.
- `Tapistry/Models/Localization.swift`
  - Provides the English/Korean localized string layer.
- `Tapistry/Views/SettingsView.swift`
  - Exposes language switching, launch at login, and notification settings.

---

## Current progression table

`1 keystroke = 1 XP`

| Lv | Cum XP | Unlock | Layer | Current render state |
|---:|-------:|:-------|:------|:---------------------|
| 1 | 0 | Tree | object | Pixel art + animation |
| 2 | 100 | Flowers | ground | Pixel art + animation |
| 3 | 300 | Fence | decoration | Pixel art |
| 4 | 500 | - | - | Toast only |
| 5 | 800 | House | object | Pixel art + animation |
| 6 | 1,100 | - | - | Toast only |
| 7 | 1,500 | Stone Path | ground | Pixel art |
| 8 | 2,500 | Lamp | decoration | Pixel art + animation |
| 9 | 3,200 | - | - | Toast only |
| 10 | 4,000 | Street Tree | object | Pixel art + animation |
| 11 | 5,000 | - | - | Toast only |
| 12 | 6,000 | Shop | object | Pixel art |
| 13 | 7,500 | - | - | Toast only |
| 14 | 9,000 | Cafe | object | Emoji fallback |
| 15 | 10,000 | Apartment | object | Emoji fallback |
| 16 | 12,000 | - | - | Toast only |
| 17 | 14,000 | City Hall | object | Emoji fallback |
| 18 | 16,500 | Hotel | object | Emoji fallback |
| 19 | 18,500 | Skyscraper | object | Emoji fallback |
| 20 | 20,000 | Windmill | object | Pixel art + animation |

---

## Rendering status

### What is already implemented

- Ground, object, and decoration layers all render in the village view.
- Tile editing supports ground placement plus 2×2 sub-cell placement for objects and decorations.
- Ground sprites are diamond-clipped to the tile top face.
- Baseline compensation is applied so sprites sit on the iso anchor instead of floating.
- Late-game buildings can still be placed even when they currently use emoji fallback rendering.

### Important rendering facts

- `blockSize` in the village grid is currently `72`.
- Draw order is based on `row + col` so front tiles appear on top.
- Some sprites are iso-native and rendered with `isoShearY == 0`.
- Billboard-style sprites like trees and lamps remain upright by design.

---

## Localization status

- The app currently supports English and Korean.
- Language switching is instant from Settings.
- Building names and core UI strings are localized through `LocalizedString` and `L10n`.

---

## Product decisions now locked

- **Product name:** Tapistry
- **Primary loop:** typing -> XP and coins -> level unlocks -> village placement
- **Scope:** single-product village builder
- **Non-goal:** reviving the old CapCha keycap collection flow as a first-class mode

Legacy CapCha design documents remain in the repo only as historical reference.

---

## Highest-priority remaining work

1. **Late-game art pass**
   - Replace emoji fallback rendering for `cafe`, `apartment`, `cityhall`, `hotel`, and `skyscraper` with proper Tapistry pixel sprites.
2. **Onboarding and copy polish**
   - Continue refining first-launch messaging so the village-builder loop is immediately clear.
3. **Logic coverage**
   - Add tests for level progression, persistence migration, and tile placement rules.
4. **Economy tuning**
   - Revisit coin drop pacing and placement prices after broader playtesting.
5. **Documentation maintenance**
   - Keep public and internal docs aligned with the actual Tapistry implementation as the product evolves.

---

## Files that matter most right now

- `Tapistry/App/TapistryApp.swift`
- `Tapistry/App/AppState.swift`
- `Tapistry/Models/VillageState.swift`
- `Tapistry/Models/VillageTile.swift`
- `Tapistry/Models/BuildingCatalog.swift`
- `Tapistry/Views/MenuBarContentView.swift`
- `Tapistry/Views/Village/VillageGridView.swift`
- `Tapistry/Views/Village/TileEditorView.swift`
- `Tapistry/Views/Village/BuildingPixelView.swift`
- `Tapistry/Views/Village/LevelUpToast.swift`
- `Tapistry/Views/Onboarding/WelcomeView.swift`
