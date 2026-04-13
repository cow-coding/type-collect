# CapCha - Architecture Design Document

## 1. Overview

**CapCha** is a macOS menu bar app that automatically collects virtual keycap items as you type in your everyday work (development, office tasks, etc.).

Inspired by Steam's "Banana" clicker game, but instead of clicking, you collect items simply by **typing as you normally would**, making it fully compatible with your daily workflow.

### Key Principles

- **Privacy First**: Never stores keystroke content. Only counts are collected
- **Zero Interruption**: Runs quietly in the background, with lightweight notifications only on drops
- **Joy of Collecting**: Gacha system + pity system to maintain a healthy sense of anticipation

---

## 2. Tech Stack

| Category | Choice | Reason |
|----------|--------|--------|
| Language | Swift 5.9+ | macOS native, best performance |
| UI Framework | SwiftUI | Declarative UI, well-suited for menu bar apps |
| Target | macOS 13.0+ | Minimum version supporting MenuBarExtra |
| Keyboard API | CGEvent tap (Listen-Only) | Global input detection, requires only Input Monitoring permission |
| Persistence | JSON (Application Support) | Suitable for MVP, easy to debug |
| Architecture | MVVM + Combine | Reactive data flow |

---

## 3. Project Structure

```
CapCha/
├── CapCha.xcodeproj
├── CapCha/
│   ├── App/
│   │   ├── CapChaApp.swift              # @main, MenuBarExtra scene
│   │   ├── AppDelegate.swift                 # NSApplicationDelegate lifecycle
│   │   ├── AppState.swift                    # Central state management (ObservableObject)
│   │   └── Info.plist                        # LSUIElement = YES
│   │
│   ├── Core/
│   │   ├── KeystrokeMonitor.swift            # CGEvent tap, global key counting
│   │   ├── PermissionManager.swift           # Input Monitoring permission management
│   │   ├── DropEngine.swift                  # Gacha/drop probability system
│   │   └── SessionTracker.swift              # Keystroke batch -> drop evaluation bridge
│   │
│   ├── Models/
│   │   ├── Keycap.swift                      # Keycap item model
│   │   ├── Rarity.swift                      # Rarity enum (Common~Legendary)
│   │   ├── KeycapCatalog.swift               # Full keycap definitions loader
│   │   ├── Collection.swift                  # User collection data
│   │   ├── UserStats.swift                   # Typing statistics model
│   │   └── DropEvent.swift                   # Drop event record
│   │
│   ├── Persistence/
│   │   ├── StorageManager.swift              # JSON file read/write
│   │   ├── CollectionStore.swift             # Collection CRUD
│   │   └── StatsStore.swift                  # Stats CRUD
│   │
│   ├── ViewModels/
│   │   ├── MenuBarViewModel.swift            # Menu bar popover state
│   │   ├── CollectionViewModel.swift         # Collection window state
│   │   └── DropNotificationViewModel.swift   # Drop toast state
│   │
│   ├── Views/
│   │   ├── MenuBar/
│   │   │   ├── MenuBarContentView.swift      # Menu bar popover main view
│   │   │   ├── QuickStatsView.swift          # Today's typing count, streak
│   │   │   ├── RecentDropsView.swift         # Last 3 drops
│   │   │   └── MenuBarFooterView.swift       # Open collection, settings, quit
│   │   │
│   │   ├── Collection/
│   │   │   ├── CollectionWindowView.swift    # Collection grid window
│   │   │   ├── KeycapCardView.swift          # Keycap card (grid item)
│   │   │   ├── KeycapDetailView.swift        # Keycap detail sheet
│   │   │   ├── RarityFilterView.swift        # Filter by rarity
│   │   │   └── CollectionStatsBar.swift      # Collection progress bar
│   │   │
│   │   ├── Drop/
│   │   │   ├── DropToastView.swift           # Drop notification toast
│   │   │   └── DropCelebrationView.swift     # Rare+ drop special animation
│   │   │
│   │   ├── Onboarding/
│   │   │   ├── PermissionRequestView.swift   # Permission request guide
│   │   │   └── WelcomeView.swift             # First-run introduction
│   │   │
│   │   └── Shared/
│   │       ├── RarityBadgeView.swift         # Rarity color badge
│   │       ├── KeycapImageView.swift         # Keycap visual rendering
│   │       └── AnimatedCounter.swift         # Number animation
│   │
│   ├── Resources/
│   │   ├── Assets.xcassets/                  # App icon, menu bar icon, keycap images
│   │   ├── Sounds/                           # Rarity-specific drop sound effects
│   │   └── KeycapDefinitions.json            # 120 keycap catalog
│   │
│   └── Utilities/
│       ├── Constants.swift                   # App constants
│       └── DateHelpers.swift                 # Date utilities
│
└── CapChaTests/
    ├── DropEngineTests.swift
    ├── SessionTrackerTests.swift
    └── KeycapCatalogTests.swift
```

