import Foundation

struct DropEngine {
    /// Base drop chance per keystroke
    static let baseDropChance: Double = 0.0025

    /// Calculate drop chance with pity system
    /// 0-499: 0.25% base, 500-999: 0.25%→0.5% ramp, 1000-1999: 0.5%→1.0% ramp, 2000+: guaranteed
    static func dropChance(keystrokesSinceLastDrop: Int) -> Double {
        let since = keystrokesSinceLastDrop
        if since < 500 {
            return baseDropChance
        } else if since < 1000 {
            let t = Double(since - 500) / 500.0
            return baseDropChance + t * (0.005 - baseDropChance)
        } else if since < 2000 {
            let t = Double(since - 1000) / 1000.0
            return 0.005 + t * (0.01 - 0.005)
        } else {
            return 1.0
        }
    }

    /// Determine whether a drop occurs with pity
    static func shouldDrop(keystrokesSinceLastDrop: Int) -> Bool {
        Double.random(in: 0..<1) < dropChance(keystrokesSinceLastDrop: keystrokesSinceLastDrop)
    }

    /// Determine rarity via weighted random
    static func rollRarity() -> Rarity {
        let roll = Double.random(in: 0..<1)
        var cumulative = 0.0
        for rarity in Rarity.allCases {
            cumulative += rarity.dropWeight
            if roll < cumulative {
                return rarity
            }
        }
        return .common
    }

    /// Execute drop with pity system
    static func executeDrop(keystrokesSinceLastDrop: Int, isFirstDrop: Bool = false) -> Keycap? {
        // First-time user: guarantee a Common drop within 100 keystrokes
        if isFirstDrop && keystrokesSinceLastDrop >= 100 {
            return KeycapCatalog.randomKeycap(for: .common)
        }

        guard shouldDrop(keystrokesSinceLastDrop: keystrokesSinceLastDrop) else { return nil }
        let rarity = rollRarity()
        return KeycapCatalog.randomKeycap(for: rarity)
    }
}
