# CapCha

타이핑하면 키캡이 모이는 macOS 메뉴바 앱

[English](../README.md)

## CapCha란?

평소처럼 개발하고, 업무하고, 글을 쓰세요.
CapCha는 메뉴바에서 조용히 실행되며, 타이핑할수록 가상 키캡 아이템이 랜덤으로 드롭됩니다.

- 백그라운드에서 조용히 동작하는 메뉴바 앱
- **키 입력 내용은 절대 수집하지 않음** — 카운트만 측정
- 5단계 등급 시스템: Common → Uncommon → Rare → Epic → Legendary
- 5개 테마 세트, 30종 키캡

## 설치 방법

### 1. 다운로드

[Releases](https://github.com/cow-coding/CapCha/releases) 페이지에서 최신 `CapCha-vX.X.X.dmg`를 다운로드하세요.

### 2. 설치

DMG를 열고 **CapCha**를 **Applications** 폴더로 드래그하세요.

### 3. 첫 실행 — Gatekeeper 경고

CapCha는 Apple Developer ID로 서명되지 않았기 때문에 첫 실행 시 macOS가 차단합니다.

1. Applications에서 **CapCha**를 실행하면 경고 다이얼로그가 나타납니다
2. **시스템 설정 → 개인정보 보호 및 보안**으로 이동하세요
3. **보안** 섹션까지 스크롤하세요
4. *"CapCha"은(는) 확인되지 않은 개발자가 배포했기 때문에 차단되었습니다.* 라는 메시지가 보입니다
5. **확인 없이 열기(Open Anyway)** 를 클릭하세요
6. 확인 다이얼로그에서 **열기**를 클릭하세요

> 이 과정은 최초 1회만 필요합니다. 이후에는 정상적으로 실행됩니다.

### 4. Input Monitoring 권한 부여

CapCha는 키스트로크를 카운트하기 위해 Input Monitoring 권한이 필요합니다.

1. 첫 실행 시 Input Monitoring 접근 요청이 나타납니다
2. 시스템 다이얼로그가 나타나면 **시스템 설정 열기**를 클릭하세요
3. **시스템 설정 → 개인정보 보호 및 보안 → 입력 모니터링**으로 이동하세요
4. 목록에서 **CapCha**를 찾아 **켜기**로 전환하세요
5. 권한 부여 후 CapCha를 재시작해야 할 수 있습니다

> **개인정보**: CapCha는 `CGEvent tap`을 listen-only 모드로 사용합니다. 키를 누를 때마다 카운터만 1 증가시킬 뿐, 어떤 키를 눌렀는지 읽거나 저장하거나 전송하지 않습니다.

## 사용법

실행하면 메뉴바에 키캡 아이콘이 나타납니다.

- **아이콘 클릭** — 키스트로크 수와 최근 드롭 확인
- **타이핑** — 키 입력마다 0.6% 확률로 키캡 드롭
- **드롭 알림** — 키캡 획득 시 메뉴바 아이콘 아래에 말풍선 표시

### 등급 시스템

| 등급 | 드롭 확률 | 색상 |
|------|----------|------|
| Common | 60% | 회색 |
| Uncommon | 25% | 초록 |
| Rare | 10% | 파랑 |
| Epic | 4% | 보라 |
| Legendary | 1% | 주황 |

## 기술 스택

- **Swift + SwiftUI** (macOS 13.0+)
- **CGEvent tap** (Listen-Only) 글로벌 키스트로크 카운팅
- **Combine** 리액티브 데이터 흐름
- **JSON** 로컬 저장 (`~/Library/Application Support/CapCha/`)

## 소스에서 빌드

```bash
# xcodegen 설치
brew install xcodegen

# Xcode 프로젝트 생성
xcodegen generate

# 빌드
xcodebuild -project CapCha.xcodeproj -scheme CapCha -configuration Release build
```

## 문서

- [DESIGN.md](../DESIGN.md) — 아키텍처 설계 문서 (한국어)
- [docs/DESIGN.en.md](./DESIGN.en.md) — 아키텍처 설계 문서 (영어)

## 개인정보 보호

CapCha는 키스트로크를 카운트하기 위해 macOS Input Monitoring 권한을 사용합니다.
**입력한 내용을 절대 읽거나 저장하거나 전송하지 않습니다.** 키스트로크 횟수만 추적합니다.

## 라이선스

TBD
