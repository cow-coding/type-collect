# TypeCollect - Architecture Design Document

## 1. Overview

**TypeCollect**은 macOS 메뉴바 상주 앱으로, 일상적인 타이핑(개발, 업무 등)을 하면 자동으로 가상 키캡 아이템이 수집되는 게임입니다.

Steam의 "Banana" 클리커 게임에서 영감을 받았지만, 클릭 대신 **평소 타이핑만으로** 아이템을 모을 수 있어 업무와 병행이 가능합니다.

### Key Principles

- **프라이버시 최우선**: 키 입력 내용은 절대 저장하지 않음. 카운트만 수집
- **제로 인터럽트**: 백그라운드에서 조용히 동작, 드롭 시에만 가볍게 알림
- **수집의 재미**: 가챠 시스템 + 천장 시스템으로 적절한 기대감 유지

---

## 2. Tech Stack

| 항목 | 선택 | 이유 |
|------|------|------|
| Language | Swift 5.9+ | macOS 네이티브, 최고 성능 |
| UI Framework | SwiftUI | 선언형 UI, 메뉴바 앱에 적합 |
| Target | macOS 13.0+ | MenuBarExtra 지원 최소 버전 |
| Keyboard API | CGEvent tap (Listen-Only) | 글로벌 입력 감지, Input Monitoring 권한만 필요 |
| Persistence | JSON (Application Support) | MVP에 적합, 디버깅 용이 |
| Architecture | MVVM + Combine | 리액티브 데이터 흐름 |

---

## 3. Project Structure

```
TypeCollect/
├── TypeCollect.xcodeproj
├── TypeCollect/
│   ├── App/
│   │   ├── TypeCollectApp.swift              # @main, MenuBarExtra 씬
│   │   ├── AppDelegate.swift                 # NSApplicationDelegate 라이프사이클
│   │   ├── AppState.swift                    # 중앙 상태 관리 (ObservableObject)
│   │   └── Info.plist                        # LSUIElement = YES
│   │
│   ├── Core/
│   │   ├── KeystrokeMonitor.swift            # CGEvent tap, 글로벌 키 카운팅
│   │   ├── PermissionManager.swift           # Input Monitoring 권한 관리
│   │   ├── DropEngine.swift                  # 가챠/드롭 확률 시스템
│   │   └── SessionTracker.swift              # 키스트로크 배치 → 드롭 판정 연결
│   │
│   ├── Models/
│   │   ├── Keycap.swift                      # 키캡 아이템 모델
│   │   ├── Rarity.swift                      # 등급 enum (Common~Legendary)
│   │   ├── KeycapCatalog.swift               # 전체 키캡 정의 로드
│   │   ├── Collection.swift                  # 유저 수집 데이터
│   │   ├── UserStats.swift                   # 타이핑 통계 모델
│   │   └── DropEvent.swift                   # 드롭 이벤트 기록
│   │
│   ├── Persistence/
│   │   ├── StorageManager.swift              # JSON 파일 읽기/쓰기
│   │   ├── CollectionStore.swift             # 컬렉션 CRUD
│   │   └── StatsStore.swift                  # 통계 CRUD
│   │
│   ├── ViewModels/
│   │   ├── MenuBarViewModel.swift            # 메뉴바 팝오버 상태
│   │   ├── CollectionViewModel.swift         # 컬렉션 윈도우 상태
│   │   └── DropNotificationViewModel.swift   # 드롭 토스트 상태
│   │
│   ├── Views/
│   │   ├── MenuBar/
│   │   │   ├── MenuBarContentView.swift      # 메뉴바 팝오버 메인
│   │   │   ├── QuickStatsView.swift          # 오늘 타이핑 수, 스트릭
│   │   │   ├── RecentDropsView.swift         # 최근 드롭 3개
│   │   │   └── MenuBarFooterView.swift       # 컬렉션 열기, 설정, 종료
│   │   │
│   │   ├── Collection/
│   │   │   ├── CollectionWindowView.swift    # 컬렉션 그리드 윈도우
│   │   │   ├── KeycapCardView.swift          # 키캡 카드 (그리드 아이템)
│   │   │   ├── KeycapDetailView.swift        # 키캡 상세 시트
│   │   │   ├── RarityFilterView.swift        # 등급별 필터
│   │   │   └── CollectionStatsBar.swift      # 수집 진행도 바
│   │   │
│   │   ├── Drop/
│   │   │   ├── DropToastView.swift           # 드롭 알림 토스트
│   │   │   └── DropCelebrationView.swift     # Rare+ 드롭 특수 애니메이션
│   │   │
│   │   ├── Onboarding/
│   │   │   ├── PermissionRequestView.swift   # 권한 요청 가이드
│   │   │   └── WelcomeView.swift             # 첫 실행 안내
│   │   │
│   │   └── Shared/
│   │       ├── RarityBadgeView.swift         # 등급 컬러 뱃지
│   │       ├── KeycapImageView.swift         # 키캡 비주얼 렌더링
│   │       └── AnimatedCounter.swift         # 숫자 애니메이션
│   │
│   ├── Resources/
│   │   ├── Assets.xcassets/                  # 앱 아이콘, 메뉴바 아이콘, 키캡 이미지
│   │   ├── Sounds/                           # 등급별 드롭 효과음
│   │   └── KeycapDefinitions.json            # 120개 키캡 카탈로그
│   │
│   └── Utilities/
│       ├── Constants.swift                   # 앱 상수
│       └── DateHelpers.swift                 # 날짜 유틸
│
└── TypeCollectTests/
    ├── DropEngineTests.swift
    ├── SessionTrackerTests.swift
    └── KeycapCatalogTests.swift
```

