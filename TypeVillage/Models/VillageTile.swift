import Foundation

enum TileLayer: String, Codable, CaseIterable {
    case ground
    case object
    case decoration
}

struct VillageTile: Codable {
    var ground: String?      // BuildingType.id
    var object: String?      // BuildingType.id
    var decoration: String?  // BuildingType.id

    var isEmpty: Bool {
        ground == nil && object == nil && decoration == nil
    }
}