---

## 4. Data Flow

```
CGEvent tap (kernel)
    │
    ▼
KeystrokeMonitor (@Published count)
    │
    ▼  Combine subscription, batched per 10 keystrokes
SessionTracker
    │
    ├──▶ StatsStore (save statistics)
    │
    ▼
DropEngine.evaluateDrop(...)
    │
    ├──▶ nil (no drop)
    │
    └──▶ Keycap (drop occurred!)
            │
            ├──▶ CollectionStore (save item)
            │
            └──▶ DropToast (notify user)
```

---

## 5. Core Modules

### 5.1 KeystrokeMonitor

The core module for global keyboard input counting.

- Uses `CGEvent.tapCreate(tap:place:options:eventsOfInterest:callback:userInfo:)`
- **`.listenOnly`** mode: does not modify or block events
- Event mask: detects only `keyDown` (excludes key-up to prevent double counting)
- Callback function: only increments counter by 1, never reads key content
- Automatically re-enables if the system disables the tap (`.tapDisabledByTimeout`)

**Permission**: `CGPreflightListenEventAccess()` / `CGRequestListenEventAccess()` -- requires only Input Monitoring permission (less intimidating than Accessibility).

### 5.2 DropEngine

3-stage gacha system:

**Stage A -- Drop Evaluation**

| Keystrokes since last drop | Drop chance (per 10 keys) |
|---|---|
| 0 ~ 499 | 0.3% |
| 500 ~ 999 | 0.5% -> 1.5% (linear increase) |
| 1,000 ~ 1,999 | 1.5% -> 5.0% (linear increase) |
| 2,000 ~ 2,999 | 5.0% -> 100% (linear increase) |
| 3,000+ | **100% (guaranteed drop)** |

Based on an average developer typing 5,000-8,000 keystrokes per day, this yields roughly **5-15 drops per day**.

**Stage B -- Rarity Determination**

| Rarity | Base chance | Pity |
|--------|-------------|------|
| Common | 60% | - |
| Uncommon | 25% | - |
| Rare | 10% | Guaranteed after 20 consecutive drops without one |
| Epic | 4% | Guaranteed after 80 consecutive drops without one |
| Legendary | 1% | Guaranteed after 500 consecutive drops without one |

**Stage C -- Keycap Selection**

- 70% priority for unowned keycaps (collection protection)
- 30% chance from the entire pool at random (duplicates possible)

### 5.3 Bonus System

| Bonus | Multiplier | Condition |
|-------|------------|-----------|
| Daily first drop | 2.0x | First drop of the day |
| 3+ day streak | 1.2x | 100+ keystrokes per day |
| 7+ day streak | 1.5x | |
| 30+ day streak | 2.0x | |
| Speed burst | 1.3x | 1,000 keystrokes within 5 minutes |
| Milestone | 3.0x | Every 10,000 total keystrokes |

Multipliers are applied to the rarity weights for Rare and above during rarity determination.

### 5.4 Milestone Drops

| Total keystrokes | Reward |
|---|---|
| 1,000 | Guaranteed drop (normal rarity) |
| 10,000 | Guaranteed drop (3x rarity boost) |
| 50,000 | Rare+ guaranteed |
| 100,000 | Epic+ guaranteed |
| 500,000 | Epic+ guaranteed (special milestone keycap) |
| 1,000,000 | Legendary guaranteed (unique "Millionaire" keycap) |

---

## 6. Data Models

### Keycap