---

## 4. Data Flow

```
CGEvent tap (커널)
    │
    ▼
KeystrokeMonitor (@Published count)
    │
    ▼  Combine 구독, 10키 단위 배치
SessionTracker
    │
    ├──▶ StatsStore (통계 저장)
    │
    ▼
DropEngine.evaluateDrop(...)
    │
    ├──▶ nil (드롭 없음)
    │
    └──▶ Keycap (드롭 발생!)
            │
            ├──▶ CollectionStore (아이템 저장)
            │
            └──▶ DropToast (유저에게 알림)
```

---

## 5. Core Modules

### 5.1 KeystrokeMonitor

글로벌 키보드 입력 카운팅의 핵심 모듈.

- `CGEvent.tapCreate(tap:place:options:eventsOfInterest:callback:userInfo:)` 사용
- **`.listenOnly`** 모드: 이벤트를 수정/차단하지 않음
- 이벤트 마스크: `keyDown`만 감지 (key-up 제외하여 중복 카운트 방지)
- 콜백 함수: 카운터 +1만 수행, 키 내용은 절대 읽지 않음
- 시스템이 tap을 비활성화할 경우 (`.tapDisabledByTimeout`) 자동 재활성화

**권한**: `CGPreflightListenEventAccess()` / `CGRequestListenEventAccess()` — Input Monitoring 권한만 필요 (Accessibility보다 덜 무서움).

### 5.2 DropEngine

3단계 가챠 시스템:

**A단계 — 드롭 여부 판정**

| 마지막 드롭 이후 키스트로크 | 드롭 확률 (10키당) |
|---|---|
| 0 ~ 499 | 0.3% |
| 500 ~ 999 | 0.5% → 1.5% (선형 증가) |
| 1,000 ~ 1,999 | 1.5% → 5.0% (선형 증가) |
| 2,000 ~ 2,999 | 5.0% → 100% (선형 증가) |
| 3,000+ | **100% (확정 드롭)** |

개발자 하루 평균 5,000~8,000키 입력 기준, 하루 약 **5~15회 드롭**.

**B단계 — 등급 결정**

| 등급 | 기본 확률 | 천장 |
|------|-----------|------|
| Common | 60% | - |
| Uncommon | 25% | - |
| Rare | 10% | 20드롭 연속 없으면 확정 |
| Epic | 4% | 80드롭 연속 없으면 확정 |
| Legendary | 1% | 500드롭 연속 없으면 확정 |

**C단계 — 키캡 선택**

- 미보유 키캡 70% 우선 선택 (도감 보호)
- 30% 확률로 전체 풀에서 랜덤 (중복 가능)

### 5.3 Bonus System

| 보너스 | 배율 | 조건 |
|--------|------|------|
| 일일 첫 드롭 | 2.0x | 매일 첫 드롭 |
| 연속 출석 3일+ | 1.2x | 매일 100키 이상 입력 |
| 연속 출석 7일+ | 1.5x | |
| 연속 출석 30일+ | 2.0x | |
| 속도 버스트 | 1.3x | 5분 내 1,000키 달성 |
| 마일스톤 | 3.0x | 총 10,000키마다 |

배율은 등급 결정 시 Rare 이상의 가중치에 곱셈 적용.

### 5.4 Milestone Drops

| 총 키스트로크 | 보상 |
|---|---|
| 1,000 | 확정 드롭 (일반 등급) |
| 10,000 | 확정 드롭 (3x 등급 부스트) |
| 50,000 | Rare+ 확정 |
| 100,000 | Epic+ 확정 |
| 500,000 | Epic+ 확정 (특별 마일스톤 키캡) |
| 1,000,000 | Legendary 확정 (유니크 "Millionaire" 키캡) |

