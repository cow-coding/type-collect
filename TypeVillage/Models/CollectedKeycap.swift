import Foundation

struct CollectedKeycap: Identifiable, Codable {
    let id: String              // Deterministic: "prefix-key-rarity"
    let keycap: Keycap
    var count: Int              // Number of times this keycap has been dropped
    let firstCollectedAt: Date  // When it was first collected
    var lastCollectedAt: Date   // When it was most recently collected
    let keystrokeNumber: Int    // Keystroke number of first drop
}
