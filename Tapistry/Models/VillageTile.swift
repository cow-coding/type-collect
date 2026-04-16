import Foundation

enum TileLayer: String, Codable, CaseIterable {
    case ground
    case object
    case decoration
}

/// A single sub-cell within a tile. Each outer tile has a 3×3 grid of these.
struct SubCell: Codable, Equatable {
    var object: String?       // BuildingType.id (tree, house, well, farm, shop, windmill)
    var decoration: String?   // BuildingType.id (fence, lamp)

    var isEmpty: Bool { object == nil && decoration == nil }
}

/// A village tile: whole-tile ground layer + 3×3 grid of sub-cells for objects and decorations.
///
/// Codable custom-decodes older save data (pre-sub-cell schema with flat
/// `object` / `decoration` fields) by moving any legacy content into the
/// center sub-cell.
struct VillageTile: Codable, Equatable {
    static let subGridSize = 2

    /// Covers the whole tile's top face.
    var ground: String?

    /// 3×3 grid indexed [subRow][subCol]. Always populated to that size.
    var subCells: [[SubCell]]

    init(ground: String? = nil, subCells: [[SubCell]]? = nil) {
        self.ground = ground
        self.subCells = subCells ?? Self.emptySubCells()
    }

    static func emptySubCells() -> [[SubCell]] {
        Array(
            repeating: Array(repeating: SubCell(), count: subGridSize),
            count: subGridSize
        )
    }

    var isEmpty: Bool {
        ground == nil && subCells.allSatisfy { row in row.allSatisfy { $0.isEmpty } }
    }

    /// Center sub-cell convenience (used by legacy placement APIs).
    var centerSubCell: SubCell {
        get { subCells[Self.subGridSize / 2][Self.subGridSize / 2] }
        set { subCells[Self.subGridSize / 2][Self.subGridSize / 2] = newValue }
    }

    // MARK: - Codable (with legacy migration)

    private enum CodingKeys: String, CodingKey {
        case ground
        case subCells
        // legacy (pre-sub-cell):
        case object
        case decoration
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.ground = try c.decodeIfPresent(String.self, forKey: .ground)

        if let sub = try c.decodeIfPresent([[SubCell]].self, forKey: .subCells),
           sub.count == Self.subGridSize,
           sub.allSatisfy({ $0.count == Self.subGridSize })
        {
            // New format
            self.subCells = sub
        } else {
            // Migrate from legacy object/decoration → center sub-cell
            self.subCells = Self.emptySubCells()
            let legacyObject = try c.decodeIfPresent(String.self, forKey: .object)
            let legacyDeco = try c.decodeIfPresent(String.self, forKey: .decoration)
            if legacyObject != nil || legacyDeco != nil {
                let mid = Self.subGridSize / 2
                self.subCells[mid][mid] = SubCell(object: legacyObject, decoration: legacyDeco)
            }
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(ground, forKey: .ground)
        try c.encode(subCells, forKey: .subCells)
    }
}
