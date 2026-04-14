import Foundation

struct Keycap: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let rarity: Rarity
    let legendCharacter: String
    let primaryColor: String  // Hex
    let setName: String
    let widthUnit: CGFloat

    init(id: String, name: String, rarity: Rarity, legendCharacter: String, primaryColor: String, setName: String, widthUnit: CGFloat = 1.0) {
        self.id = id
        self.name = name
        self.rarity = rarity
        self.legendCharacter = legendCharacter
        self.primaryColor = primaryColor
        self.setName = setName
        self.widthUnit = widthUnit
    }

    // Decode with default widthUnit for backwards compatibility
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        rarity = try container.decode(Rarity.self, forKey: .rarity)
        legendCharacter = try container.decode(String.self, forKey: .legendCharacter)
        primaryColor = try container.decode(String.self, forKey: .primaryColor)
        setName = try container.decode(String.self, forKey: .setName)
        widthUnit = try container.decodeIfPresent(CGFloat.self, forKey: .widthUnit) ?? 1.0
    }
}
