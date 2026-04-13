<p align="center">
  <img src="CapCha/Resources/Assets.xcassets/AppIcon.appiconset/icon_256.png" width="128" height="128" alt="CapCha Icon">
</p>

<h1 align="center">CapCha</h1>

<p align="center">
  <strong>Type to collect keycaps. Every keystroke counts.</strong>
</p>

<p align="center">
  <a href="https://github.com/cow-coding/CapCha/releases/latest"><img src="https://img.shields.io/github/v/release/cow-coding/CapCha?style=flat-square&color=6C5CE7&labelColor=2D3436&label=release" alt="Release"></a>
  <a href="https://github.com/cow-coding/CapCha/releases"><img src="https://img.shields.io/github/downloads/cow-coding/CapCha/total?style=flat-square&color=00B894&labelColor=2D3436" alt="Downloads"></a>
  <img src="https://img.shields.io/badge/platform-macOS%2013%2B-0984E3?style=flat-square&labelColor=2D3436" alt="Platform">
  <img src="https://img.shields.io/badge/swift-5.9-F97F51?style=flat-square&labelColor=2D3436" alt="Swift">
</p>

<p align="center">
  <a href="docs/README.ko.md">한국어</a> · <a href="https://github.com/cow-coding/CapCha/releases/latest">Download</a> · <a href="docs/DESIGN.en.md">Design Doc</a>
</p>

---

<!-- TODO: Add demo GIF here -->
<!-- <p align="center"><img src="docs/assets/demo.gif" width="600" alt="CapCha Demo"></p> -->

## What is CapCha?

CapCha is a macOS menu bar app that turns your everyday typing into a collectible keycap gacha game. Just type as you normally do — coding, writing, chatting — and watch virtual keycaps drop into your collection.

> **🔒 Privacy first** — CapCha never reads what you type. It only counts keystrokes using `CGEvent tap` in listen-only mode. Zero network access, all data stays local.

### Highlights

- 🎲 **2,610 keycap combinations** — 87 TKL keys × 5 themed sets × 6 rarity tiers
- 🌈 **6 rarity tiers** — Common → Uncommon → Rare → Epic → **Legendary** → ***Eternal***
- 🎯 **Pity system** — Guaranteed drop within 2,000 keystrokes, no endless droughts
- 🔔 **Drop notifications** — Popover bubble right below your menu bar icon
- 📦 **Collection window** — Browse keycaps with isometric 3D card views
- ⚙️ **Settings** — Launch at login, notification toggle
- 🔐 **Security audited** — No key content reading, no network, no data collection

---

## Installation

### 1. Download

> **[Download Latest DMG](https://github.com/cow-coding/CapCha/releases/latest)**

### 2. Install

Open the DMG → Drag **CapCha** to **Applications**.

### 3. First Launch

macOS will block the app since it's not notarized:

```
System Settings → Privacy & Security → Open Anyway → Open
```

### 4. Grant Permission

```
System Settings → Privacy & Security → Input Monitoring → CapCha → ON
```

> **💡 Updating?** Remove the old CapCha entry from Input Monitoring first, then add the new one.

---

## How It Works

```
⌨️ Keystroke → 🎲 Drop Check (0.25%) → 🎰 Rarity Roll → 🎁 Keycap! → 🔔 Notification
```

### Drop Mechanics

Every keystroke rolls a **0.25% base chance**. On success, the system picks a random **rarity → set → key** combination and generates a unique keycap.

### Rarity Tiers

| Rarity | Weight | Visual Effect |
|:-------|:------:|:-------------|
| ⚪ Common | 59.4% | Plain keycap |
| 🟢 Uncommon | 25% | Green glow + tinted outline |
| 🔵 Rare | 10% | Blue glow + thick outline |
| 🟣 Epic | 4% | Purple glow + inner shine |
| 🟠 Legendary | 1% | Gold glow + inner shine |
| 🌈 Eternal | 0.6% | Animated prismatic rainbow |

### Pity System

No more bad luck streaks. Drop chance increases automatically:

| Keystrokes Without Drop | Drop Chance |
|:-----------------------|:-----------|
| 0 – 499 | 0.25% (base) |
| 500 – 999 | 0.25% → 0.5% |
| 1,000 – 1,999 | 0.5% → 1.0% |
| 2,000+ | **100% guaranteed** |

> 🎁 **First-time bonus** — New users get a guaranteed Common keycap within 100 keystrokes.

### Keycap Sets

| Set | Theme | Color |
|:----|:------|:-----:|
| Mechanical Classics | Cherry-inspired switches | 🔴 |
| Retro Computing | Vintage terminals | 🟤 |
| Artisan Collection | Handcrafted artisans | 🟣 |
| Nature Elements | Earth and forest | 🟢 |
| Space Theme | Deep cosmos | 🔵 |

Each set has all **87 TKL keys**. Same key can appear in any rarity — collect them all!

Duplicates stack as count. Save them for future trading!

---

## Build from Source

```bash
# Prerequisites
brew install xcodegen

# Generate & Build
xcodegen generate
xcodebuild -project CapCha.xcodeproj -scheme CapCha -configuration Release build
```

---

## Tech Stack

| | Technology |
|:--|:----------|
| **Language** | Swift 5.9 |
| **UI** | SwiftUI + Canvas (isometric keycap rendering) |
| **Input** | CGEvent tap (listen-only, tailAppend) |
| **Reactive** | Combine |
| **Storage** | JSON (`~/Library/Application Support/CapCha/`) |
| **CI/CD** | GitHub Actions + create-dmg |

---

## Documentation

| | |
|:--|:--|
| 📄 [Design Doc (EN)](docs/DESIGN.en.md) | Architecture, data models, drop engine |
| 📄 [Design Doc (KR)](DESIGN.md) | 아키텍처, 데이터 모델, 드롭 엔진 |

---

## Privacy

CapCha uses macOS Input Monitoring to count keystrokes.

- ✅ Only counts key presses — never reads content
- ✅ Zero network access — all data stays local
- ✅ Open source — verify it yourself
- ✅ Security audited — [see audit report](https://github.com/cow-coding/CapCha/pull/3)

---

## License

Apache License 2.0 — see [LICENSE](LICENSE) for details.
