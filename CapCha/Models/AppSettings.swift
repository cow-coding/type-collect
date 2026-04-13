import Foundation
import ServiceManagement

final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @Published var launchAtLogin: Bool {
        didSet {
            if launchAtLogin {
                try? SMAppService.mainApp.register()
            } else {
                try? SMAppService.mainApp.unregister()
            }
            save()
        }
    }

    @Published var showDropNotifications: Bool {
        didSet { save() }
    }

    private let defaults = UserDefaults.standard

    private init() {
        launchAtLogin = defaults.bool(forKey: "launchAtLogin")
        showDropNotifications = defaults.object(forKey: "showDropNotifications") as? Bool ?? true
    }

    private func save() {
        defaults.set(launchAtLogin, forKey: "launchAtLogin")
        defaults.set(showDropNotifications, forKey: "showDropNotifications")
    }
}
