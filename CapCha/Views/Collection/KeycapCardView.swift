import SwiftUI

struct KeycapCardView: View {
    let keycap: Keycap
    let isCollected: Bool

    @State private var isHovering = false

    var body: some View {
        VStack(spacing: 4) {
            KeycapShapeView(
                primaryColor: keycap.primaryColor,
                legendCharacter: keycap.legendCharacter,
                isCollected: isCollected,
                size: 80
            )

            // Name
            Text(isCollected ? keycap.name : "???")
                .font(.system(size: 11, weight: .medium))
                .lineLimit(1)
                .foregroundColor(isCollected ? .primary : .secondary)

            // Rarity badge
            if keycap.rarity.isRainbow && isCollected {
                RainbowText(keycap.rarity.displayName, font: .system(size: 9, weight: .bold))
            } else {
                Text(keycap.rarity.displayName)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(isCollected ? keycap.rarity.color : .gray)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isHovering ? Color.primary.opacity(0.05) : Color.clear)
        )
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
