import SwiftUI

struct KeycapDetailView: View {
    let keycap: Keycap
    let collected: CollectedKeycap?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            // Keycap preview
            KeycapShapeView(
                primaryColor: keycap.primaryColor,
                legendCharacter: keycap.legendCharacter,
                rarity: keycap.rarity,
                isCollected: collected != nil,
                size: 140
            )

            // Info
            VStack(spacing: 8) {
                Text(collected != nil ? keycap.name : "???")
                    .font(.title2)
                    .fontWeight(.bold)

                if keycap.rarity.isRainbow {
                    RainbowText(keycap.rarity.displayName, font: .system(size: 14, weight: .bold))
                } else {
                    Text(keycap.rarity.displayName)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(keycap.rarity.color)
                }

                Text(keycap.setName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if let collected = collected {
                Divider()
                    .padding(.horizontal, 40)

                VStack(spacing: 6) {
                    detailRow("Owned", value: "\u{00D7}\(collected.count)")
                    detailRow("First Drop", value: formatted(date: collected.firstCollectedAt))
                    if collected.count > 1 {
                        detailRow("Last Drop", value: formatted(date: collected.lastCollectedAt))
                    }
                    detailRow("Keystroke #", value: "\(collected.keystrokeNumber)")
                }
            } else {
                Text("Keep typing to unlock!")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            }

            Spacer()

            Button("Close") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.regular)
        }
        .padding(24)
        .frame(width: 320, height: 440)
    }

    private func detailRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
                .font(.caption)
            Spacer()
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 40)
    }

    private func formatted(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
