<p align="center">
  <img src="CapCha/Resources/Assets.xcassets/AppIcon.appiconset/icon_256.png" width="128" height="128" alt="CapCha Icon">
</p>

<h1 align="center">CapCha</h1>

<p align="center">
  <strong>Type to collect keycaps. Every keystroke counts.</strong>
</p>

<p align="center">
  <a href="https://github.com/cow-coding/CapCha/releases/latest">
    <img src="https://img.shields.io/github/v/release/cow-coding/CapCha?style=flat-square&color=white&labelColor=000000&label=release" alt="Release">
  </a>
  <a href="https://github.com/cow-coding/CapCha/releases">
    <img src="https://img.shields.io/github/downloads/cow-coding/CapCha/total?style=flat-square&color=white&labelColor=000000" alt="Downloads">
  </a>
  <a href="https://github.com/cow-coding/CapCha/blob/main/LICENSE">
    <img src="https://img.shields.io/badge/license-TBD-white?style=flat-square&labelColor=000000" alt="License">
  </a>
  <img src="https://img.shields.io/badge/platform-macOS%2013%2B-white?style=flat-square&labelColor=000000" alt="Platform">
  <img src="https://img.shields.io/badge/swift-5.9-white?style=flat-square&labelColor=000000" alt="Swift">
</p>

<p align="center">
  <a href="docs/README.ko.md">한국어</a>
</p>

---

## What is CapCha?

CapCha is a macOS menu bar app that turns your everyday typing into a collectible keycap gacha game. Just type as you normally do — coding, writing, chatting — and watch virtual keycaps drop into your collection.

> **🔒 Privacy first** — CapCha uses `CGEvent tap` in listen-only mode. It only counts keystrokes — it never reads, stores, or transmits what you type.

### Highlights

- 🎲 **2,610 keycap combinations** — 87 TKL keys × 5 themed sets × 6 rarity tiers
- 🌈 **6 rarity tiers** — Common → Uncommon → Rare → Epic → Legendary → Eternal
- 🎯 **Pity system** — No endless droughts, guaranteed drop within 2,000 keystrokes
- 🔔 **Drop notifications** — Popover bubble anchored to menu bar icon
- 📦 **Collection window** — Browse keycaps with isometric 3D card views
- ⚙️ **Settings** — Launch at login, notification toggle
- 🔐 **Secure** — Full security audit, no network access, no data collection

---

## Installation

### 1. Download

Download the latest **DMG** from the [Releases](https://github.com/cow-coding/CapCha/releases/latest) page.

### 2. Install

Open the DMG and drag **CapCha** → **Applications**.

### 3. First Launch

Since CapCha is not notarized with Apple Developer ID:

1. Open **CapCha** — macOS will show a warning
2. Go to **System Settings → Privacy & Security**
3. Click **Open Anyway** → **Open**

### 4. Grant Permission

1. Go to **System Settings → Privacy & Security → Input Monitoring**
2. Toggle **CapCha** → **ON**
3. Restart CapCha if needed

> ⚠️ **Updating?** Remove the old CapCha entry from Input Monitoring before adding the new one.

---

## How It Works

```
⌨️ Keystroke → 🎲 Drop Check (0.25%) → 🎰 Rarity Roll → 🎁 Keycap Drop → 🔔 Notification
```

Every keystroke has a **0.25% base chance** to drop a keycap. When a drop occurs, the rarity is determined by weighted random, and a random key + set combination is generated.

### Rarity Tiers

| Rarity | Weight | Visual |
|--------|--------|--------|
| Common | 59.4% | Plain keycap |
| Uncommon | 25% | Green glow |
| Rare | 10% | Blue glow + thick outline |
| Epic | 4% | Purple glow + inner shine |
| Legendary | 1% | Gold glow + inner shine |
| Eternal | 0.6% | 🌈 Animated rainbow glow |

### Pity System

Drop chance ramps up the longer you go without a drop:

| Gap | Chance |
|-----|--------|
| 0 – 499 keystrokes | 0.25% base |
| 500 – 999 | → 0.5% ramp |
| 1,000 – 1,999 | → 1.0% ramp |
| 2,000+ | **Guaranteed** |

First-time users get a **guaranteed Common drop within 100 keystrokes**.

### Keycap Sets

| Set | Theme | Vibe |
|-----|-------|------|
| Mechanical Classics | Cherry reds | 🔴 Bold, warm |
| Retro Computing | Vintage beige | 🟤 Nostalgic |
| Artisan Collection | Deep purples | 🟣 Premium |
| Nature Elements | Forest greens | 🟢 Organic |
| Space Theme | Cosmic blues | 🔵 Ethereal |

Duplicates stack as count — save them for future trading!

---

## Build from Source

```bash
brew install xcodegen
xcodegen generate
xcodebuild -project CapCha.xcodeproj -scheme CapCha -configuration Release build
```

---

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Language | Swift 5.9 |
| UI | SwiftUI + Canvas |
| Keystroke | CGEvent tap (listen-only, tailAppend) |
| Data Flow | Combine |
| Persistence | JSON (`~/Library/Application Support/CapCha/`) |
| CI/CD | GitHub Actions + create-dmg |

---

## Documentation

- [DESIGN.md](./DESIGN.md) — Architecture design (Korean)
- [docs/DESIGN.en.md](./docs/DESIGN.en.md) — Architecture design (English)

---

## Privacy

CapCha uses macOS Input Monitoring permission to count keystrokes.

**We never read, store, or transmit what you type.** Only the keystroke count is tracked. The app has zero network access — all data stays local on your machine.

---

## License

TBD
