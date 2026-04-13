# CapCha

A macOS menu bar app that collects virtual keycaps as you type.

[한국어](docs/README.ko.md)

## What is CapCha?

Just type as you normally do — coding, writing, chatting.
CapCha runs quietly in your menu bar and drops virtual keycap collectibles as you type.

- Runs silently in the background as a menu bar app
- **Never reads what you type** — only counts keystrokes
- 5-tier rarity system: Common → Uncommon → Rare → Epic → Legendary
- 30 unique keycaps across 5 themed sets

## Installation

### 1. Download

Download the latest `CapCha-vX.X.X.dmg` from the [Releases](https://github.com/cow-coding/CapCha/releases) page.

### 2. Install

Open the DMG and drag **CapCha** to **Applications**.

### 3. First Launch — Gatekeeper Warning

Since CapCha is not signed with an Apple Developer ID, macOS will block it on first launch.

1. Open **CapCha** from Applications — macOS will show a warning dialog
2. Go to **System Settings → Privacy & Security**
3. Scroll down to the **Security** section
4. You'll see: *"CapCha" was blocked from use because it is not from an identified developer.*
5. Click **Open Anyway**
6. In the confirmation dialog, click **Open**

> You only need to do this once. After that, CapCha will open normally.

### 4. Grant Input Monitoring Permission

CapCha needs Input Monitoring permission to count your keystrokes.

1. On first launch, CapCha will request Input Monitoring access
2. If the system dialog appears, click **Open System Settings**
3. Go to **System Settings → Privacy & Security → Input Monitoring**
4. Find **CapCha** in the list and toggle it **ON**
5. You may need to restart CapCha after granting permission

> **Privacy**: CapCha uses `CGEvent tap` in listen-only mode. It only increments a counter on each key press — it never reads, stores, or transmits the content of your keystrokes.

## Usage

Once running, you'll see a keycap icon in your menu bar.

- **Click the icon** to see your keystroke count and recent drops
- **Keep typing** — keycaps drop randomly as you type (0.6% chance per keystroke)
- **Drop notification** — a popover appears below the menu bar icon when you get a new keycap

### Rarity Tiers

| Rarity | Drop Rate | Color |
|--------|-----------|-------|
| Common | 60% | Gray |
| Uncommon | 25% | Green |
| Rare | 10% | Blue |
| Epic | 4% | Purple |
| Legendary | 1% | Orange |

## Tech Stack

- **Swift + SwiftUI** (macOS 13.0+)
- **CGEvent tap** (Listen-Only) for global keystroke counting
- **Combine** for reactive data flow
- **JSON** for local persistence (`~/Library/Application Support/CapCha/`)

## Build from Source

```bash
# Install xcodegen
brew install xcodegen

# Generate Xcode project
xcodegen generate

# Build
xcodebuild -project CapCha.xcodeproj -scheme CapCha -configuration Release build
```

## Documentation

- [DESIGN.md](./DESIGN.md) — Architecture design document (Korean)
- [docs/DESIGN.en.md](./docs/DESIGN.en.md) — Architecture design document (English)

## Privacy

CapCha uses macOS Input Monitoring permission to count keystrokes.
**We never read, store, or transmit what you type.** Only the keystroke count is tracked.

## License

TBD
