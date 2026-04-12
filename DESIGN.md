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

## 8. Art Style & Asset Pipeline

### 8.1 Art Direction: Isometric Pixel Art

키캡을 **아이소메트릭(등각투영) 도트 아트**로 표현합니다. 위에서 내려다보는 평면이 아니라, 대각선 위에서 바라보는 입체적인 도트 스타일입니다.

- 키캡의 **윗면 + 앞면 + 옆면**이 동시에 보여 입체감 있음
- 프로필별 높이 차이가 시각적으로 드러남 (Cherry는 낮고, SA는 높고)
- 등급별 이펙트 표현이 풍부 (광택, 투명 레진, 빛남 등)
- 키보드 조립 화면에서 실제 키보드처럼 보임

**스프라이트 크기**: 32x32 또는 48x48 픽셀

### 8.2 Asset Creation Tools

#### Pixel Art 에디터

| 도구 | 가격 | 플랫폼 | 아이소메트릭 지원 | 비고 |
|------|------|--------|------------------|------|
| **Aseprite** | $19.99 (1회) | Win/Mac/Linux | Pixthic 확장으로 지원 | 업계 표준, 커뮤니티 활발 |
| **Pixelorama** | 무료 (오픈소스) | Win/Mac/Linux | 네이티브 타일맵 지원 | 무료 대안으로 우수 |
| **Pixaki** | $24.99 | iPad 전용 | 네이티브 각도 잠금 | iPad 있으면 최적 |
| **GraphicsGale** | 무료 | Win/Mac | 일반 | 애니메이션 특화 |

**추천**: Aseprite ($19.99) + Pixthic 확장 (아이소메트릭 그리드 지원)

#### AI 보조 생성

| 도구 | 가격 | 용도 |
|------|------|------|
| **PixelLab** | $9~50/월 | Aseprite 플러그인, 4/8방향 스프라이트 자동 생성 |
| **Midjourney** | $10/월~ | 아이소메트릭 레퍼런스 생성 (프롬프트: `isometric pixel art keycap, 32x32, --v 4`) |
| **Stable Diffusion + Pixel Art XL LoRA** | 무료 (로컬) | 로컬에서 일관된 픽셀아트 생성, 트리거 워드 불필요 |
| **8bitdiffuser** | 무료 (로컬) | 레트로 8비트 스타일 특화 |

**추천 워크플로우**:
1. Midjourney/SD로 10~15개 레퍼런스 생성
2. Aseprite에서 수동 보정 및 스타일 통일
3. PixelLab 배치 생성으로 변형 대량 생산

#### 프로그래밍 기반 생성

| 도구/라이브러리 | 언어 | 용도 |
|----------------|------|------|
| **ProceduralPixelArt** | Python | 아이소메트릭 픽셀아트 절차적 생성 |
| **Sprite-Generator** | Python | 템플릿 마스크 기반 변형 생성 (색상, 밝기, 채도 파라미터) |
| **Pillow (PIL)** | Python | 이미지 조작, 픽셀 단위 제어 |
| **Lospec Palettes** | 웹 | 검증된 픽셀아트 색상 팔레트 모음 |

### 8.3 Template-Based Production Pipeline

120개 이상의 키캡을 효율적으로 생산하기 위한 템플릿 시스템:

**Step 1: 프로필별 베이스 템플릿 제작 (6개)**
- Cherry, SA, DSA, OEM, XDA, MT3 프로필
- 각 템플릿은 아이소메트릭 도트로 윗면/앞면/옆면 영역 분리
- 수작업으로 Aseprite에서 제작

**Step 2: 등급별 색상 팔레트 정의**
- Common: 무채색, 단색
- Uncommon: 파스텔 투톤
- Rare: 채도 높은 컬러 + 테두리 하이라이트
- Epic: 그라데이션 + 광택 픽셀
- Legendary: 특수 이펙트 (투명, 빛남, 애니메이션 프레임)

**Step 3: Python 스크립트로 조합 생성**

```python
# 의사 코드
base = load_template("cherry_mx_base.png")
palette = load_palette("neon_pastel")
legend = render_legend("A", font="pixel_5x5")
keycap = composite(base, palette, legend)
save_sprite(keycap, "cherry-neon-A.png")
```

**Step 4: Legendary급은 수작업으로 특별 제작**

#### 예상 제작 기간 (솔로 개발자)

| 방식 | 비용 | 시간 | 품질 |
|------|------|------|------|
| 전부 수작업 | $20 | 480~960시간 | 최고 일관성 |
| AI + 수동 보정 | $120~520 | 120~200시간 | 보정 필요 |
| 템플릿 + 배치 생성 | $120~220 | 40~80시간 | 높은 일관성 |
| **하이브리드 (AI + 템플릿)** | **$220~520** | **60~120시간** | **추천** |

