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
    static let appName        = LocalizedString("TypeVillage", ko: "타입빌리지")
    static let settings       = LocalizedString("Settings", ko: "설정")
    static let quit           = LocalizedString("Quit TypeVillage", ko: "TypeVillage 종료")

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
    static func tileLabel(row: Int, col: Int, lang: AppLanguage) -> String {
        switch lang {
        case .english: return "Tile (\(row), \(col))"
        case .korean: return "타일 (\(row), \(col))"
        }
    }

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
