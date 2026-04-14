import SwiftUI

struct KeycapCardView: View {
    let keycap: Keycap
    let isCollected: Bool
    var count: Int = 1

    @State private var isHovering = false

    // Design tokens
    private let surfaceContainerHigh = Color(red: 0.11, green: 0.125, blue: 0.15)
    private let surfaceContainerLowest = Color.black
    private let onSurface = Color(red: 0.886, green: 0.898, blue: 0.937)
    private let outline = Color(red: 0.447, green: 0.459, blue: 0.494)

    private var cardWidthUnit: CGFloat {
        keycap.widthUnit
    }

    private var cardSize: CGFloat {
        70
    }

    /// Rarity-based glow color for hover effect
    private var glowColor: Color {
        isCollected ? keycap.rarity.color : outline
    }

    var body: some View {
        VStack(spacing: 0) {
            // Inner keycap display area
            ZStack(alignment: .topTrailing) {
                // Background with rarity gradient
                RoundedRectangle(cornerRadius: 20)
                    .fill(surfaceContainerLowest)
                    .overlay(
                        LinearGradient(
                            colors: [
                                isCollected ? glowColor.opacity(0.1) : Color.clear,
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    )

                // Keycap shape centered
                KeycapShapeView(
                    primaryColor: keycap.primaryColor,
                    legendCharacter: keycap.legendCharacter,
                    rarity: keycap.rarity,
                    isCollected: isCollected,
                    size: cardSize,
                    widthUnit: cardWidthUnit,
                    setName: keycap.setName
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Duplicate count badge (top-right)
                if isCollected && count > 1 {
                    Text("x\(count)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(onSurface)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.black.opacity(0.5))
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(.ultraThinMaterial)
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .strokeBorder(outline.opacity(0.3), lineWidth: 0.5)
                        )
                        .padding(10)
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 20))

            // Card footer: name + rarity
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(isCollected ? keycap.name : "???")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(isCollected ? onSurface : outline)
                        .lineLimit(1)

                    if keycap.rarity.isRainbow && isCollected {
                        RainbowText(
                            keycap.rarity.displayName.uppercased(),
                            font: .system(size: 9, weight: .bold)
                        )
                    } else {
                        Text(keycap.rarity.displayName.uppercased())
                            .font(.system(size: 9, weight: .bold))
                            .tracking(1)
                            .foregroundColor(isCollected ? outline : Color.gray)
                    }
                }

                Spacer()

                // Rarity glow dot
                if isCollected {
                    Circle()
                        .fill(keycap.rarity.color)
                        .frame(width: 8, height: 8)
                        .shadow(color: keycap.rarity.color.opacity(0.8), radius: 4, x: 0, y: 0)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(surfaceContainerHigh)
        )
        .shadow(
            color: isHovering ? glowColor.opacity(0.15) : glowColor.opacity(0.05),
            radius: isHovering ? 20 : 12,
            x: 0, y: 0
        )
        .scaleEffect(isHovering ? 1.02 : 1.0)
        .animation(.easeOut(duration: 0.2), value: isHovering)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