```swift
struct Keycap: Identifiable, Codable, Hashable {
    let id: String                  // "mech-cherry-red-common-001"
    let name: String                // "Cherry Red Classic"
    let rarity: Rarity
    let setName: String             // "Mechanical Classics"
    let description: String         // Flavor text
    let imageName: String           // Asset catalog reference
    let primaryColor: String        // Keycap body color (Hex)
    let legendColor: String         // Keycap legend color (Hex)
    let legendCharacter: String     // Legend character ("A", "Esc", etc.)
    let profile: KeycapProfile      // Cherry, SA, DSA, OEM, XDA, MT3
}
```

### Rarity

```swift
enum Rarity: String, Codable, CaseIterable, Comparable {
    case common       // 60%
    case uncommon     // 25%
    case rare         // 10%
    case epic         // 4%
    case legendary    // 1%
}
```

### CollectedKeycap

```swift
struct CollectedKeycap: Identifiable, Codable {
    let id: UUID
    let keycap: Keycap
    let collectedAt: Date
    let keystrokeNumber: Int        // Which keystroke number triggered this drop
    let dropContext: DropContext     // standard, pity, milestone, dailyBonus, streakBonus
}
```

### UserStats

```swift
struct UserStats: Codable {
    var totalKeystrokesAllTime: Int
    var dailyStats: [DayStats]
    var currentDayStreak: Int
    var longestDayStreak: Int
    var totalItemsCollected: Int
    var keystrokesSinceLastDrop: Int
    var keystrokesSinceLastRareOrAbove: Int
    var keystrokesSinceLastEpicOrAbove: Int
    var keystrokesSinceLastLegendary: Int
}
```

---

## 7. UI Design

### 7.1 Menubar Popover

```
┌──────────────────────────────────┐
│  ⌨️ CapCha                  │
├──────────────────────────────────┤
│                                  │
│  Today: 3,247 keystrokes         │
│  ████████████░░░  (65% to next)  │
│                                  │
│  Total: 47,891 | Streak: 5 days  │
│                                  │
├──────── Recent Drops ────────────┤
│                                  │
│  🟢 Cherry Red Classic    2m ago │
│  🟢 Alps Blue Switch     18m ago │
│  🟣 Holy Panda             1h ago│
│                                  │
├──────────────────────────────────┤
│  📦 Collection (42/120)          │
│  [Open Collection]  [Settings]   │
│                                  │
│  ─────────────────────────────── │
│  [Quit CapCha]              │
└──────────────────────────────────┘
```

- Uses `MenuBarExtra`'s `.window` style
- Width: 320pt, compact information display

### 7.2 Collection Window

- `NavigationSplitView`: sidebar (rarity filter) + detail (keycap grid)
- `LazyVGrid`: keycap card grid layout
- Card click opens a detail sheet (keycap image, name, description, acquisition date, rarity)
- Default window size: 720x540pt

### 7.3 Drop Toast

- `NSPanel` (`.nonactivatingPanel`): floating window that does not steal focus
- Displayed in the upper-right corner of the screen
- Common/Uncommon: shown for 3 seconds
- Rare and above: 5 seconds + special animation
- Rarity-specific sound effects

---

## 8. Art Style & Asset Pipeline

### 8.1 Art Direction: Isometric Pixel Art

Keycaps are rendered in **isometric (axonometric) pixel art**. Rather than a flat top-down view, they use a diagonal overhead perspective that creates a sense of depth.

- The keycap's **top, front, and side** faces are all visible, creating a 3D feel
- Profile height differences are visually apparent (Cherry is low, SA is tall)
- Rich rarity-tier effects (gloss, translucent resin, glow, etc.)
- Looks like a real keyboard in the keyboard assembly view

**Sprite size**: 32x32 or 48x48 pixels

### 8.2 Asset Creation Tools

#### Pixel Art Editors

| Tool | Price | Platform | Isometric support | Notes |
|------|-------|----------|-------------------|-------|
| **Aseprite** | $19.99 (one-time) | Win/Mac/Linux | Via Pixthic extension | Industry standard, active community |
| **Pixelorama** | Free (open-source) | Win/Mac/Linux | Native tilemap support | Excellent free alternative |
| **Pixaki** | $24.99 | iPad only | Native angle lock | Best option if you have an iPad |
| **GraphicsGale** | Free | Win/Mac | General | Specialized for animation |

