import SwiftUI

/// Shared design tokens with light/dark mode support
enum DesignTokens {
    // MARK: - Surface colors

    static let surface = Color(
        light: Color(red: 0.98, green: 0.98, blue: 0.99),   // #fafbfd
        dark: Color(red: 0.047, green: 0.055, blue: 0.071)   // #0c0e12
    )

    static let surfaceContainer = Color(
        light: Color(red: 0.94, green: 0.945, blue: 0.96),   // #f0f1f5
        dark: Color(red: 0.09, green: 0.102, blue: 0.122)    // #171a1f
    )

    static let surfaceContainerHigh = Color(
        light: Color(red: 0.91, green: 0.92, blue: 0.94),    // #e8eaf0
        dark: Color(red: 0.11, green: 0.125, blue: 0.15)     // #1c2026
    )

    static let surfaceContainerLowest = Color(
        light: Color.white,                                    // #ffffff
        dark: Color.black                                      // #000000
    )

    // MARK: - Content colors

    static let onSurface = Color(
        light: Color(red: 0.1, green: 0.1, blue: 0.12),      // #1a1a1f
        dark: Color(red: 0.886, green: 0.898, blue: 0.937)   // #e2e5ef
    )

    static let outline = Color(
        light: Color(red: 0.45, green: 0.47, blue: 0.52),    // #737885
        dark: Color(red: 0.447, green: 0.459, blue: 0.494)   // #72757e
    )

    // MARK: - Accent colors

    static let primary = Color(red: 0.757, green: 0.502, blue: 1.0)  // #c180ff (same in both modes)
    static let primaryDim = Color(red: 0.612, green: 0.282, blue: 0.918) // #9c48ea
}

// MARK: - Color convenience init for light/dark

extension Color {
    init(light: Color, dark: Color) {
        self.init(nsColor: NSColor(name: nil) { appearance in
            let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            return isDark ? NSColor(dark) : NSColor(light)
        })
    }
}
