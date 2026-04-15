import Foundation
import Combine

final class AppState: ObservableObject {
    let permissionManager = PermissionManager()
    let keystrokeMonitor = KeystrokeMonitor()
    let village = VillageState()

    @Published var isMonitoring: Bool = false
    @Published var keystrokeCount: Int = 0
    @Published var todayKeystrokeCount: Int = 0

    private var lastKnownTotal: Int = 0
    private var currentDay: String = ""
    private var reEnableTimer: Timer?
    private var permissionPollTimer: Timer?
    private var saveTimer: Timer?
    private var cancellables = Set<AnyCancellable>()

    static func todayString() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }

    init() {
        // Restore persisted stats
        let stats = StorageManager.shared.loadStats()
        keystrokeMonitor.totalCount = stats.totalKeystrokes

        let today = Self.todayString()
        currentDay = today
        todayKeystrokeCount = (stats.todayDate == today) ? stats.todayKeystrokes : 0
        lastKnownTotal = keystrokeMonitor.totalCount

        // Forward keystroke count changes for SwiftUI binding
        keystrokeMonitor.$totalCount
            .receive(on: DispatchQueue.main)
            .assign(to: &$keystrokeCount)

        // Feed keystroke delta → today counter + village XP (with midnight rollover)
        keystrokeMonitor.$totalCount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newTotal in
                guard let self = self else { return }

                let today = Self.todayString()
                if today != self.currentDay {
                    self.todayKeystrokeCount = 0
                    self.currentDay = today
                }

                let delta = newTotal - self.lastKnownTotal
                if delta > 0 {
                    self.todayKeystrokeCount += delta
                    self.lastKnownTotal = newTotal
                    self.village.addXP(delta)
                }
            }
            .store(in: &cancellables)

        tryStartMonitoring()

        // Auto-save stats every 60 seconds
        saveTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.saveStats()
        }
    }

    func tryStartMonitoring() {
        keystrokeMonitor.start()

        if keystrokeMonitor.isRunning {
            isMonitoring = true
            #if DEBUG
            print("[AppState] Monitoring started.")
            #endif
            reEnableTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
                self?.keystrokeMonitor.reEnableIfNeeded()
            }
        } else {
            isMonitoring = false
            #if DEBUG
            print("[AppState] No permission. Polling...")
            #endif
            startPermissionPolling()
        }
    }

    private func startPermissionPolling() {
        permissionPollTimer?.invalidate()
        permissionPollTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] timer in
            guard let self = self else { timer.invalidate(); return }
            self.keystrokeMonitor.start()
            if self.keystrokeMonitor.isRunning {
                timer.invalidate()
                self.permissionPollTimer = nil
                self.isMonitoring = true
                #if DEBUG
                print("[AppState] Permission granted. Monitoring started.")
                #endif
                self.reEnableTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
                    self?.keystrokeMonitor.reEnableIfNeeded()
                }
            }
        }
    }

    private func saveStats() {
        let stats = UserStats(
            totalKeystrokes: keystrokeMonitor.totalCount,
            todayKeystrokes: todayKeystrokeCount,
            todayDate: Self.todayString()
        )
        StorageManager.shared.saveStats(stats)
    }

    func saveOnExit() {
        reEnableTimer?.invalidate()
        permissionPollTimer?.invalidate()
        saveTimer?.invalidate()
        reEnableTimer = nil
        permissionPollTimer = nil
        saveTimer = nil

        let stats = UserStats(
            totalKeystrokes: keystrokeMonitor.totalCount,
            todayKeystrokes: todayKeystrokeCount,
            todayDate: Self.todayString()
        )
        StorageManager.shared.saveStats(stats, sync: true)
        village.save()
        keystrokeMonitor.stop()
    }
}
