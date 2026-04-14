import Foundation
import ServiceManagement

final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @Published var launchAtLogin: Bool {
        didSet {
            do {
                if launchAtLogin {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                // Revert on failure
                #if DEBUG
                print("[AppSettings] SMAppService error: \(error)")
                #endif
                launchAtLogin = oldValue
            }
            save()
        }
    }

    @Published var showDropNotifications: Bool {
        didSet { save() }
    }

    @Published var hasCompletedOnboarding: Bool {
        didSet { save() }
    }

    @Published var language: AppLanguage {
        didSet { save() }
    }

    private let defaults = UserDefaults.standard

    private init() {
        let systemStatus = SMAppService.mainApp.status
        launchAtLogin = (systemStatus == .enabled)
        showDropNotifications = defaults.object(forKey: "showDropNotifications") as? Bool ?? true
        hasCompletedOnboarding = defaults.bool(forKey: "hasCompletedOnboarding")

        if let raw = defaults.string(forKey: "language"),
           let lang = AppLanguage(rawValue: raw) {
            language = lang
        } else {
            language = AppLanguage.systemDefault
        }
    }

    private func save() {
        defaults.set(launchAtLogin, forKey: "launchAtLogin")
        defaults.set(showDropNotifications, forKey: "showDropNotifications")
        defaults.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        defaults.set(language.rawValue, forKey: "language")
    }
}
