import AppKit
import SwiftUI

/// Level-up notification shown as a popover bubble from the menu bar status item button.
final class LevelUpToastManager {
    static let shared = LevelUpToastManager()

    weak var anchorButton: NSStatusBarButton?

    private var popover: NSPopover?
    private var hideTask: DispatchWorkItem?

    func show(fromLevel: Int, toLevel: Int, unlocked: [BuildingType]) {
        guard AppSettings.shared.showDropNotifications else { return }
        DispatchQueue.main.async { [weak self] in
            self?.hideTask?.cancel()
            self?.popover?.close()
            self?.present(fromLevel: fromLevel, toLevel: toLevel, unlocked: unlocked)
        }
    }

    private func present(fromLevel: Int, toLevel: Int, unlocked: [BuildingType]) {
        guard let button = anchorButton else { return }
        if button.window?.attachedSheet != nil { return }

        let hasUnlock = !unlocked.isEmpty
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 260, height: hasUnlock ? 110 : 70)
        popover.behavior = .applicationDefined
        popover.animates = true
        popover.contentViewController = NSHostingController(
            rootView: LevelUpBubbleContent(fromLevel: fromLevel, toLevel: toLevel, unlocked: unlocked)
        )

        self.popover = popover
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)

        // Unlock toast stays longer so the user can read it
        let duration = hasUnlock ? 4.5 : 3.0
        let task = DispatchWorkItem { [weak self] in
            self?.popover?.performClose(nil)
            self?.popover = nil
        }
        hideTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: task)
    }
}

struct LevelUpBubbleContent: View {
    let fromLevel: Int
    let toLevel: Int
    let unlocked: [BuildingType]

    @ObservedObject var settings = AppSettings.shared
    private var lang: AppLanguage { settings.language }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                LvUpBadgeView(width: 56)

                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.levelUp.resolve(lang))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)

                    HStack(spacing: 4) {
                        Text("Lv.\(fromLevel)")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.secondary)
                        Text("Lv.\(toLevel)")
                            .font(.system(size: 14, weight: .heavy, design: .rounded))
                            .foregroundStyle(.orange)
                    }
                }

                Spacer(minLength: 0)
            }

            // Unlocked content section
            if !unlocked.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.yellow)
                    Text(L10n.newUnlock.resolve(lang))
                        .font(.system(size: 10, weight: .heavy))
                        .tracking(0.5)
                        .foregroundStyle(.yellow)

                    ForEach(unlocked) { building in
                        HStack(spacing: 3) {
                            BuildingPixelView(building: building, size: 18)
                                .frame(width: 18, height: 18)
                            Text(building.name.resolve(lang))
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.primary)
                        }
                        .padding(.horizontal, 5)
                        .padding(.vertical, 3)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.yellow.opacity(0.15))
                        )
                    }
                    Spacer(minLength: 0)
                }
            }
        }
        .padding(10)
    }
}
