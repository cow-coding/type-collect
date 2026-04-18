<p align="center">
  <img src="../Tapistry/Resources/Assets.xcassets/AppIcon.appiconset/icon_256.png" width="128" height="128" alt="Tapistry Icon">
</p>

<h1 align="center">Tapistry</h1>

<p align="center">
  <strong>타이핑으로 작은 마을을 엮어가는 macOS 메뉴바 빌더입니다.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS%2013%2B-0984E3?style=flat-square&labelColor=2D3436" alt="Platform">
  <img src="https://img.shields.io/badge/swift-5.9-F97F51?style=flat-square&labelColor=2D3436" alt="Swift">
  <img src="https://img.shields.io/badge/ui-SwiftUI%20%2B%20Canvas-2ECC71?style=flat-square&labelColor=2D3436" alt="UI">
</p>

<p align="center">
  <a href="../README.md">English</a> · <a href="pivot-context.md">제품 문맥</a> · <a href="iso-pixel-art-guide.md">아이소 픽셀아트 가이드</a>
</p>

https://github.com/user-attachments/assets/95f25153-f32f-453e-8181-6663cacb54d4

---

## Tapistry란?

Tapistry는 일상적인 타이핑을 작은 아이소메트릭 마을 빌딩으로 바꿔주는 macOS 메뉴바 앱입니다.
키를 입력하면 XP와 코인이 쌓이고, XP로 레벨이 오르며 새로운 건물이 해금됩니다. 해금한 건물은 코인을 사용해 메뉴바 팝오버 안의 4×4 마을 그리드에 배치할 수 있습니다.

> **프라이버시 우선** — Tapistry는 입력 내용을 절대 읽지 않습니다. listen-only `CGEvent tap`으로 key-down 이벤트 수만 카운트합니다. 네트워크 접근이 없고, 모든 데이터는 Mac 내부에만 저장됩니다.

## 주요 기능

- **타이핑 기반 성장** — `1 키스트로크 = 1 XP`를 기본으로 진행됩니다.
- **4×4 아이소 마을** — 메뉴바 안에서 바로 마을을 키우고 꾸밀 수 있습니다.
- **레이어 기반 타일 편집** — 각 타일은 `ground`, `object`, `decoration`을 지원하며, `object`와 `decoration`은 2×2 서브셀 단위로 배치됩니다.
- **애니메이션 픽셀아트** — 나무 흔들림, 가로등 점멸, 굴뚝 연기, 풍차 회전이 들어가 있습니다.
- **한국어/영어 지원** — 설정에서 즉시 언어를 전환할 수 있습니다.
- **로컬 저장** — 마을 상태, 코인, 타이핑 통계가 모두 로컬에 저장됩니다.
- **macOS 네이티브 설정** — 로그인 시 자동 실행, 알림 토글, 온보딩, 권한 안내를 포함합니다.

## 진행 구조

```text
⌨️ 키 입력 → ⭐ XP + 💰 코인 획득 → ⬆️ 레벨 업 → 🏡 건물 해금 → 🧱 마을 배치
```

### 성장 방식

- 모든 키 입력은 XP가 됩니다.
- 레벨이 오르면 새 건물이 해금됩니다.
- 코인은 타이핑 중 확률적으로 획득되며, 건물 배치에 사용됩니다.
- 마을 레이아웃은 저장되므로 앱을 다시 열어도 유지됩니다.

### 현재 해금 경로

| 레벨 | 해금 |
|:-----|:-----|
| 1 | 나무 |
| 2 | 꽃밭 |
| 3 | 울타리 |
| 5 | 집 |
| 7 | 돌길 |
| 8 | 가로등 |
| 10 | 가로수 |
| 12 | 상점 |
| 14 | 카페 |
| 15 | 아파트 |
| 17 | 시청 |
| 18 | 호텔 |
| 19 | 고층빌딩 |
| 20 | 풍차 |

### 마을 배치 규칙

- `ground`는 타일 상면 전체를 덮는 지면 레이어입니다.
- `object`는 메인 구조물입니다.
- `decoration`은 울타리나 가로등 같은 보조 장식입니다.
- 타일마다 2×2 서브셀이 있어서 한 칸 안에서도 더 촘촘한 배치가 가능합니다.

## 개인정보 보호

Tapistry는 macOS 입력 모니터링 권한을 사용하지만, 오직 키 입력 횟수만 셉니다.

- 어떤 키를 눌렀는지 읽지 않습니다.
- 입력한 텍스트를 저장하지 않습니다.
- 분석, 광고, 텔레메트리가 없습니다.
- 핵심 기능에 네트워크가 필요하지 않습니다.
- 데이터는 `~/Library/Application Support/Tapistry/` 아래에 저장됩니다.

## 소스에서 빌드

```bash
# 사전 설치
brew install xcodegen

# 프로젝트 생성 및 빌드
xcodegen generate
xcodebuild -project Tapistry.xcodeproj -scheme Tapistry -configuration Release build
```

### 첫 실행

macOS가 처음 실행을 차단할 수 있습니다:

```text
시스템 설정 → 개인정보 보호 및 보안 → 확인 없이 열기 → 열기
```

이후 입력 모니터링 권한을 허용합니다:

```text
시스템 설정 → 개인정보 보호 및 보안 → 입력 모니터링 → Tapistry → 켜기
```

이전 빌드를 교체하는 경우에는 기존 Tapistry 항목을 입력 모니터링에서 제거한 뒤 다시 허용해주시면 됩니다.

## 기술 스택

| | 기술 |
|:--|:-----|
| **언어** | Swift 5.9 |
| **UI** | SwiftUI + Canvas |
| **앱 형태** | macOS 메뉴바 앱 (`LSUIElement`) |
| **입력 감지** | listen-only `CGEvent tap` |
| **리액티브** | Combine |
| **저장** | Application Support 기반 JSON |
| **프로젝트 생성** | XcodeGen |

## 라이선스

Apache License 2.0 — [LICENSE](../LICENSE) 참조.