**Recommended**: Aseprite ($19.99) + Pixthic extension (isometric grid support)

#### AI-Assisted Generation

| Tool | Price | Use case |
|------|-------|----------|
| **PixelLab** | $9-50/mo | Aseprite plugin, auto-generates 4/8-directional sprites |
| **Midjourney** | $10/mo+ | Isometric reference generation (prompt: `isometric pixel art keycap, 32x32, --v 4`) |
| **Stable Diffusion + Pixel Art XL LoRA** | Free (local) | Consistent local pixel art generation, no trigger word needed |
| **8bitdiffuser** | Free (local) | Specialized for retro 8-bit style |

**Recommended workflow**:
1. Generate 10-15 references with Midjourney/SD
2. Manual refinement and style unification in Aseprite
3. Batch generation of variations with PixelLab

#### Programmatic Generation

| Tool/Library | Language | Use case |
|-------------|----------|----------|
| **ProceduralPixelArt** | Python | Procedural isometric pixel art generation |
| **Sprite-Generator** | Python | Template mask-based variant generation (color, brightness, saturation parameters) |
| **Pillow (PIL)** | Python | Image manipulation, pixel-level control |
| **Lospec Palettes** | Web | Curated pixel art color palette collection |

### 8.3 Template-Based Production Pipeline

A template system for efficiently producing 120+ keycaps:

**Step 1: Create per-profile base templates (6 total)**
- Cherry, SA, DSA, OEM, XDA, MT3 profiles
- Each template separates top/front/side areas in isometric pixel art
- Hand-crafted in Aseprite

**Step 2: Define rarity-specific color palettes**
- Common: achromatic, monochrome
- Uncommon: pastel two-tone
- Rare: high-saturation colors + border highlights
- Epic: gradient + gloss pixels
- Legendary: special effects (translucent, glow, animated frames)

**Step 3: Combine with Python scripts**

```python
# Pseudocode
base = load_template("cherry_mx_base.png")
palette = load_palette("neon_pastel")
legend = render_legend("A", font="pixel_5x5")
keycap = composite(base, palette, legend)
save_sprite(keycap, "cherry-neon-A.png")
```

**Step 4: Legendary-tier keycaps are hand-crafted individually**

#### Estimated Production Time (Solo Developer)

| Approach | Cost | Time | Quality |
|----------|------|------|---------|
| Fully hand-crafted | $20 | 480-960 hours | Best consistency |
| AI + manual refinement | $120-520 | 120-200 hours | Requires refinement |
| Template + batch generation | $120-220 | 40-80 hours | High consistency |
| **Hybrid (AI + template)** | **$220-520** | **60-120 hours** | **Recommended** |

#### Asset Folder Structure

```
assets/
├── keycaps/
│   ├── templates/            # Per-profile base templates (6)
│   │   ├── cherry_mx_base.aseprite
│   │   ├── sa_profile_base.aseprite
│   │   └── ...
│   ├── palettes/             # Rarity-specific color palettes
│   │   ├── common.json
│   │   ├── legendary.json
│   │   └── ...
│   ├── generated/            # AI/script generation output
│   │   ├── batch_midjourney/
│   │   └── batch_pixellab/
│   ├── final/                # Final sprites
│   │   ├── keycaps_32x32.png   (sprite sheet)
│   │   └── keycaps.json        (metadata)
│   └── scripts/              # Generation scripts
│       ├── generate_sprites.py
│       └── apply_palette.py
├── keyboards/                # Keyboard assembly assets
│   ├── boards/               # Keyboard board bases
│   └── layouts/              # Layout definition JSON
└── sounds/                   # Rarity-specific sound effects
```

### 8.4 3D Voxel Art & Rotation (Research Findings)

Research results on creating keycaps as 3D voxels that can be rotated and viewed from multiple angles.

#### Voxel Art Creation Tools

| Tool | Price | Export formats | Notes |
|------|-------|---------------|-------|
| **MagicaVoxel** | Free | OBJ, PLY, ISO sprites | Industry standard, well-suited for keycaps |
| **Goxel** | Free (open-source) | glTF2, OBJ, PLY | Lightweight, macOS support |
| **Blockbench** | Free | OBJ, glTF | Web-based, Minecraft style |

#### 3D Rendering Options on macOS

