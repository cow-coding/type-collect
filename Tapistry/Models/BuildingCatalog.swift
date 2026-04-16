import SwiftUI

struct BuildingType: Identifiable {
    let id: String
    let name: LocalizedString
    let emoji: String
    let layer: TileLayer
    let unlockLevel: Int
    let animated: Bool
    let price: Int              // coin cost per placement
}

struct BuildingCatalog {
    static let all: [BuildingType] = [
        // Ground types
        BuildingType(id: "flowers",     name: LocalizedString("Flowers",     ko: "꽃밭"),   emoji: "🌸", layer: .ground,     unlockLevel: 2,  animated: false, price: 5),
        BuildingType(id: "stone_path",  name: LocalizedString("Stone Path",  ko: "돌길"),   emoji: "🪨", layer: .ground,     unlockLevel: 7,  animated: false, price: 10),

        // Objects
        BuildingType(id: "tree",        name: LocalizedString("Tree",        ko: "나무"),   emoji: "🌳", layer: .object,     unlockLevel: 1,  animated: true,  price: 3),
        BuildingType(id: "house",       name: LocalizedString("House",       ko: "집"),     emoji: "🏠", layer: .object,     unlockLevel: 5,  animated: true,  price: 25),
        BuildingType(id: "street_tree", name: LocalizedString("Street Tree", ko: "가로수"), emoji: "🌲", layer: .object,     unlockLevel: 10, animated: true,  price: 15),
        BuildingType(id: "shop",        name: LocalizedString("Shop",        ko: "상점"),   emoji: "🏪", layer: .object,     unlockLevel: 12, animated: true,  price: 40),
        BuildingType(id: "cafe",        name: LocalizedString("Cafe",        ko: "카페"),     emoji: "☕", layer: .object,     unlockLevel: 14, animated: true,  price: 50),
        BuildingType(id: "apartment",   name: LocalizedString("Apartment",   ko: "아파트"),   emoji: "🏢", layer: .object,     unlockLevel: 15, animated: false, price: 60),
        BuildingType(id: "cityhall",    name: LocalizedString("City Hall",   ko: "시청"),     emoji: "🏛️", layer: .object,     unlockLevel: 17, animated: false, price: 80),
        BuildingType(id: "hotel",       name: LocalizedString("Hotel",       ko: "호텔"),     emoji: "🏨", layer: .object,     unlockLevel: 18, animated: false, price: 90),
        BuildingType(id: "skyscraper",  name: LocalizedString("Skyscraper",  ko: "고층빌딩"), emoji: "🏙️", layer: .object,     unlockLevel: 19, animated: false, price: 120),
        BuildingType(id: "windmill",    name: LocalizedString("Windmill",    ko: "풍차"),     emoji: "🌾", layer: .object,     unlockLevel: 20, animated: true,  price: 100),

        // Decorations
        BuildingType(id: "fence",       name: LocalizedString("Fence",       ko: "울타리"), emoji: "🪵", layer: .decoration, unlockLevel: 3,  animated: false, price: 5),
        BuildingType(id: "lamp",        name: LocalizedString("Lamp",        ko: "가로등"), emoji: "💡", layer: .decoration, unlockLevel: 8,  animated: true,  price: 12),
    ]

    static func find(_ id: String) -> BuildingType? {
        all.first { $0.id == id }
    }

    static func forLayer(_ layer: TileLayer) -> [BuildingType] {
        all.filter { $0.layer == layer }
    }
}
