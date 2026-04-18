<p align="center">
  <img src="Tapistry/Resources/Assets.xcassets/AppIcon.appiconset/icon_256.png" width="128" height="128" alt="Tapistry Icon">
</p>

<h1 align="center">Tapistry</h1>

<p align="center">
  <strong>Type to weave a tiny village. Every keystroke becomes progress.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS%2013%2B-0984E3?style=flat-square&labelColor=2D3436" alt="Platform">
  <img src="https://img.shields.io/badge/swift-5.9-F97F51?style=flat-square&labelColor=2D3436" alt="Swift">
  <img src="https://img.shields.io/badge/ui-SwiftUI%20%2B%20Canvas-2ECC71?style=flat-square&labelColor=2D3436" alt="UI">
</p>

<p align="center">
  <a href="docs/README.ko.md">한국어</a> · <a href="docs/pivot-context.md">Product Context</a> · <a href="docs/iso-pixel-art-guide.md">Iso Pixel Art Guide</a>
</p>

https://github.com/user-attachments/assets/95f25153-f32f-453e-8181-6663cacb54d4

---

## What is Tapistry?

Tapistry is a macOS menu bar app that turns everyday typing into a tiny isometric village builder.
As you type, the app awards XP and coins. XP raises your village level, and new buildings unlock over time. Coins let you place those buildings onto a 4×4 isometric village grid that lives right inside the menu bar popover.

> **Privacy first** — Tapistry never reads what you type. It only counts key-down events through a listen-only `CGEvent tap`. No network access, no key content capture, and all data stays on your Mac.

## Highlights

- **Typing-powered progression** — `1 keystroke = 1 XP`, with coin drops layered on top.
- **4×4 isometric village** — Build a compact pixel-art town directly from the menu bar.
- **Layered tile editing** — Each tile supports `ground`, `object`, and `decoration`, with 2×2 sub-cell placement for finer layout control.
- **Animated pixel art** — Trees sway, lamps flicker, smoke rises, and windmill blades rotate.
- **Bilingual UI** — English and Korean are both supported in-app, with instant language switching in Settings.
- **Local-first persistence** — Village state, coins, and typing stats are stored locally in Application Support.
- **macOS-native settings** — Launch at login, notification toggle, onboarding, and permission guidance are built in.

## Gameplay Loop

```text
⌨️ Keystroke → ⭐ XP + 💰 coin rolls → ⬆️ Level up → 🏡 Unlock buildings → 🧱 Place them in your village
```

### Progression

- Every keystroke grants XP.
- Leveling up unlocks new village content.
- Coins are earned probabilistically from typing and spent when placing buildings.
- The village is persistent, so your layout stays across launches.

### Current unlock path

| Level | Unlock |
|:------|:-------|
| 1 | Tree |
| 2 | Flowers |
| 3 | Fence |
| 5 | House |
| 7 | Stone Path |
| 8 | Lamp |
| 10 | Street Tree |
| 12 | Shop |
| 14 | Cafe |
| 15 | Apartment |
| 17 | City Hall |
| 18 | Hotel |
| 19 | Skyscraper |
| 20 | Windmill |

### Village building rules

- `ground` fills the tile's top face, for surfaces like flowers or stone paths.
- `object` is the main structure placed into a tile sub-cell.
- `decoration` adds accents such as fences and lamps around the main object.
- Objects and decorations are placed inside a 2×2 sub-grid per tile, so layouts can feel denser than a single-item-per-tile system.

## Privacy

Tapistry uses macOS Input Monitoring only to count keystrokes.

- Only key press counts are observed.
- Typed content is never read or stored.
- No analytics, ads, or telemetry are included.
- No network access is required for the core app.
- All local data is stored under `~/Library/Application Support/Tapistry/`.

## Build from Source

```bash
# Prerequisites
brew install xcodegen

# Generate & Build
xcodegen generate
xcodebuild -project Tapistry.xcodeproj -scheme Tapistry -configuration Release build
```

### First Launch

If macOS blocks the app on first run:

```text
System Settings → Privacy & Security → Open Anyway → Open
```

Then grant Input Monitoring:

```text
System Settings → Privacy & Security → Input Monitoring → Tapistry → ON
```

If you are replacing an older build, remove the previous Tapistry entry from Input Monitoring and enable the new one again.

## Tech Stack

| | Technology |
|:--|:----------|
| **Language** | Swift 5.9 |
| **UI** | SwiftUI + Canvas |
| **App Model** | macOS menu bar app (`LSUIElement`) |
| **Input** | `CGEvent tap` in listen-only mode |
| **Reactive** | Combine |
| **Persistence** | JSON in Application Support |
| **Project Generation** | XcodeGen |

## License

Apache License 2.0 — see [LICENSE](LICENSE) for details.