| Framework | Status | Suitability |
|-----------|--------|-------------|
| **RealityKit + RealityView** | Currently Apple-recommended | SwiftUI integration, loads glTF2/USDZ |
| **SceneKit** | Deprecated as of WWDC 2025 | Reference for existing code, not recommended for new projects |
| **Model3D** | visionOS only | Not available on macOS |
| **Metal** | Low-level GPU | Custom voxel rendering possible but overkill |

#### 3D Rotation Implementation Comparison

| Approach | Feasibility | Resource overhead | Development difficulty |
|----------|-------------|-------------------|----------------------|
| **Pre-rendered sprites (8-16 angles)** | 5/5 | Minimal | Low |
| **Real-time 3D grid** | 2/5 | High | High |
| **Hybrid (sprites + detailed 3D)** | 4/5 | Low-Medium | Medium |

#### Recommendation: Hybrid Approach

**Normal view (grid/list)**:
- Display as pre-rendered isometric sprites
- Zero GPU load, suitable for a menu bar app

**Detail view (on keycap click)**:
- Load 3D voxel model via RealityView
- 360-degree rotation via drag
- Lazy loading -- render only when needed

#### 3D Asset Pipeline

```
MagicaVoxel (.vox)
    │
    ├──▶ ISO export -> 8-16 angle sprite PNGs (for grid)
    │
    └──▶ OBJ export
            │
            ▼
        Blender (OBJ -> glTF2 conversion + optimization)
            │
            ▼
        .glb file (for detail view 3D rotation)
```

#### IsoVoxel Tool
- Automatically converts `.vox` files to isometric PNG sprites
- Supports batch processing -> render all 120 keycaps at multiple angles at once

#### Estimated File Sizes

| Asset type | Per keycap | Total for 120 |
|------------|-----------|---------------|
| Sprites (8 angles) | ~50KB | ~6MB |
| 3D model (.glb) | ~200KB | ~24MB |
| **Total** | | **~30MB** |

Light enough for a menu bar app.

---

## 9. Keyboard Assembly System

### 9.1 Concept

A system where you place your collected keycaps onto a keyboard board to **build your own custom keyboard**. It gives purpose to collecting and lets you share your completed keyboards.

### 9.2 Keyboard Board Types

| Board | Key count | Difficulty | Unlock condition |
|-------|-----------|------------|-----------------|
| 40% | 40 keys | Beginner | Provided by default |
| 60% | 61 keys | Intermediate | Collect 30 total keycaps |
| TKL (80%) | 87 keys | Advanced | Collect 60 total keycaps |
| Full (100%) | 104 keys | Hardcore | Collect 100 total keycaps |

### 9.3 Assembly Rules

- Place keycaps in matching slots (A-legend keycap goes in the A key slot)
- Filling with the same set grants a **set bonus** (special visual effects, title)
- Filling with the same rarity grants a **rarity bonus** (glowing border, etc.)
- Empty slots shown as gray silhouettes -> the keyboard fills in as you collect more
- Build multiple keyboards for your collection

### 9.4 Assembly UI

The entire keyboard rendered in isometric pixel art style:

```
  ╱──╲╱──╲╱──╲╱──╲╱──╲╱──╲╱──╲╱──╲╱──╲╱──╲
 ╱ ~ ╲╱ 1 ╲╱ 2 ╲╱ 3 ╲╱ 4 ╲╱ 5 ╲╱ 6 ╲╱ 7 ╲╱ 8 ╲╱ 9 ╲
│    ││    ││    ││░░░░││    ││    ││    ││    ││░░░░││    │
 ╲──╱╲──╱╲──╱╲──╱╲──╱╲──╱╲──╱╲──╱╲──╱╲──╱
  ╱──╲╱──╲╱──╲╱──╲╱──╲╱──╲╱──╲╱──╲╱──╲
 ╱Tab╲╱ Q ╲╱ W ╲╱ E ╲╱ R ╲╱ T ╲╱ Y ╲╱ U ╲╱ I ╲
│    ││    ││    ││░░░░││    ││    ││    ││    ││    │
 ╲──╱╲──╱╲──╱╲──╱╲──╱╲──╱╲──╱╲──╱╲──╱

░░░░ = Empty slot (not yet collected)
```

### 9.5 Sharing

