import SwiftUI

struct KeycapDetailView: View {
    let keycap: Keycap
    let collected: CollectedKeycap?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            // Keycap preview
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(collected != nil ? Color(hex: keycap.primaryColor) : Color.gray.opacity(0.3))
                    .frame(width: 120, height: 100)

                if collected != nil {
                    Text(keycap.legendCharacter)
                        .font(.system(size: 40, weight: .bold, design: .monospaced))
                        .foregroundColor(DropBubbleContent.legendColor(for: keycap.primaryColor))
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.gray.opacity(0.5))
                }
            }

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
                    detailRow("Collected", value: formatted(date: collected.collectedAt))
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
        .frame(width: 300, height: 380)
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
