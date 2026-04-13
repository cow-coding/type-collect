import Foundation

struct UserStats: Codable {
    var totalKeystrokes: Int = 0
    var keystrokesSinceLastDrop: Int = 0
    var todayKeystrokes: Int = 0
    var todayDate: String = ""  // "yyyy-MM-dd" format
}

final class StorageManager {
    static let shared = StorageManager()

    private let fileManager = FileManager.default
    private let directory: URL

    private init() {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        directory = appSupport.appendingPathComponent("CapCha", isDirectory: true)
        try? fileManager.createDirectory(
            at: directory,
            withIntermediateDirectories: true,
            attributes: [.posixPermissions: 0o700]
        )
    }

    private var collectionURL: URL {
        directory.appendingPathComponent("collection.json")
    }

    private var statsURL: URL {
        directory.appendingPathComponent("stats.json")
    }

    // MARK: - Collection

    func saveCollection(_ items: [CollectedKeycap]) {
        do {
            let data = try JSONEncoder().encode(items)
            try data.write(to: collectionURL, options: .atomic)
        } catch {
            #if DEBUG
            print("[StorageManager] Save collection failed: \(error)")
            #endif
        }
    }

    func loadCollection() -> [CollectedKeycap] {
        guard let data = try? Data(contentsOf: collectionURL) else { return [] }

        // Try new format first
        if let collection = try? JSONDecoder().decode([CollectedKeycap].self, from: data) {
            return collection
        }

        // Migrate from old format (id: UUID, collectedAt: Date)
        // Try multiple date decoding strategies
        for strategy in [JSONDecoder.DateDecodingStrategy.deferredToDate, .secondsSince1970, .iso8601] {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = strategy
            if let legacy = try? decoder.decode([LegacyCollectedKeycap].self, from: data), !legacy.isEmpty {
                #if DEBUG
                print("[StorageManager] Migrating \(legacy.count) legacy keycaps (strategy: \(strategy))")
                #endif
                var migrated: [String: CollectedKeycap] = [:]
                for old in legacy {
                    let key = old.keycap.id
                    if var existing = migrated[key] {
                        existing.count += 1
                        if old.collectedAt > existing.lastCollectedAt {
                            existing.lastCollectedAt = old.collectedAt
                        }
                        migrated[key] = existing
                    } else {
                        migrated[key] = CollectedKeycap(
                            id: key,
                            keycap: old.keycap,
                            count: 1,
                            firstCollectedAt: old.collectedAt,
                            lastCollectedAt: old.collectedAt,
                            keystrokeNumber: old.keystrokeNumber
                        )
                    }
                }
                let result = Array(migrated.values)
                saveCollection(result)
                return result
            }
        }

        #if DEBUG
        print("[StorageManager] Could not parse collection data, preserving file")
        #endif
        return []
    }

    // Legacy format for migration
    private struct LegacyCollectedKeycap: Codable {
        let id: UUID
        let keycap: Keycap
        let collectedAt: Date
        let keystrokeNumber: Int
    }

    // MARK: - Stats

    func saveStats(_ stats: UserStats) {
        do {
            let data = try JSONEncoder().encode(stats)
            try data.write(to: statsURL, options: .atomic)
        } catch {
            #if DEBUG
            print("[StorageManager] Save stats failed: \(error)")
            #endif
        }
    }

    func loadStats() -> UserStats {
        guard let data = try? Data(contentsOf: statsURL) else { return UserStats() }
        return (try? JSONDecoder().decode(UserStats.self, from: data)) ?? UserStats()
    }
}