- Save/share completed keyboards as **profile card images**
- Auto-generate images for social media sharing (isometric keyboard rendering)
- Future: browse other users' keyboards

### 9.6 Data Model

```swift
struct KeyboardBuild: Identifiable, Codable {
    let id: UUID
    var name: String                     // "My Daily Driver"
    let layout: KeyboardLayout           // forty, sixty, tkl, full
    var slots: [KeySlot]                 // Slot array per layout
    let createdAt: Date
    var completionRate: Double           // 0.0 ~ 1.0
}

struct KeySlot: Identifiable, Codable {
    let id: String                       // "key-A", "key-Esc", etc.
    let position: SlotPosition           // Isometric coordinates
    let expectedLegend: String           // Character expected for this slot
    var assignedKeycap: CollectedKeycap? // nil means empty slot
}

enum KeyboardLayout: String, Codable {
    case forty      // 40%
    case sixty      // 60%
    case tkl        // 80% (TKL)
    case full       // 100% (Full)

    var slotCount: Int { ... }
}
```

---

## 10. Keycap Catalog (MVP: 120 keycaps)

| Set name | Common | Uncommon | Rare | Epic | Legendary | Total |
|----------|--------|----------|------|------|-----------|-------|
| Mechanical Classics | 10 | 5 | 3 | 1 | 1 | 20 |
| Retro Computing | 10 | 5 | 3 | 1 | 1 | 20 |
| Artisan Collection | 5 | 5 | 5 | 3 | 2 | 20 |
| Nature Elements | 10 | 5 | 3 | 1 | 1 | 20 |
| Space Theme | 8 | 5 | 4 | 2 | 1 | 20 |
| Milestone Specials | 0 | 5 | 7 | 5 | 3 | 20 |
| **Total** | **43** | **30** | **25** | **13** | **9** | **120** |

---

## 11. Persistence

- Storage location: `~/Library/Application Support/CapCha/`
- Files: `collection.json`, `stats.json`, `settings.json`
- Save timing: on drop events, every 60-second interval, on app termination (`applicationWillTerminate`)
- Does not save on every keystroke (performance protection)

---

## 12. App Configuration

- `LSUIElement = YES`: hidden from Dock and Cmd-Tab
- Deployment Target: macOS 13.0
- Code signing required (for CGEvent tap usage)
- Distributed without App Sandbox (for unrestricted Input Monitoring permission usage)

---

## 13. Known Challenges & Mitigations

| Issue | Mitigation |
|-------|------------|
| CGEvent tap disabled by the system | Auto re-enable via `.tapDisabledByTimeout` handling |
| Events not received after system sleep/screen lock | Subscribe to `NSWorkspace` sleep/wake notifications to restart tap |
| Permission revoked at runtime | Poll `CGPreflightListenEventAccess()` every 30 seconds |
| Toast steals focus | `NSPanel(.nonactivatingPanel)` + `.floating` level |
| SettingsLink not working in MenuBarExtra | Open via `NSApp.sendAction` or Window scene ID |

---

## 14. Implementation Phases

### Phase 1 — MVP ✅
- Menu bar app + global keystroke counting (CGEvent tap, tailAppend, listenOnly)
- Dynamic keycap generation (87 TKL keys × 5 sets × 6 rarities = 2,610 combinations)
- Gacha drop system + pity system
- Rarity visual effects (glow, outline, shine, Eternal prismatic animation)
- Collection window (sidebar + isometric keycap grid)
- Duplicate counting + optimized storage
- Settings screen (Launch at Login, notification toggle)
- Local JSON persistence + data migration
- GitHub Actions DMG release
- Security audit completed
- Apache 2.0 license

### Phase 2 — Contents
- Keyboard assembly system (build custom keyboards with collected keycaps)
- Special key designs (Space, Shift, Enter with different shapes)
- Unowned keycap priority selection (duplicate prevention)
- Seasonal/limited keycaps (time-limited sets)
- Demo GIF (app walkthrough for README)

### Phase 3 — Business
- Item trading/sharing between users
- In-house trade server
- JSON integrity verification (HMAC/checksum)
- ID hash system (tamper prevention)
- Apple Developer signing + notarization (Gatekeeper/permission fix)
- Achievement system
- Statistics dashboard (daily/weekly typing analysis)
