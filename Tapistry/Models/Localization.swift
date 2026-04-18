import Foundation

enum AppLanguage: String, Codable, CaseIterable, Identifiable {
    case english = "en"
    case korean = "ko"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .korean: return "한국어"
        }
    }

    /// Default based on system language
    static var systemDefault: AppLanguage {
        let preferred = Locale.preferredLanguages.first ?? "en"
        return preferred.hasPrefix("ko") ? .korean : .english
    }
}

/// A string with English and Korean variants
struct LocalizedString {
    let en: String
    let ko: String

    init(_ en: String, ko: String) {
        self.en = en
        self.ko = ko
    }

    func resolve(_ lang: AppLanguage) -> String {
        switch lang {
        case .english: return en
        case .korean: return ko
        }
    }
}

/// Centralized localized strings for the app
enum L10n {
    // Menu bar
    // Brand name stays in English across all locales
    static let appName        = LocalizedString("Tapistry", ko: "Tapistry")
    static let settings       = LocalizedString("Settings", ko: "설정")
    static let quit           = LocalizedString("Quit Tapistry", ko: "Tapistry 종료")

    // Permission banner
    static let permissionTitle    = LocalizedString("Input Monitoring required", ko: "입력 모니터링 권한 필요")
    static let permissionDetail   = LocalizedString("Allow access to earn XP from typing", ko: "타이핑으로 XP를 쌓으려면 허용해주세요")
    static let permissionOpen     = LocalizedString("Open", ko: "열기")

    // XP / Level
    static let levelUp        = LocalizedString("Level Up!", ko: "레벨 업!")
    static let newUnlock      = LocalizedString("New unlock!", ko: "새 해금!")
    static let max            = LocalizedString("MAX", ko: "MAX")

    // Building picker
    static let layerGround    = LocalizedString("Ground", ko: "지면")
    static let layerObject    = LocalizedString("Building", ko: "건물")
    static let layerDecoration = LocalizedString("Decor", ko: "장식")
    static let noUnlocked     = LocalizedString("No unlocks yet", ko: "해금된 건물 없음")
    static let upcomingUnlocks = LocalizedString("Coming up", ko: "해금 예정")
    static let remove         = LocalizedString("Remove", ko: "제거")
    static let done           = LocalizedString("Done", ko: "완료")
    static let cancel         = LocalizedString("Cancel", ko: "취소")
    static let noneLabel      = LocalizedString("None", ko: "없음")
    static let tapSubCell     = LocalizedString("Tap a cell to place", ko: "셀을 탭해 배치")
    static let subCellLabel   = LocalizedString("Cell", ko: "셀")
    static func tileLabel(row: Int, col: Int, lang: AppLanguage) -> String {
        switch lang {
        case .english: return "Tile (\(row), \(col))"
        case .korean: return "타일 (\(row), \(col))"
        }
    }

    // Welcome / Onboarding
    static let welcomeTagline     = LocalizedString("Weave your village, one keystroke at a time.", ko: "키 하나하나가 엮어내는 나만의 마을.")
    static let welcomeConceptTitle = LocalizedString("Type. Level up. Unlock.", ko: "타이핑, 레벨업, 해금")
    static let welcomeConceptBody = LocalizedString(
        "Every keystroke weaves XP into your village.\nNew buildings unlock as you level up.",
        ko: "키 입력이 마을의 경험치로 엮입니다.\n레벨이 오를수록 새 건물이 해금됩니다."
    )
    static let welcomePreviewTree    = LocalizedString("Tree", ko: "나무")
    static let welcomePreviewHouse   = LocalizedString("House", ko: "나무집")
    static let welcomePreviewWindmill = LocalizedString("Windmill", ko: "풍차")
    static let welcomePrivacyTitle  = LocalizedString("Your Privacy", ko: "개인정보 보호")
    static let welcomePrivacySubtitle = LocalizedString("Tapistry runs entirely on-device.", ko: "Tapistry는 완전히 기기 내에서만 작동합니다.")
    static let welcomePrivacyRow1Title  = LocalizedString("Counts keystrokes only", ko: "키 입력 횟수만 감지")
    static let welcomePrivacyRow1Detail = LocalizedString("What you type stays yours — we never read keys or content.", ko: "어떤 키를 눌렀는지, 무엇을 입력했는지는 알 수 없습니다.")
    static let welcomePrivacyRow2Title  = LocalizedString("Local-only storage", ko: "로컬 저장만 사용")
    static let welcomePrivacyRow2Detail = LocalizedString("All data stays on this Mac. Nothing ever leaves the device.", ko: "모든 데이터는 기기에만 저장되며 외부로 전송되지 않습니다.")
    static let welcomePrivacyRow3Title  = LocalizedString("No tracking", ko: "추적 없음")
    static let welcomePrivacyRow3Detail = LocalizedString("No analytics, no ads, no telemetry.", ko: "분석, 광고, 사용자 추적 기능이 없습니다.")
    static let welcomeNext          = LocalizedString("Next", ko: "다음")
    static let welcomeGetStarted    = LocalizedString("Get Started", ko: "시작하기")

    // Cash / Coins
    static let coins           = LocalizedString("coins", ko: "코인")
    static let todayLabel      = LocalizedString("today", ko: "오늘")
    static let notEnoughCoins  = LocalizedString("Not enough coins", ko: "코인 부족")

    // Settings
    static let settingsTitle  = LocalizedString("Settings", ko: "설정")
    static let general        = LocalizedString("General", ko: "일반")
    static let launchAtLogin  = LocalizedString("Launch at login", ko: "로그인 시 자동 실행")
    static let showNotifications = LocalizedString("Show notifications", ko: "알림 표시")
    static let language       = LocalizedString("Language", ko: "언어")
    static let about          = LocalizedString("About", ko: "정보")
    static let version        = LocalizedString("Version", ko: "버전")
    static let close          = LocalizedString("Close", ko: "닫기")
}