#### 에셋 폴더 구조

```
assets/
├── keycaps/
│   ├── templates/            # 프로필별 베이스 템플릿 (6개)
│   │   ├── cherry_mx_base.aseprite
│   │   ├── sa_profile_base.aseprite
│   │   └── ...
│   ├── palettes/             # 등급별 색상 팔레트
│   │   ├── common.json
│   │   ├── legendary.json
│   │   └── ...
│   ├── generated/            # AI/스크립트 생성 결과
│   │   ├── batch_midjourney/
│   │   └── batch_pixellab/
│   ├── final/                # 최종 스프라이트
│   │   ├── keycaps_32x32.png   (스프라이트 시트)
│   │   └── keycaps.json        (메타데이터)
│   └── scripts/              # 생성 스크립트
│       ├── generate_sprites.py
│       └── apply_palette.py
├── keyboards/                # 키보드 조립 에셋
│   ├── boards/               # 키보드 보드 베이스
│   └── layouts/              # 레이아웃 정의 JSON
└── sounds/                   # 등급별 효과음
```

### 8.4 3D Voxel Art & Rotation (리서치 결과)

키캡을 3D 복셀로 만들어 여러 각도에서 돌려볼 수 있는지 조사한 결과입니다.

#### Voxel Art 제작 도구

| 도구 | 가격 | 내보내기 형식 | 비고 |
|------|------|-------------|------|
| **MagicaVoxel** | 무료 | OBJ, PLY, ISO 스프라이트 | 업계 표준, 키캡에 적합 |
| **Goxel** | 무료 (오픈소스) | glTF2, OBJ, PLY | 가벼움, macOS 지원 |
| **Blockbench** | 무료 | OBJ, glTF | 웹 기반, Minecraft 스타일 |

#### macOS에서 3D 렌더링 옵션

| 프레임워크 | 상태 | 적합도 |
|-----------|------|--------|
| **RealityKit + RealityView** | 현재 Apple 추천 | SwiftUI 통합, glTF2/USDZ 로드 가능 |
| **SceneKit** | WWDC 2025부터 deprecated | 기존 코드 참고용, 신규 비추천 |
| **Model3D** | visionOS 전용 | macOS에서 사용 불가 |
| **Metal** | 저수준 GPU | 커스텀 복셀 렌더링 가능하나 오버킬 |

#### 3D 회전 구현 방식 비교

| 방식 | 실현 가능성 | 리소스 부하 | 개발 난이도 |
|------|-----------|------------|------------|
| **프리렌더 스프라이트 (8~16각도)** | ★★★★★ | 최소 | 낮음 |
| **실시간 3D 그리드** | ★★ | 높음 | 높음 |
| **하이브리드 (스프라이트 + 상세 3D)** | ★★★★ | 낮음~중간 | 중간 |

#### 추천: 하이브리드 방식

**평소 (그리드/목록)**:
- 프리렌더된 아이소메트릭 스프라이트로 표시
- GPU 부하 제로, 메뉴바 앱에 적합

**상세 보기 (키캡 클릭 시)**:
- RealityView로 3D 복셀 모델 로드
- 드래그로 360도 회전 가능
- Lazy 로딩으로 필요할 때만 렌더링

#### 3D 에셋 파이프라인

```
MagicaVoxel (.vox)
    │
    ├──▶ ISO 내보내기 → 8~16각도 스프라이트 PNG (그리드용)
    │
    └──▶ OBJ 내보내기
            │
            ▼
        Blender (OBJ → glTF2 변환 + 최적화)
            │
            ▼
        .glb 파일 (상세 보기 3D 회전용)
```

#### IsoVoxel 도구
- `.vox` 파일을 자동으로 아이소메트릭 PNG 스프라이트로 변환
- 배치 처리 가능 → 120개 키캡을 한번에 다각도 렌더링

#### 파일 크기 예상

| 에셋 유형 | 키캡 1개당 | 120개 합계 |
|-----------|-----------|-----------|
| 스프라이트 (8각도) | ~50KB | ~6MB |
| 3D 모델 (.glb) | ~200KB | ~24MB |
| **합계** | | **~30MB** |

메뉴바 앱으로서 충분히 가벼운 크기입니다.

---

## 9. Keyboard Assembly System

### 9.1 Concept

모은 키캡을 키보드 보드에 배치하여 **나만의 커스텀 키보드를 완성**하는 시스템입니다. 수집에 목적을 부여하고, 완성된 키보드를 공유할 수 있습니다.

### 9.2 Keyboard Board Types

