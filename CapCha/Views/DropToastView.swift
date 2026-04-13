import SwiftUI
import AppKit

struct DropBubbleContent: View {
    let keycap: Keycap

    var body: some View {
        HStack(spacing: 10) {
            KeycapShapeView(
                primaryColor: keycap.primaryColor,
                legendCharacter: keycap.legendCharacter,
                rarity: keycap.rarity,
                isCollected: true,
                size: 44,
                widthUnit: keycap.widthUnit,
                setName: keycap.setName
            )

            VStack(alignment: .leading, spacing: 2) {
                Text("New Drop!")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                Text(keycap.name)
                    .font(.system(size: 13, weight: .semibold))
                if keycap.rarity.isRainbow {
                    RainbowText(keycap.rarity.displayName)
                } else {
                    Text(keycap.rarity.displayName)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(keycap.rarity.color)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    static func legendColor(for hex: String) -> Color {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0
        let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
        return luminance > 0.5 ? .black : .white
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
