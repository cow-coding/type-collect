import SwiftUI
import AppKit

struct DropBubbleContent: View {
    let keycap: Keycap

    private var isEternal: Bool { keycap.rarity.isRainbow }

    var body: some View {
        HStack(spacing: 10) {
            // Keycap preview in tinted box
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(keycap.rarity.color.opacity(isEternal ? 0.05 : 0.1))

                KeycapShapeView(
                    primaryColor: keycap.primaryColor,
                    legendCharacter: keycap.legendCharacter,
                    rarity: keycap.rarity,
                    isCollected: true,
                    size: 36,
                    widthUnit: min(keycap.widthUnit, 1.5),
                    setName: keycap.setName
                )

                // Rainbow tint overlay for Eternal
                if isEternal {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [.red, .blue, .purple, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .opacity(0.15)
                        .allowsHitTesting(false)
                }
            }
            .frame(width: 44, height: 44)

            // Text stack
            VStack(alignment: .leading, spacing: 1) {
                Text("New Drop!")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)

                Text(keycap.name)
                    .font(.system(size: 13, weight: .semibold))
                    .tracking(-0.3)

                if isEternal {
                    RainbowText(
                        keycap.rarity.displayName.uppercased(),
                        font: .system(size: 11, weight: .bold)
                    )
                } else {
                    Text(keycap.rarity.displayName)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(keycap.rarity.color)
                }
            }
        }
        .padding(8)
    }
}

final class DropNotificationManager {
    static let shared = DropNotificationManager()

    weak var anchorButton: NSStatusBarButton?

    private var popover: NSPopover?
    private var hideTask: DispatchWorkItem?

    func show(keycap: Keycap) {
        DispatchQueue.main.async { [weak self] in
            self?.hideTask?.cancel()
            self?.popover?.close()
            self?.presentBubble(keycap: keycap)
        }
    }

    private func presentBubble(keycap: Keycap) {
        // Skip if the button's window has another popover shown (main menu popover)
        if let button = anchorButton, button.window?.attachedSheet != nil {
            return
        }

        guard let button = anchorButton else {
            #if DEBUG
            print("[DropNotification] No anchor button")
            #endif
            return
        }

        let popover = NSPopover()
        popover.contentSize = NSSize(width: 230, height: 60)
        popover.behavior = .applicationDefined
        popover.animates = true
        popover.contentViewController = NSHostingController(rootView: DropBubbleContent(keycap: keycap))

        self.popover = popover

        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)

        let task = DispatchWorkItem { [weak self] in
            self?.popover?.performClose(nil)
            self?.popover = nil
        }
        hideTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: task)
    }
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        switch hex.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
        default:
            r = 1; g = 1; b = 1
        }
        self.init(red: r, green: g, blue: b)
    }
}
