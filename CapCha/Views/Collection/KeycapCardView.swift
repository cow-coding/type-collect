import SwiftUI

struct KeycapCardView: View {
    let keycap: Keycap
    let isCollected: Bool
    var count: Int = 1

    @State private var isHovering = false

    private var cardWidthUnit: CGFloat {
        keycap.widthUnit
    }

    private var cardSize: CGFloat {
        keycap.widthUnit >= 5.0 ? 70 : 70
    }

    var body: some View {
        VStack(spacing: 4) {
            ZStack(alignment: .topTrailing) {
                KeycapShapeView(
                    primaryColor: keycap.primaryColor,
                    legendCharacter: keycap.legendCharacter,
                    rarity: keycap.rarity,
                    isCollected: isCollected,
                    size: cardSize,
                    widthUnit: cardWidthUnit,
                    setName: keycap.setName
                )

                // Duplicate count badge
                if isCollected && count > 1 {
                    Text("\u{00D7}\(count)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.black.opacity(0.6)))
                        .offset(x: -2, y: 4)
                }
            }

            // Name + Set
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
