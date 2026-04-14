import Foundation
import Combine

final class AppState: ObservableObject {
    let permissionManager = PermissionManager()
    let keystrokeMonitor = KeystrokeMonitor()

    @Published var collection: [CollectedKeycap] = []
    @Published var recentDrops: [CollectedKeycap] = []
    @Published var isMonitoring: Bool = false
    @Published var keystrokeCount: Int = 0
    @Published var todayKeystrokeCount: Int = 0

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
        // Restore persisted data
        collection = StorageManager.shared.loadCollection()
        recentDrops = Array(collection.suffix(6).reversed())

        let stats = StorageManager.shared.loadStats()
        keystrokeMonitor.totalCount = stats.totalKeystrokes
        savedPityCount = stats.keystrokesSinceLastDrop

        // Restore today's keystrokes (reset if date changed)
        let today = Self.todayString()
        currentDay = today
        if stats.todayDate == today {
            todayKeystrokeCount = stats.todayKeystrokes
        } else {
            todayKeystrokeCount = 0
        }
        lastKnownTotal = keystrokeMonitor.totalCount

        // Forward keystroke count changes to AppState for SwiftUI binding
        keystrokeMonitor.$totalCount
            .receive(on: DispatchQueue.main)
            .assign(to: &$keystrokeCount)

        // Track today's keystrokes separately with midnight rollover
        keystrokeMonitor.$totalCount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newTotal in
                guard let self = self else { return }

                // Check for midnight rollover
                let today = Self.todayString()
                if today != self.currentDay {
                    self.todayKeystrokeCount = 0
                    self.currentDay = today
                }

                let delta = newTotal - self.lastKnownTotal
                if delta > 0 {
                    self.todayKeystrokeCount += delta
                    self.lastKnownTotal = newTotal
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

                self.sessionTracker = SessionTracker(keystrokeMonitor: self.keystrokeMonitor, initialKeystrokesSinceLastDrop: self.savedPityCount, hasEverDropped: !self.collection.isEmpty) { [weak self] keycap, keystrokeNumber in
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
            keystrokesSinceLastDrop: sessionTracker?.currentPityCount ?? 0,
            todayKeystrokes: todayKeystrokeCount,
            todayDate: Self.todayString()
        )
        StorageManager.shared.saveStats(stats)
    }

    // MARK: - Debug Seed Data

    #if DEBUG
    static func makeTestCollection() -> [CollectedKeycap] {
        let now = Date()
        var seeded: [CollectedKeycap] = []

        let standardKeys = KeycapCatalog.keys.filter { $0.widthUnit == 1.0 }
        let modifierKeys = KeycapCatalog.keys.filter { $0.widthUnit > 1.0 && $0.widthUnit < 5.0 }
        let spaceKeys = KeycapCatalog.keys.filter { $0.widthUnit >= 5.0 }

        for (i, key) in standardKeys.prefix(30).enumerated() {
            let set = KeycapCatalog.sets[i % KeycapCatalog.sets.count]
            let rarity = Rarity.allCases[i % Rarity.allCases.count]
            guard let colors = set.palette[rarity], let color = colors.first else { continue }

            let id = "\(set.prefix)-\(key.displayName.lowercased().replacingOccurrences(of: " ", with: "-"))-\(rarity.rawValue)"
            let keycap = Keycap(
                id: id, name: key.displayName, rarity: rarity,
                legendCharacter: key.legend, primaryColor: color,
                setName: set.name, widthUnit: key.widthUnit
            )
            let count = rarity == .common ? Int.random(in: 3...15) :
                        rarity == .uncommon ? Int.random(in: 2...8) :
                        rarity == .rare ? Int.random(in: 1...4) :
                        rarity == .epic ? Int.random(in: 1...2) : 1
            seeded.append(CollectedKeycap(
                id: id, keycap: keycap, count: count,
                firstCollectedAt: now.addingTimeInterval(Double(-i * 3600)),
                lastCollectedAt: now.addingTimeInterval(Double(-i * 60)),
                keystrokeNumber: (i + 1) * 150
            ))
        }

        for (i, key) in modifierKeys.prefix(8).enumerated() {
            let set = KeycapCatalog.sets[i % KeycapCatalog.sets.count]
            let rarity: Rarity = [.uncommon, .rare, .epic, .legendary][i % 4]
            guard let colors = set.palette[rarity], let color = colors.first else { continue }

            let id = "\(set.prefix)-\(key.displayName.lowercased().replacingOccurrences(of: " ", with: "-"))-\(rarity.rawValue)"
            let keycap = Keycap(
                id: id, name: key.displayName, rarity: rarity,
                legendCharacter: key.legend, primaryColor: color,
                setName: set.name, widthUnit: key.widthUnit
            )
            seeded.append(CollectedKeycap(
                id: id, keycap: keycap, count: Int.random(in: 1...3),
                firstCollectedAt: now.addingTimeInterval(Double(-i * 7200)),
                lastCollectedAt: now.addingTimeInterval(Double(-i * 120)),
                keystrokeNumber: (i + 31) * 200
            ))
        }

        if let spaceKey = spaceKeys.first {
            let set = KeycapCatalog.sets[2]
            let id = "\(set.prefix)-space-legendary"
            let keycap = Keycap(
                id: id, name: "Space", rarity: .legendary,
                legendCharacter: spaceKey.legend, primaryColor: set.palette[.legendary]!.first!,
                setName: set.name, widthUnit: spaceKey.widthUnit
            )
            seeded.append(CollectedKeycap(
                id: id, keycap: keycap, count: 1,
                firstCollectedAt: now.addingTimeInterval(-86400),
                lastCollectedAt: now.addingTimeInterval(-86400),
                keystrokeNumber: 9999
            ))
        }

        return seeded
    }
    #endif

    func saveOnExit() {
        reEnableTimer?.invalidate()
        permissionPollTimer?.invalidate()
        saveTimer?.invalidate()
        reEnableTimer = nil
        permissionPollTimer = nil
        saveTimer = nil

        // Sync save — must complete before process exits
        StorageManager.shared.saveCollection(collection, sync: true)
        let stats = UserStats(
            totalKeystrokes: keystrokeMonitor.totalCount,
            keystrokesSinceLastDrop: sessionTracker?.currentPityCount ?? 0,
            todayKeystrokes: todayKeystrokeCount,
            todayDate: Self.todayString()
        )
        StorageManager.shared.saveStats(stats, sync: true)
        keystrokeMonitor.stop()
    }
}
