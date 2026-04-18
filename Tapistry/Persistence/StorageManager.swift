import Foundation

struct UserStats: Codable {
    var totalKeystrokes: Int = 0
    var todayKeystrokes: Int = 0
    var todayDate: String = ""  // "yyyy-MM-dd" format
}

final class StorageManager {
    static let shared = StorageManager()

    private let fileManager = FileManager.default
    private let directory: URL
    private let saveQueue = DispatchQueue(label: "com.tapistry.storage", qos: .utility)

    private init() {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        directory = appSupport.appendingPathComponent(AppEnvironment.storageFolderName, isDirectory: true)
        try? fileManager.createDirectory(
            at: directory,
            withIntermediateDirectories: true,
            attributes: [.posixPermissions: 0o700]
        )
    }

    private var statsURL: URL {
        directory.appendingPathComponent("stats.json")
    }

    // MARK: - Stats

    func saveStats(_ stats: UserStats, sync: Bool = false) {
        let work = { [statsURL] in
            do {
                let data = try JSONEncoder().encode(stats)
                try data.write(to: statsURL, options: .atomic)
            } catch {
                #if DEBUG
                print("[StorageManager] Save stats failed: \(error)")
                #endif
            }
        }
        if sync {
            dispatchPrecondition(condition: .notOnQueue(saveQueue))
            saveQueue.sync { work() }
        } else {
            saveQueue.async { work() }
        }
    }

    func loadStats() -> UserStats {
        guard let data = try? Data(contentsOf: statsURL) else { return UserStats() }
        return (try? JSONDecoder().decode(UserStats.self, from: data)) ?? UserStats()
    }
}
