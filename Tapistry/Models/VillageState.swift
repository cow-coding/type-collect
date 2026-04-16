import Foundation
import Combine

/// Central state for the village system
final class VillageState: ObservableObject {
    @Published var xp: Int = 0
    @Published var cash: Int = 0
    @Published var grid: [[VillageTile]]

    let gridSize = 4

    // MARK: - Level Thresholds

    /// (level, cumulative XP required)
    static let levelTable: [(level: Int, xp: Int)] = [
        (1, 0),
        (2, 100),
        (3, 300),
        (4, 500),
        (5, 800),
        (6, 1_100),
        (7, 1_500),
        (8, 2_500),
        (9, 3_200),
        (10, 4_000),
        (11, 5_000),
        (12, 6_000),
        (13, 7_500),
        (14, 9_000),
        (15, 10_000),
        (16, 12_000),
        (17, 14_000),
        (18, 16_500),
        (19, 18_500),
        (20, 20_000),
    ]

    var level: Int {
        let entry = Self.levelTable.last { $0.xp <= xp } ?? Self.levelTable[0]
        return entry.level
    }

    var xpForCurrentLevel: Int {
        Self.levelTable.first { $0.level == level }?.xp ?? 0
    }

    var xpForNextLevel: Int? {
        Self.levelTable.first { $0.level == level + 1 }?.xp
    }

    /// Progress 0.0 ~ 1.0 within current level
    var levelProgress: Double {
        guard let nextXP = xpForNextLevel else { return 1.0 }
        let currentXP = xpForCurrentLevel
        let range = nextXP - currentXP
        guard range > 0 else { return 1.0 }
        return Double(xp - currentXP) / Double(range)
    }

    /// Building types unlocked at current level
    var unlockedBuildings: [BuildingType] {
        BuildingCatalog.all.filter { $0.unlockLevel <= level }
    }

    // MARK: - Init

    init() {
        grid = Array(
            repeating: Array(repeating: VillageTile(), count: 4),
            count: 4
        )
        load()
    }

    // MARK: - XP

    private var previousLevel: Int = 1
    var onLevelUp: ((_ from: Int, _ to: Int, _ unlocked: [BuildingType]) -> Void)?

    func addXP(_ amount: Int) {
        let before = level
        xp += amount
        let after = level
        if after > before {
            let unlocked = BuildingCatalog.all.filter { $0.unlockLevel > before && $0.unlockLevel <= after }
            onLevelUp?(before, after, unlocked)
        }
        scheduleSave()
    }

    // MARK: - Cash

    func addCash(_ amount: Int) {
        cash += amount
        scheduleSave()
    }

    @discardableResult
    func spendCash(_ amount: Int) -> Bool {
        guard cash >= amount else { return false }
        cash -= amount
        scheduleSave()
        return true
    }

    #if DEBUG
    func setLevel(_ targetLevel: Int) {
        let entry = Self.levelTable.first { $0.level == targetLevel }
        xp = entry?.xp ?? 0
    }

    func unlockAll() {
        xp = 20_000
    }

    func resetCash() {
        cash = 0
        scheduleSave()
    }
    #endif

    // MARK: - Grid

    /// Ground covers the whole tile. Pass nil to clear.
    func placeGround(_ buildingType: BuildingType?, row: Int, col: Int) {
        guard isValidTile(row: row, col: col) else { return }
        if let b = buildingType {
            guard b.layer == .ground else { return }
            guard unlockedBuildings.contains(where: { $0.id == b.id }) else { return }
            grid[row][col].ground = b.id
        } else {
            grid[row][col].ground = nil
        }
        scheduleSave()
    }

    /// Place an object or decoration into a specific sub-cell (2×2 within a tile).
    func placeSubCell(
        _ buildingType: BuildingType,
        row: Int, col: Int,
        subRow: Int, subCol: Int,
        layer: TileLayer
    ) {
        guard isValidTile(row: row, col: col),
              isValidSub(subRow: subRow, subCol: subCol) else { return }
        guard buildingType.layer == layer else { return }
        guard unlockedBuildings.contains(where: { $0.id == buildingType.id }) else { return }

        switch layer {
        case .ground:
            return  // use placeGround instead
        case .object:
            grid[row][col].subCells[subRow][subCol].object = buildingType.id
        case .decoration:
            grid[row][col].subCells[subRow][subCol].decoration = buildingType.id
        }
        scheduleSave()
    }

    func removeSubCell(row: Int, col: Int, subRow: Int, subCol: Int, layer: TileLayer) {
        guard isValidTile(row: row, col: col),
              isValidSub(subRow: subRow, subCol: subCol) else { return }
        switch layer {
        case .ground:
            return
        case .object:
            grid[row][col].subCells[subRow][subCol].object = nil
        case .decoration:
            grid[row][col].subCells[subRow][subCol].decoration = nil
        }
        scheduleSave()
    }

    /// Replace a whole tile (used by the tile editor "Cancel" to restore a snapshot).
    func replaceTile(_ tile: VillageTile, row: Int, col: Int) {
        guard isValidTile(row: row, col: col) else { return }
        grid[row][col] = tile
        scheduleSave()
    }

    // MARK: - Legacy placement APIs (delegate to ground / center sub-cell)

    func place(_ buildingType: BuildingType, row: Int, col: Int, layer: TileLayer) {
        let mid = VillageTile.subGridSize / 2
        switch layer {
        case .ground:
            placeGround(buildingType, row: row, col: col)
        case .object, .decoration:
            placeSubCell(buildingType, row: row, col: col, subRow: mid, subCol: mid, layer: layer)
        }
    }

    func remove(row: Int, col: Int, layer: TileLayer) {
        let mid = VillageTile.subGridSize / 2
        switch layer {
        case .ground:
            placeGround(nil, row: row, col: col)
        case .object, .decoration:
            removeSubCell(row: row, col: col, subRow: mid, subCol: mid, layer: layer)
        }
    }

    // MARK: - Bounds helpers

    private func isValidTile(row: Int, col: Int) -> Bool {
        row >= 0 && row < gridSize && col >= 0 && col < gridSize
    }

    private func isValidSub(subRow: Int, subCol: Int) -> Bool {
        subRow >= 0 && subRow < VillageTile.subGridSize
            && subCol >= 0 && subCol < VillageTile.subGridSize
    }

    // MARK: - Persistence

    private var saveTimer: Timer?

    private func scheduleSave() {
        saveTimer?.invalidate()
        saveTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            self?.save()
        }
    }

    private var saveURL: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("Tapistry", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("village.json")
    }

    private struct SaveData: Codable {
        let xp: Int
        var cash: Int = 0       // default for migration — old saves without cash decode to 0
        let grid: [[VillageTile]]
    }

    func save() {
        let data = SaveData(xp: xp, cash: cash, grid: grid)
        if let encoded = try? JSONEncoder().encode(data) {
            try? encoded.write(to: saveURL, options: .atomic)
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: saveURL),
              let decoded = try? JSONDecoder().decode(SaveData.self, from: data)
        else { return }
        xp = decoded.xp
        cash = decoded.cash
        if decoded.grid.count == gridSize && decoded.grid.allSatisfy({ $0.count == gridSize }) {
            grid = decoded.grid
        }
        previousLevel = level
    }
}
