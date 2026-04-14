import SwiftUI

struct KeycapDetailView: View {
    let keycap: Keycap
    let collected: CollectedKeycap?
    var onDismiss: (() -> Void)?
    @Environment(\.dismiss) private var dismiss

    // Design tokens
    private let surface = Color(red: 0.047, green: 0.055, blue: 0.071)
    private let surfaceContainerHigh = Color(red: 0.11, green: 0.125, blue: 0.15)
    private let surfaceContainerLowest = Color.black
    private let onSurface = Color(red: 0.886, green: 0.898, blue: 0.937)
    private let outline = Color(red: 0.447, green: 0.459, blue: 0.494)
    private let primaryColor = Color(red: 0.757, green: 0.502, blue: 1.0)

    private var glowColor: Color {
        keycap.rarity.color
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top bar with close button
            HStack {
                Spacer()
                Button {
                    if let onDismiss { onDismiss() } else { dismiss() }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(outline)
                        .frame(width: 28, height: 28)
                        .background(
                            Circle().fill(surfaceContainerHigh)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            // Keycap display area
            ZStack {
                // Ambient glow behind keycap
                RoundedRectangle(cornerRadius: 24)
                    .fill(surfaceContainerLowest)
                    .overlay(
                        RadialGradient(
                            colors: [
                                glowColor.opacity(0.15),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 140
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                    )

                KeycapShapeView(
                    primaryColor: keycap.primaryColor,
                    legendCharacter: keycap.legendCharacter,
                    rarity: keycap.rarity,
                    isCollected: collected != nil,
                    size: 140,
                    widthUnit: keycap.widthUnit,
                    setName: keycap.setName
                )
            }
            .frame(height: 180)
            .padding(.horizontal, 24)
            .padding(.top, 8)

            // Name + Rarity
            VStack(spacing: 6) {
                Text(collected != nil ? keycap.name : "???")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(onSurface)

                HStack(spacing: 8) {
                    Circle()
                        .fill(keycap.rarity.color)
                        .frame(width: 8, height: 8)
                        .shadow(color: keycap.rarity.color.opacity(0.8), radius: 4)

                    if keycap.rarity.isRainbow {
                        RainbowText(
                            keycap.rarity.displayName.uppercased(),
                            font: .system(size: 11, weight: .bold)
                        )
                    } else {
                        Text(keycap.rarity.displayName.uppercased())
                            .font(.system(size: 11, weight: .bold))
                            .tracking(2)
                            .foregroundColor(keycap.rarity.color)
                    }
                }

                Text(keycap.setName)
                    .font(.system(size: 12))
                    .foregroundColor(outline)
            }
            .padding(.top, 16)

            // Stats section
            if let collected = collected {
                VStack(spacing: 0) {
                    detailRow("Owned", value: "\u{00D7}\(collected.count)")
                    detailRow("First Drop", value: formatted(date: collected.firstCollectedAt))
                    if collected.count > 1 {
                        detailRow("Last Drop", value: formatted(date: collected.lastCollectedAt))
                    }
                    detailRow("Keystroke #", value: "\(collected.keystrokeNumber)")
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(surfaceContainerHigh)
                )
                .padding(.horizontal, 24)
                .padding(.top, 20)
            } else {
                VStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16))
                        .foregroundColor(outline.opacity(0.5))
                    Text("Keep typing to unlock!")
                        .font(.system(size: 12))
                        .foregroundColor(outline)
                }
                .padding(.top, 24)
            }

            Spacer()
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(surface)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .frame(width: max(340, keycap.widthUnit >= 2.0 ? 420 : 340), height: 480)
    }

    private func detailRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .bold))
                .tracking(1)
                .foregroundColor(outline)
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(onSurface)
        }
        .padding(.vertical, 8)
        .overlay(
            Rectangle()
                .fill(outline.opacity(0.1))
                .frame(height: 0.5),
            alignment: .bottom
        )
    }

    private func formatted(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm:ss"
        return formatter.string(from: date)
    }
}
