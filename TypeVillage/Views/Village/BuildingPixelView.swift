import SwiftUI

/// Renders a building as pixel art. Placeholder: emoji for now, will replace with
/// actual pixel art per building type in future iterations.
struct BuildingPixelView: View {
    let building: BuildingType
    let size: CGFloat

    var body: some View {
        Text(building.emoji)
            .font(.system(size: size * 0.8))
    }
}
