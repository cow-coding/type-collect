# TypeCollect

타이핑하면 키캡이 모이는 macOS 메뉴바 앱

## Concept

평소처럼 개발하고, 업무하고, 글을 쓰세요.
타이핑할수록 다양한 등급의 가상 키캡 아이템이 드롭됩니다.

- 백그라운드에서 조용히 동작하는 메뉴바 앱
- 키 입력 내용은 절대 수집하지 않음 (카운트만)
- Common부터 Legendary까지 5단계 등급 시스템
- 천장(Pity) 시스템으로 확정 드롭 보장
- 콤보, 연속 출석, 마일스톤 보너스

## Tech Stack

- **Swift + SwiftUI** (macOS 13.0+)
- **CGEvent tap** (Listen-Only) for global keystroke counting
- **Combine** for reactive data flow
- **JSON** for local persistence

## Features (MVP)

- [x] Architecture design
- [ ] Menubar app with popover UI
- [ ] Global keystroke monitoring
- [ ] Gacha drop system with pity
- [ ] Keycap collection view
- [ ] Drop toast notifications
- [ ] 120 keycap catalog (6 sets)
- [ ] Local data persistence

## Documentation

- [DESIGN.md](./DESIGN.md) — Full architecture design document

## Privacy

TypeCollect uses macOS Input Monitoring permission to count keystrokes.
**We never read, store, or transmit what you type.** Only the keystroke count is tracked.

## License

TBD