| 보드 | 키 수 | 난이도 | 해금 조건 |
|------|-------|--------|----------|
| 40% | 40키 | 입문 | 기본 제공 |
| 60% | 61키 | 중급 | 총 30개 키캡 수집 |
| TKL (80%) | 87키 | 고급 | 총 60개 키캡 수집 |
| Full (100%) | 104키 | 하드코어 | 총 100개 키캡 수집 |

### 9.3 Assembly Rules

- 각 슬롯에 맞는 키캡을 배치 (A키 슬롯에는 A 각인 키캡)
- 동일 세트로 채우면 **세트 보너스** (특수 시각 이펙트, 칭호)
- 동일 등급으로 채우면 **등급 보너스** (테두리 빛남 등)
- 빈 슬롯은 회색 실루엣으로 표시 → 키캡을 모을수록 키보드 완성
- 여러 키보드를 만들어서 컬렉션 가능

### 9.4 Assembly UI

아이소메트릭 도트 스타일로 키보드 전체를 표현:

```
  ╱──╲╱──╲╱──╲╱──╲╱──╲╱──╲╱──╲╱──╲╱──╲╱──╲
 ╱ ~ ╲╱ 1 ╲╱ 2 ╲╱ 3 ╲╱ 4 ╲╱ 5 ╲╱ 6 ╲╱ 7 ╲╱ 8 ╲╱ 9 ╲
│    ││    ││    ││░░░░││    ││    ││    ││    ││░░░░││    │
 ╲──╱╲──╱╲──╱╲──╱╲──╱╲──╱╲──╱╲──╱╲──╱╲──╱
  ╱──╲╱──╲╱──╲╱──╲╱──╲╱──╲╱──╲╱──╲╱──╲
 ╱Tab╲╱ Q ╲╱ W ╲╱ E ╲╱ R ╲╱ T ╲╱ Y ╲╱ U ╲╱ I ╲
│    ││    ││    ││░░░░││    ││    ││    ││    ││    │
 ╲──╱╲──╱╲──╱╲──╱╲──╱╲──╱╲──╱╲──╱╲──╱

░░░░ = 빈 슬롯 (미수집)
```

### 9.5 Sharing

- 완성된 키보드를 **프로필 카드 이미지**로 저장/공유
- SNS 공유용 이미지 자동 생성 (아이소메트릭 키보드 렌더링)
- 나중에 유저 간 키보드 구경 기능 추가 가능

### 9.6 Data Model

```swift
struct KeyboardBuild: Identifiable, Codable {
    let id: UUID
    var name: String                     // "My Daily Driver"
    let layout: KeyboardLayout           // forty, sixty, tkl, full
    var slots: [KeySlot]                 // 레이아웃별 슬롯 배열
    let createdAt: Date
    var completionRate: Double           // 0.0 ~ 1.0
}

struct KeySlot: Identifiable, Codable {
    let id: String                       // "key-A", "key-Esc" 등
    let position: SlotPosition           // 아이소메트릭 좌표
    let expectedLegend: String           // 이 슬롯에 들어갈 문자
    var assignedKeycap: CollectedKeycap? // nil이면 빈 슬롯
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

## 10. Keycap Catalog (MVP: 120개)

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

## 11. Persistence

- 저장 위치: `~/Library/Application Support/TypeCollect/`
- 파일: `collection.json`, `stats.json`, `settings.json`
- 저장 시점: 드롭 발생 시, 60초 주기, 앱 종료 시 (`applicationWillTerminate`)
- 매 키스트로크마다 저장하지 않음 (성능 보호)

---

## 12. App Configuration

- `LSUIElement = YES`: Dock, Cmd-Tab에서 숨김
- Deployment Target: macOS 13.0
- 코드 서명 필요 (CGEvent tap 사용 시)
- App Sandbox 없이 직접 배포 (Input Monitoring 권한 자유 사용)

---

## 13. Known Challenges & Mitigations

| 문제 | 대응 |
|------|------|
| CGEvent tap이 시스템에 의해 비활성화 | `.tapDisabledByTimeout` 핸들링으로 자동 재활성화 |
| 시스템 Sleep/화면잠금 후 이벤트 못 받음 | `NSWorkspace` sleep/wake 알림 구독하여 tap 재시작 |
| 권한이 실행 중 취소됨 | 30초 주기로 `CGPreflightListenEventAccess()` 폴링 |
| 토스트가 포커스 빼앗음 | `NSPanel(.nonactivatingPanel)` + `.floating` 레벨 |
| MenuBarExtra에서 SettingsLink 미작동 | `NSApp.sendAction` 또는 Window 씬 ID로 직접 열기 |

---

## 14. Implementation Phases

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