---

## 6. Data Models

### Keycap

```swift
struct Keycap: Identifiable, Codable, Hashable {
    let id: String                  // "mech-cherry-red-common-001"
    let name: String                // "Cherry Red Classic"
    let rarity: Rarity
    let setName: String             // "Mechanical Classics"
    let description: String         // 플레이버 텍스트
    let imageName: String           // Asset catalog 참조
    let primaryColor: String        // 키캡 바디 색상 (Hex)
    let legendColor: String         // 키캡 각인 색상 (Hex)
    let legendCharacter: String     // 각인 문자 ("A", "Esc" 등)
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
    let keystrokeNumber: Int        // 몇 번째 키스트로크에서 드롭됐는지
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
│  ⌨️ TypeCollect                  │
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
│  [Quit TypeCollect]              │
└──────────────────────────────────┘
```

- `MenuBarExtra`의 `.window` 스타일 사용
- 너비 320pt, 컴팩트한 정보 표시

### 7.2 Collection Window

- `NavigationSplitView`: 사이드바(등급 필터) + 디테일(키캡 그리드)
- `LazyVGrid`: 키캡 카드 그리드 레이아웃
- 카드 클릭 시 상세 시트 (키캡 이미지, 이름, 설명, 획득일, 등급)
- 기본 윈도우 크기: 720x540pt

### 7.3 Drop Toast

- `NSPanel` (`.nonactivatingPanel`): 포커스를 뺏지 않는 플로팅 윈도우
- 화면 우상단에 표시
- Common/Uncommon: 3초 표시
- Rare 이상: 5초 + 특수 애니메이션
- 등급별 효과음

---

## 8. Keycap Catalog (MVP: 120개)

| 세트 이름 | Common | Uncommon | Rare | Epic | Legendary | 합계 |
|-----------|--------|----------|------|------|-----------|------|
| Mechanical Classics | 10 | 5 | 3 | 1 | 1 | 20 |
| Retro Computing | 10 | 5 | 3 | 1 | 1 | 20 |
| Artisan Collection | 5 | 5 | 5 | 3 | 2 | 20 |
| Nature Elements | 10 | 5 | 3 | 1 | 1 | 20 |
| Space Theme | 8 | 5 | 4 | 2 | 1 | 20 |
| Milestone Specials | 0 | 5 | 7 | 5 | 3 | 20 |
| **합계** | **43** | **30** | **25** | **13** | **9** | **120** |

---

## 9. Persistence

- 저장 위치: `~/Library/Application Support/TypeCollect/`
- 파일: `collection.json`, `stats.json`, `settings.json`
- 저장 시점: 드롭 발생 시, 60초 주기, 앱 종료 시 (`applicationWillTerminate`)
- 매 키스트로크마다 저장하지 않음 (성능 보호)

---

## 10. App Configuration

- `LSUIElement = YES`: Dock, Cmd-Tab에서 숨김
- Deployment Target: macOS 13.0
- 코드 서명 필요 (CGEvent tap 사용 시)
- App Sandbox 없이 직접 배포 (Input Monitoring 권한 자유 사용)

---

## 11. Known Challenges & Mitigations

| 문제 | 대응 |
|------|------|
| CGEvent tap이 시스템에 의해 비활성화 | `.tapDisabledByTimeout` 핸들링으로 자동 재활성화 |
| 시스템 Sleep/화면잠금 후 이벤트 못 받음 | `NSWorkspace` sleep/wake 알림 구독하여 tap 재시작 |
| 권한이 실행 중 취소됨 | 30초 주기로 `CGPreflightListenEventAccess()` 폴링 |
| 토스트가 포커스 빼앗음 | `NSPanel(.nonactivatingPanel)` + `.floating` 레벨 |
| MenuBarExtra에서 SettingsLink 미작동 | `NSApp.sendAction` 또는 Window 씬 ID로 직접 열기 |

---

## 12. Implementation Phases

### Phase 1 — MVP (현재)
- 메뉴바 앱 + 글로벌 키 카운팅
- 가챠 드롭 시스템 + 천장
- 키캡 컬렉션 UI
- 로컬 JSON 저장

### Phase 2 — Social
- 유저 간 아이템 거래/공유
- 자체 거래 서버 또는 Steam 연동 검토
- 친구 시스템, 컬렉션 공유 링크

### Phase 3 — Expansion
- 시즌 키캡 (기간 한정)
- 커스텀 키캡 디자인 (유저 제작)
- 통계 대시보드 (일별/주별 타이핑 분석)
- 업적 시스템
