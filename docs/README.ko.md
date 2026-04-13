<p align="center">
  <img src="../CapCha/Resources/Assets.xcassets/AppIcon.appiconset/icon_256.png" width="128" height="128" alt="CapCha Icon">
</p>

<h1 align="center">CapCha</h1>

<p align="center">
  <strong>타이핑하면 키캡이 모입니다. 모든 키 입력이 수집이 됩니다.</strong>
</p>

<p align="center">
  <a href="https://github.com/cow-coding/CapCha/releases/latest"><img src="https://img.shields.io/github/v/release/cow-coding/CapCha?style=flat-square&color=6C5CE7&labelColor=2D3436&label=release" alt="Release"></a>
  <a href="https://github.com/cow-coding/CapCha/releases"><img src="https://img.shields.io/github/downloads/cow-coding/CapCha/total?style=flat-square&color=00B894&labelColor=2D3436" alt="Downloads"></a>
  <img src="https://img.shields.io/badge/platform-macOS%2013%2B-0984E3?style=flat-square&labelColor=2D3436" alt="Platform">
  <img src="https://img.shields.io/badge/swift-5.9-F97F51?style=flat-square&labelColor=2D3436" alt="Swift">
</p>

<p align="center">
  <a href="../README.md">English</a> · <a href="https://github.com/cow-coding/CapCha/releases/latest">다운로드</a> · <a href="DESIGN.en.md">설계 문서</a>
</p>

---

## CapCha란?

CapCha는 일상적인 타이핑을 가상 키캡 가챠 게임으로 바꿔주는 macOS 메뉴바 앱입니다. 개발하고, 업무하고, 글 쓰면서 — 키캡을 모으세요.

> **🔒 프라이버시 최우선** — CapCha는 입력 내용을 절대 읽지 않습니다. `CGEvent tap` listen-only 모드로 카운트만 합니다. 네트워크 접근 없음, 모든 데이터는 로컬에 저장.

### 주요 기능

- 🎲 **2,610가지 키캡 조합** — 87 TKL키 × 5 테마 세트 × 6 등급
- 🌈 **6단계 등급** — Common → Uncommon → Rare → Epic → **Legendary** → ***Eternal***
- 🎯 **천장(Pity) 시스템** — 2,000타 내 확정 드롭, 가뭄 걱정 없음
- 🔔 **드롭 알림** — 메뉴바 아이콘 아래 말풍선 팝업
- 📦 **컬렉션 윈도우** — 아이소메트릭 3D 카드로 키캡 탐색
- ⚙️ **설정** — 로그인 시 자동 실행, 알림 토글
- 🔐 **보안 감사 완료** — 키 내용 미접근, 네트워크 없음, 데이터 수집 없음

---

## 설치 방법

### 1. 다운로드

> **[최신 DMG 다운로드](https://github.com/cow-coding/CapCha/releases/latest)**

### 2. 설치

DMG 열기 → **CapCha**를 **Applications**로 드래그

### 3. 첫 실행

Apple Developer ID로 서명되지 않아 macOS가 차단합니다:

```
시스템 설정 → 개인정보 보호 및 보안 → 확인 없이 열기 → 열기
```

### 4. 권한 부여

```
시스템 설정 → 개인정보 보호 및 보안 → 입력 모니터링 → CapCha → 켜기
```

> **💡 업데이트 시** 기존 CapCha 항목을 입력 모니터링에서 먼저 삭제하고, 새 버전에 권한을 다시 부여하세요.

---

## 작동 원리

```
⌨️ 키 입력 → 🎲 드롭 판정 (0.25%) → 🎰 등급 결정 → 🎁 키캡 획득! → 🔔 알림
```

### 드롭 시스템

매 키 입력마다 **0.25% 기본 확률**로 판정합니다. 성공하면 랜덤 **등급 → 세트 → 키** 조합으로 키캡이 생성됩니다.

### 등급 시스템

| 등급 | 가중치 | 시각 효과 |
|:-----|:-----:|:---------|
| ⚪ Common | 59.4% | 기본 키캡 |
| 🟢 Uncommon | 25% | 초록 글로우 + 테두리 |
| 🔵 Rare | 10% | 파란 글로우 + 두꺼운 테두리 |
| 🟣 Epic | 4% | 보라 글로우 + 내부 광택 |
| 🟠 Legendary | 1% | 골드 글로우 + 내부 광택 |
| 🌈 Eternal | 0.6% | 프리즘 무지개 애니메이션 |

### 천장(Pity) 시스템

운이 나빠도 걱정 없습니다. 드롭 확률이 자동으로 올라갑니다:

| 드롭 없이 지난 키스트로크 | 드롭 확률 |
|:----------------------|:---------|
| 0 – 499 | 0.25% (기본) |
| 500 – 999 | 0.25% → 0.5% |
| 1,000 – 1,999 | 0.5% → 1.0% |
| 2,000+ | **100% 확정** |

> 🎁 **첫 드롭 보장** — 신규 사용자는 100타 안에 Common 키캡 1개가 확정됩니다.

### 키캡 세트

| 세트 | 테마 | 색상 |
|:----|:-----|:---:|
| Mechanical Classics | 체리 스위치 계열 | 🔴 |
| Retro Computing | 빈티지 터미널 | 🟤 |
| Artisan Collection | 아티산 키캡 | 🟣 |
| Nature Elements | 자연과 숲 | 🟢 |
| Space Theme | 우주 | 🔵 |

각 세트에 **TKL 87키** 전체가 포함됩니다. 같은 키가 모든 등급으로 나올 수 있어요!

중복 키캡은 수량으로 쌓입니다. 나중에 거래에 활용하세요!

---

## 소스에서 빌드

```bash
# 사전 설치
brew install xcodegen

# 생성 & 빌드
xcodegen generate
xcodebuild -project CapCha.xcodeproj -scheme CapCha -configuration Release build
```

---

## 기술 스택

| | 기술 |
|:--|:-----|
| **언어** | Swift 5.9 |
| **UI** | SwiftUI + Canvas (아이소메트릭 키캡 렌더링) |
| **입력** | CGEvent tap (listen-only, tailAppend) |
| **리액티브** | Combine |
| **저장** | JSON (`~/Library/Application Support/CapCha/`) |
| **CI/CD** | GitHub Actions + create-dmg |

---

## 문서

| | |
|:--|:--|
| 📄 [설계 문서 (EN)](DESIGN.en.md) | Architecture, data models, drop engine |
| 📄 [설계 문서 (KR)](../DESIGN.md) | 아키텍처, 데이터 모델, 드롭 엔진 |

---

## 개인정보 보호

CapCha는 macOS 입력 모니터링으로 키스트로크를 카운트합니다.

- ✅ 키 입력 횟수만 측정 — 내용은 절대 읽지 않음
- ✅ 네트워크 접근 없음 — 모든 데이터 로컬 저장
- ✅ 오픈소스 — 직접 확인 가능
- ✅ 보안 감사 완료 — [감사 보고서 보기](https://github.com/cow-coding/CapCha/pull/3)

---

## 라이선스

Apache License 2.0 — [LICENSE](../LICENSE) 참조.
