import Foundation

struct KeyDefinition {
    let legend: String
    let displayName: String
    let row: Int
    let widthUnit: CGFloat

    init(legend: String, displayName: String, row: Int, widthUnit: CGFloat = 1.0) {
        self.legend = legend
        self.displayName = displayName
        self.row = row
        self.widthUnit = widthUnit
    }
}

struct KeycapSet {
    let name: String
    let prefix: String
    let palette: [Rarity: [String]]
    let tintColor: (hue: Double, saturation: Double, brightness: Double)
}

struct KeycapCatalog {

    // MARK: - TKL 87 Keys

    static let keys: [KeyDefinition] = [
        // Row 0: Function (1u)
        KeyDefinition(legend: "Esc", displayName: "Escape", row: 0),
        KeyDefinition(legend: "F1", displayName: "F1", row: 0),
        KeyDefinition(legend: "F2", displayName: "F2", row: 0),
        KeyDefinition(legend: "F3", displayName: "F3", row: 0),
        KeyDefinition(legend: "F4", displayName: "F4", row: 0),
        KeyDefinition(legend: "F5", displayName: "F5", row: 0),
        KeyDefinition(legend: "F6", displayName: "F6", row: 0),
        KeyDefinition(legend: "F7", displayName: "F7", row: 0),
        KeyDefinition(legend: "F8", displayName: "F8", row: 0),
        KeyDefinition(legend: "F9", displayName: "F9", row: 0),
        KeyDefinition(legend: "F10", displayName: "F10", row: 0),
        KeyDefinition(legend: "F11", displayName: "F11", row: 0),
        KeyDefinition(legend: "F12", displayName: "F12", row: 0),
        // Row 1: Numbers (1u) + Backspace (2u)
        KeyDefinition(legend: "`", displayName: "Grave", row: 1),
        KeyDefinition(legend: "1", displayName: "1", row: 1),
        KeyDefinition(legend: "2", displayName: "2", row: 1),
        KeyDefinition(legend: "3", displayName: "3", row: 1),
        KeyDefinition(legend: "4", displayName: "4", row: 1),
        KeyDefinition(legend: "5", displayName: "5", row: 1),
        KeyDefinition(legend: "6", displayName: "6", row: 1),
        KeyDefinition(legend: "7", displayName: "7", row: 1),
        KeyDefinition(legend: "8", displayName: "8", row: 1),
        KeyDefinition(legend: "9", displayName: "9", row: 1),
        KeyDefinition(legend: "0", displayName: "0", row: 1),
        KeyDefinition(legend: "-", displayName: "Minus", row: 1),
        KeyDefinition(legend: "=", displayName: "Equal", row: 1),
        KeyDefinition(legend: "BS", displayName: "Backspace", row: 1, widthUnit: 2.0),
        // Row 2: Tab (1.5u) + QWERTY (1u) + Backslash (1.5u)
        KeyDefinition(legend: "Tab", displayName: "Tab", row: 2, widthUnit: 1.5),
        KeyDefinition(legend: "Q", displayName: "Q", row: 2),
        KeyDefinition(legend: "W", displayName: "W", row: 2),
        KeyDefinition(legend: "E", displayName: "E", row: 2),
        KeyDefinition(legend: "R", displayName: "R", row: 2),
        KeyDefinition(legend: "T", displayName: "T", row: 2),
        KeyDefinition(legend: "Y", displayName: "Y", row: 2),
        KeyDefinition(legend: "U", displayName: "U", row: 2),
        KeyDefinition(legend: "I", displayName: "I", row: 2),
        KeyDefinition(legend: "O", displayName: "O", row: 2),
        KeyDefinition(legend: "P", displayName: "P", row: 2),
        KeyDefinition(legend: "[", displayName: "Left Bracket", row: 2),
        KeyDefinition(legend: "]", displayName: "Right Bracket", row: 2),
        KeyDefinition(legend: "\\", displayName: "Backslash", row: 2, widthUnit: 1.5),
        // Row 3: CapsLock (1.75u) + Home (1u) + Enter (2.25u)
        KeyDefinition(legend: "Caps", displayName: "CapsLock", row: 3, widthUnit: 1.75),
        KeyDefinition(legend: "A", displayName: "A", row: 3),
        KeyDefinition(legend: "S", displayName: "S", row: 3),
        KeyDefinition(legend: "D", displayName: "D", row: 3),
        KeyDefinition(legend: "F", displayName: "F", row: 3),
        KeyDefinition(legend: "G", displayName: "G", row: 3),
        KeyDefinition(legend: "H", displayName: "H", row: 3),
        KeyDefinition(legend: "J", displayName: "J", row: 3),
        KeyDefinition(legend: "K", displayName: "K", row: 3),
        KeyDefinition(legend: "L", displayName: "L", row: 3),
        KeyDefinition(legend: ";", displayName: "Semicolon", row: 3),
        KeyDefinition(legend: "'", displayName: "Quote", row: 3),
        KeyDefinition(legend: "Enter", displayName: "Enter", row: 3, widthUnit: 2.25),
        // Row 4: LShift (2.25u) + Bottom (1u) + RShift (2.75u)
        KeyDefinition(legend: "Shift", displayName: "Left Shift", row: 4, widthUnit: 2.25),
        KeyDefinition(legend: "Z", displayName: "Z", row: 4),
        KeyDefinition(legend: "X", displayName: "X", row: 4),
        KeyDefinition(legend: "C", displayName: "C", row: 4),
        KeyDefinition(legend: "V", displayName: "V", row: 4),
        KeyDefinition(legend: "B", displayName: "B", row: 4),
        KeyDefinition(legend: "N", displayName: "N", row: 4),
        KeyDefinition(legend: "M", displayName: "M", row: 4),
        KeyDefinition(legend: ",", displayName: "Comma", row: 4),
        KeyDefinition(legend: ".", displayName: "Period", row: 4),
        KeyDefinition(legend: "/", displayName: "Slash", row: 4),
        KeyDefinition(legend: "Shift", displayName: "Right Shift", row: 4, widthUnit: 2.75),
        // Row 5: Modifiers (1.25u) + Space (6.25u)
        KeyDefinition(legend: "Ctrl", displayName: "Left Ctrl", row: 5, widthUnit: 1.25),
        KeyDefinition(legend: "Alt", displayName: "Left Alt", row: 5, widthUnit: 1.25),
        KeyDefinition(legend: "Cmd", displayName: "Left Cmd", row: 5, widthUnit: 1.25),
        KeyDefinition(legend: "Space", displayName: "Space", row: 5, widthUnit: 6.25),
        KeyDefinition(legend: "Cmd", displayName: "Right Cmd", row: 5, widthUnit: 1.25),
        KeyDefinition(legend: "Alt", displayName: "Right Alt", row: 5, widthUnit: 1.25),
        KeyDefinition(legend: "Fn", displayName: "Fn", row: 5, widthUnit: 1.25),
        KeyDefinition(legend: "Ctrl", displayName: "Right Ctrl", row: 5, widthUnit: 1.25),
        // Navigation
        KeyDefinition(legend: "Ins", displayName: "Insert", row: 0),
        KeyDefinition(legend: "Home", displayName: "Home", row: 0),
        KeyDefinition(legend: "PgUp", displayName: "Page Up", row: 0),
        KeyDefinition(legend: "Del", displayName: "Delete", row: 1),
        KeyDefinition(legend: "End", displayName: "End", row: 1),
        KeyDefinition(legend: "PgDn", displayName: "Page Down", row: 1),
        // Arrows
        KeyDefinition(legend: "↑", displayName: "Up", row: 4),
        KeyDefinition(legend: "←", displayName: "Left", row: 5),
        KeyDefinition(legend: "↓", displayName: "Down", row: 5),
        KeyDefinition(legend: "→", displayName: "Right", row: 5),
        // Top right
        KeyDefinition(legend: "PrtSc", displayName: "Print Screen", row: 0),
        KeyDefinition(legend: "ScrLk", displayName: "Scroll Lock", row: 0),
        KeyDefinition(legend: "Pause", displayName: "Pause", row: 0),
    ]

