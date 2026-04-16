import SwiftUI

struct BuildingType: Identifiable {
    let id: String
    let name: LocalizedString
    let emoji: String
    let layer: TileLayer
    let unlockLevel: Int
    let animated: Bool
}

struct BuildingCatalog {
    static let all: [BuildingType] = [
        // Ground types
        BuildingType(id: "flowers",     name: LocalizedString("Flowers",     ko: "꽃밭"),   emoji: "🌸", layer: .ground,     unlockLevel: 2,  animated: false),
        BuildingType(id: "stone_path",  name: LocalizedString("Stone Path",  ko: "돌길"),   emoji: "🪨", layer: .ground,     unlockLevel: 7,  animated: false),

        // Objects
        BuildingType(id: "tree",        name: LocalizedString("Tree",        ko: "나무"),   emoji: "🌳", layer: .object,     unlockLevel: 1,  animated: true),
        BuildingType(id: "house",       name: LocalizedString("House",       ko: "집"),     emoji: "🏠", layer: .object,     unlockLevel: 5,  animated: true),
        BuildingType(id: "street_tree", name: LocalizedString("Street Tree", ko: "가로수"), emoji: "🌲", layer: .object,     unlockLevel: 10, animated: true),
        BuildingType(id: "shop",        name: LocalizedString("Shop",        ko: "상점"),   emoji: "🏪", layer: .object,     unlockLevel: 12, animated: true),
        BuildingType(id: "cafe",        name: LocalizedString("Cafe",        ko: "카페"),   emoji: "☕", layer: .object,     unlockLevel: 14, animated: true),
        BuildingType(id: "cityhall",    name: LocalizedString("City Hall",   ko: "시청"),   emoji: "🏛️", layer: .object,     unlockLevel: 17, animated: false),
        BuildingType(id: "windmill",    name: LocalizedString("Windmill",    ko: "풍차"),   emoji: "🌾", layer: .object,     unlockLevel: 20, animated: true),

        // Decorations
        BuildingType(id: "fence",       name: LocalizedString("Fence",       ko: "울타리"), emoji: "🪵", layer: .decoration, unlockLevel: 3,  animated: false),
        BuildingType(id: "lamp",        name: LocalizedString("Lamp",        ko: "가로등"), emoji: "💡", layer: .decoration, unlockLevel: 8,  animated: true),
    ]

    static func find(_ id: String) -> BuildingType? {
        all.first { $0.id == id }
    }

    static func forLayer(_ layer: TileLayer) -> [BuildingType] {
        all.filter { $0.layer == layer }
    }
}
