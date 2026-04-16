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

enum BuildingRenderKind {
    case tree
    case house
    case windmill
    case shop
    case cafe
    case fence
    case lamp
    case flowersGround
    case stonePathGround
    case streetTree
    case apartment
    case emojiFallback
}

enum BuildingAnchorStyle {
    case centered
    case structure
    case fence
}

struct BuildingRenderSpec {
    let kind: BuildingRenderKind
    let baselineRows32: Int
    let isoShearY: CGFloat
    let anchorStyle: BuildingAnchorStyle
    let emojiScale: CGFloat

    static let byID: [String: BuildingRenderSpec] = [
        // Ground
        "flowers": .init(kind: .flowersGround, baselineRows32: 0, isoShearY: 0, anchorStyle: .centered, emojiScale: 0.8),
        "stone_path": .init(kind: .stonePathGround, baselineRows32: 0, isoShearY: 0, anchorStyle: .centered, emojiScale: 0.8),

        // Object
        "house": .init(kind: .house, baselineRows32: 4, isoShearY: 0, anchorStyle: .structure, emojiScale: 0.8),
        "shop": .init(kind: .shop, baselineRows32: 4, isoShearY: 0, anchorStyle: .structure, emojiScale: 0.8),
        "cafe": .init(kind: .cafe, baselineRows32: 4, isoShearY: 0, anchorStyle: .structure, emojiScale: 0.8),
        "apartment": .init(kind: .apartment, baselineRows32: 3, isoShearY: 0, anchorStyle: .structure, emojiScale: 0.8),
        "cityhall": .init(kind: .emojiFallback, baselineRows32: 0, isoShearY: -0.5, anchorStyle: .structure, emojiScale: 0.6),
        "hotel": .init(kind: .emojiFallback, baselineRows32: 0, isoShearY: -0.5, anchorStyle: .structure, emojiScale: 0.6),
        "skyscraper": .init(kind: .emojiFallback, baselineRows32: 0, isoShearY: -0.5, anchorStyle: .structure, emojiScale: 0.6),
        "windmill": .init(kind: .windmill, baselineRows32: 3, isoShearY: -0.5, anchorStyle: .structure, emojiScale: 0.8),

        // Decoration
        "tree": .init(kind: .tree, baselineRows32: 12, isoShearY: 0, anchorStyle: .centered, emojiScale: 0.8),
        "fence": .init(kind: .fence, baselineRows32: 8, isoShearY: 0, anchorStyle: .fence, emojiScale: 0.8),
        "lamp": .init(kind: .lamp, baselineRows32: 4, isoShearY: 0, anchorStyle: .centered, emojiScale: 0.8),
        "street_tree": .init(kind: .streetTree, baselineRows32: 13, isoShearY: 0, anchorStyle: .centered, emojiScale: 0.8),
    ]

    static func fallback(for building: BuildingType) -> BuildingRenderSpec {
        switch building.layer {
        case .ground:
            return .init(kind: .emojiFallback, baselineRows32: 0, isoShearY: 0, anchorStyle: .centered, emojiScale: 0.8)
        case .decoration:
            return .init(kind: .emojiFallback, baselineRows32: 0, isoShearY: 0, anchorStyle: .centered, emojiScale: 0.8)
        case .object:
            return .init(kind: .emojiFallback, baselineRows32: 0, isoShearY: -0.5, anchorStyle: .structure, emojiScale: 0.8)
        }
    }

    func placementOffset(blockSize: CGFloat) -> CGSize {
        switch anchorStyle {
        case .centered:
            return .zero
        case .structure:
            return CGSize(width: -blockSize / 16, height: blockSize / 16)
        case .fence:
            return CGSize(width: blockSize / 32, height: blockSize / 10)
        }
    }
}

extension BuildingType {
    var renderSpec: BuildingRenderSpec {
        BuildingRenderSpec.byID[id] ?? BuildingRenderSpec.fallback(for: self)
    }
}

struct BuildingCatalog {
    static let all: [BuildingType] = [
        // Ground types
        BuildingType(id: "flowers",     name: LocalizedString("Flowers",     ko: "꽃밭"),   emoji: "🌸", layer: .ground,     unlockLevel: 2,  animated: false, price: 5),
        BuildingType(id: "stone_path",  name: LocalizedString("Stone Path",  ko: "돌길"),   emoji: "🪨", layer: .ground,     unlockLevel: 7,  animated: false, price: 10),

        // Objects
        BuildingType(id: "house",       name: LocalizedString("House",       ko: "집"),     emoji: "🏠", layer: .object,     unlockLevel: 5,  animated: true,  price: 25),
        BuildingType(id: "shop",        name: LocalizedString("Shop",        ko: "상점"),   emoji: "🏪", layer: .object,     unlockLevel: 12, animated: true,  price: 40),
        BuildingType(id: "cafe",        name: LocalizedString("Cafe",        ko: "카페"),     emoji: "☕", layer: .object,     unlockLevel: 14, animated: true,  price: 50),
        BuildingType(id: "apartment",   name: LocalizedString("Apartment",   ko: "아파트"),   emoji: "🏢", layer: .object,     unlockLevel: 15, animated: false, price: 60),
        BuildingType(id: "cityhall",    name: LocalizedString("City Hall",   ko: "시청"),     emoji: "🏛️", layer: .object,     unlockLevel: 17, animated: false, price: 80),
        BuildingType(id: "hotel",       name: LocalizedString("Hotel",       ko: "호텔"),     emoji: "🏨", layer: .object,     unlockLevel: 18, animated: false, price: 90),
        BuildingType(id: "skyscraper",  name: LocalizedString("Skyscraper",  ko: "고층빌딩"), emoji: "🏙️", layer: .object,     unlockLevel: 19, animated: false, price: 120),
        BuildingType(id: "windmill",    name: LocalizedString("Windmill",    ko: "풍차"),     emoji: "🌾", layer: .object,     unlockLevel: 20, animated: true,  price: 100),

        // Decorations
        BuildingType(id: "tree",        name: LocalizedString("Tree",        ko: "나무"),   emoji: "🌳", layer: .decoration, unlockLevel: 1,  animated: true,  price: 3),
        BuildingType(id: "fence",       name: LocalizedString("Fence",       ko: "울타리"), emoji: "🪵", layer: .decoration, unlockLevel: 3,  animated: false, price: 5),
        BuildingType(id: "lamp",        name: LocalizedString("Lamp",        ko: "가로등"), emoji: "💡", layer: .decoration, unlockLevel: 8,  animated: true,  price: 12),
        BuildingType(id: "street_tree", name: LocalizedString("Street Tree", ko: "가로수"), emoji: "🌲", layer: .decoration, unlockLevel: 10, animated: true,  price: 15),
    ]

    private static let byID = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })
    private static let byLayer = Dictionary(grouping: all, by: \.layer)

    static func find(_ id: String) -> BuildingType? {
        byID[id]
    }

    static func forLayer(_ layer: TileLayer) -> [BuildingType] {
        byLayer[layer] ?? []
    }
}