    // MARK: - Sets

    static let sets: [KeycapSet] = [
        KeycapSet(name: "Mechanical Classics", prefix: "mech", palette: [
            .common:    ["#CC3333", "#B22222", "#8B1A1A", "#CD5555", "#A52A2A"],
            .uncommon:  ["#FF4444", "#E8352E", "#D44A3C", "#DC143C"],
            .rare:      ["#FF6B6B", "#FF5252", "#FF4500"],
            .epic:      ["#FF1744", "#E91E63"],
            .legendary: ["#FF0000"],
            .eternal:   ["#FF2060"],
        ], tintColor: (hue: 0.0, saturation: 0.75, brightness: 1.0)),
        KeycapSet(name: "Retro Computing", prefix: "retro", palette: [
            .common:    ["#D4C5A9", "#C2B280", "#BDB76B", "#D2B48C", "#CDBA96"],
            .uncommon:  ["#DEB887", "#D2691E", "#BC8F8F", "#A0522D"],
            .rare:      ["#8B7355", "#6B4226", "#8B6914"],
            .epic:      ["#8B4513", "#654321"],
            .legendary: ["#3D2B1F"],
            .eternal:   ["#FFD700"],
        ], tintColor: (hue: 0.08, saturation: 0.45, brightness: 1.2)),
        KeycapSet(name: "Artisan Collection", prefix: "artisan", palette: [
            .common:    ["#9370DB", "#8A2BE2", "#9B59B6", "#8E44AD", "#7E57C2"],
            .uncommon:  ["#7B68EE", "#6A5ACD", "#663399", "#5C6BC0"],
            .rare:      ["#4B0082", "#551A8B", "#4527A0"],
            .epic:      ["#800080", "#6A0DAD"],
            .legendary: ["#4A0070"],
            .eternal:   ["#E040FB"],
        ], tintColor: (hue: 0.75, saturation: 0.65, brightness: 1.0)),
        KeycapSet(name: "Nature Elements", prefix: "nature", palette: [
            .common:    ["#228B22", "#2E8B57", "#3CB371", "#66CDAA", "#4CAF50"],
            .uncommon:  ["#006400", "#008B45", "#00C853", "#00897B"],
            .rare:      ["#00FF7F", "#00FA9A", "#1DE9B6"],
            .epic:      ["#00E676", "#00BFA5"],
            .legendary: ["#004D40"],
            .eternal:   ["#76FF03"],
        ], tintColor: (hue: 0.35, saturation: 0.70, brightness: 1.0)),
        KeycapSet(name: "Space Theme", prefix: "space", palette: [
            .common:    ["#191970", "#1C1C5E", "#2F2F6E", "#4169E1", "#3949AB"],
            .uncommon:  ["#0000CD", "#0000FF", "#1E90FF", "#2979FF"],
            .rare:      ["#00BFFF", "#00CED1", "#40C4FF"],
            .epic:      ["#7DF9FF", "#18FFFF"],
            .legendary: ["#E0FFFF"],
            .eternal:   ["#B388FF"],
        ], tintColor: (hue: 0.60, saturation: 0.75, brightness: 0.9)),
    ]

