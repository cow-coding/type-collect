import Foundation
import Combine

final class AppState: ObservableObject {
    let permissionManager = PermissionManager()
    let keystrokeMonitor = KeystrokeMonitor()

    @Published var collection: [CollectedKeycap] = []
    @Published var recentDrops: [CollectedKeycap] = []
    @Published var isMonitoring: Bool = false
    @Published var keystrokeCount: Int = 0

    /// Set of unique keycap IDs the user has collected
    var collectedKeycapIDs: Set<String> {
        Set(collection.map { $0.keycap.id })
    }

    /// Number of unique keycaps collected
    var uniqueCollectedCount: Int {
        collectedKeycapIDs.count
    }

    /// Check if a specific keycap has been collected
    func isCollected(_ keycap: Keycap) -> Bool {
        collectedKeycapIDs.contains(keycap.id)
    }

    /// Get the first collected instance of a keycap (for detail view)
    func collectedInstance(of keycap: Keycap) -> CollectedKeycap? {
        collection.first { $0.keycap.id == keycap.id }
    }

    private var sessionTracker: SessionTracker?
    private var savedPityCount: Int = 0
    private var reEnableTimer: Timer?
    private var permissionPollTimer: Timer?
    private var saveTimer: Timer?
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Restore persisted data
        collection = StorageManager.shared.loadCollection()
        recentDrops = Array(collection.suffix(6).reversed())

        let stats = StorageManager.shared.loadStats()
        keystrokeMonitor.totalCount = stats.totalKeystrokes
        savedPityCount = stats.keystrokesSinceLastDrop

        // Forward keystroke count changes to AppState for SwiftUI binding
        keystrokeMonitor.$totalCount
            .receive(on: DispatchQueue.main)
            .assign(to: &$keystrokeCount)

        tryStartMonitoring()

        // Auto-save stats every 60 seconds
        saveTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.saveStats()
        }
    }

    func tryStartMonitoring() {
        guard sessionTracker == nil else { return }

        keystrokeMonitor.start()

        if keystrokeMonitor.isRunning {
            isMonitoring = true
            #if DEBUG
            print("[AppState] Monitoring started.")
            #endif

            sessionTracker = SessionTracker(keystrokeMonitor: keystrokeMonitor, initialKeystrokesSinceLastDrop: savedPityCount, hasEverDropped: !collection.isEmpty) { [weak self] keycap, keystrokeNumber in
                self?.handleDrop(keycap: keycap, keystrokeNumber: keystrokeNumber)
            }
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

                self.sessionTracker = SessionTracker(keystrokeMonitor: self.keystrokeMonitor) { [weak self] keycap, keystrokeNumber in
                    self?.handleDrop(keycap: keycap, keystrokeNumber: keystrokeNumber)
                }
                self.reEnableTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
                    self?.keystrokeMonitor.reEnableIfNeeded()
                }
            }
        }
    }

    private func handleDrop(keycap: Keycap, keystrokeNumber: Int) {
        #if DEBUG
        print("[AppState] DROP! \(keycap.name) (\(keycap.rarity.displayName)) at keystroke #\(keystrokeNumber)")
        #endif
        let now = Date()

        if let index = collection.firstIndex(where: { $0.id == keycap.id }) {
            // Duplicate — increment count
            collection[index].count += 1
            collection[index].lastCollectedAt = now
        } else {
            // New keycap
            let collected = CollectedKeycap(
                id: keycap.id,
                keycap: keycap,
                count: 1,
                firstCollectedAt: now,
                lastCollectedAt: now,
                keystrokeNumber: keystrokeNumber
            )
            collection.append(collected)
        }

        // Recent drops: show keycap regardless of duplicate
        let recentEntry = CollectedKeycap(
            id: "\(keycap.id)-\(now.timeIntervalSince1970)",
            keycap: keycap,
            count: 1,
            firstCollectedAt: now,
            lastCollectedAt: now,
            keystrokeNumber: keystrokeNumber
        )
        recentDrops.insert(recentEntry, at: 0)
        if recentDrops.count > 6 {
            recentDrops = Array(recentDrops.prefix(6))
        }

        StorageManager.shared.saveCollection(collection)
        saveStats()
        if AppSettings.shared.showDropNotifications {
            DropNotificationManager.shared.show(keycap: keycap)
        }
    }

    private func saveStats() {
        let stats = UserStats(
            totalKeystrokes: keystrokeMonitor.totalCount,
            keystrokesSinceLastDrop: sessionTracker?.currentPityCount ?? 0
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

        StorageManager.shared.saveCollection(collection)
        saveStats()
        keystrokeMonitor.stop()
    }
}
