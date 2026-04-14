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

    private let defaults = UserDefaults.standard

    private init() {
        // Read actual system state instead of stale UserDefaults
        let systemStatus = SMAppService.mainApp.status
        launchAtLogin = (systemStatus == .enabled)
        showDropNotifications = defaults.object(forKey: "showDropNotifications") as? Bool ?? true
        hasCompletedOnboarding = defaults.bool(forKey: "hasCompletedOnboarding")
    }

    private func save() {
        defaults.set(launchAtLogin, forKey: "launchAtLogin")
        defaults.set(showDropNotifications, forKey: "showDropNotifications")
        defaults.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
    }
}