    // MARK: - Dynamic Generation

    static func randomKeycap(for rarity: Rarity) -> Keycap? {
        guard let set = sets.randomElement(),
              let key = keys.randomElement(),
              let colors = set.palette[rarity],
              let color = colors.randomElement()
        else { return nil }

        let id = "\(set.prefix)-\(key.displayName.lowercased().replacingOccurrences(of: " ", with: "-"))-\(rarity.rawValue)"

        return Keycap(
            id: id,
            name: key.displayName,
            rarity: rarity,
            legendCharacter: key.legend,
            primaryColor: color,
            setName: set.name,
            widthUnit: key.widthUnit
        )
    }

    static var totalCombinations: Int {
        keys.count * sets.count * Rarity.allCases.count
    }

    static func tintColor(for setName: String) -> (hue: Double, saturation: Double, brightness: Double) {
        sets.first { $0.name == setName }?.tintColor ?? (hue: 0, saturation: 0, brightness: 1.0)
    }

    /// Asset name for a given widthUnit
    static func assetName(for widthUnit: CGFloat) -> String {
        if widthUnit >= 5.0 { return "keycap_space" }
        if widthUnit >= 2.5 { return "keycap_2_75u" }
        if widthUnit >= 2.0 { return "keycap_2u" }
        if widthUnit >= 1.25 { return "keycap_1_5u" }
        return "keycap_1u"
    }
}
