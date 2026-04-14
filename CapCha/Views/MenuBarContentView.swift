import SwiftUI

struct MenuBarContentView: View {
    @ObservedObject var appState: AppState
    @State private var isCollectionHovering = false
    @State private var isSettingsHovering = false
    @State private var isQuitHovering = false
    @State private var hoveredDropId: String?

    var body: some View {
        VStack(spacing: 0) {
            // Header bar
            headerBar

            if appState.isMonitoring {
                statsSection
                thinDivider
                if !appState.recentDrops.isEmpty {
                    recentDropsSection
                }
            } else {
                permissionSection
            }

            // Footer actions
            footerSection
        }
        .frame(width: 280)
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack {
            Image(systemName: "keyboard")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.blue)

            Spacer()

            Text("CapCha")
                .font(.system(size: 14, weight: .bold))
                .tracking(-0.3)

            Spacer()

            // Symmetry spacer
            Color.clear
                .frame(width: 14, height: 14)
        }
        .padding(.horizontal, 12)
        .frame(height: 40)
        .background(.bar)
    }

    // MARK: - Stats

    private var statsSection: some View {
        VStack(spacing: 10) {
            statRow(label: "Today", value: appState.todayKeystrokeCount.formatted(), unit: "KEYSTROKES")
            statRow(label: "Total", value: appState.keystrokeCount.formatted(), unit: "KEYSTROKES")
            statRow(label: "Collected", value: "\(appState.uniqueCollectedCount)", unit: "KEYCAPS")
        }
        .padding(12)
    }

    private func statRow(label: String, value: String, unit: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .tracking(0.5)
                .foregroundStyle(.secondary)
            Spacer()
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                Text(unit)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .tracking(-0.5)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(4)
    }

    // MARK: - Divider

    private var thinDivider: some View {
        Rectangle()
            .fill(.quaternary)
            .frame(height: 1)
            .padding(.horizontal, 12)
    }

    // MARK: - Recent Drops

    private var recentDropsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("RECENT DROPS")
                .font(.system(size: 10, weight: .bold))
                .tracking(1.5)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)

            VStack(spacing: 2) {
                ForEach(appState.recentDrops.prefix(5)) { drop in
                    dropRow(drop: drop)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
    }

    private func dropRow(drop: CollectedKeycap) -> some View {
        HStack {
            HStack(spacing: 12) {
                Circle()
                    .fill(drop.keycap.rarity.color)
                    .frame(width: 8, height: 8)
                    .shadow(
                        color: drop.keycap.rarity.color.opacity(0.35),
                        radius: 4
                    )

                Text(drop.keycap.name)
                    .font(.system(size: 14, weight: .semibold))
                    .tracking(-0.3)
            }

            Spacer()

            if drop.keycap.rarity.isRainbow {
                RainbowText(
                    drop.keycap.rarity.displayName.uppercased(),
                    font: .system(size: 10, weight: .bold)
                )
            } else {
                Text(drop.keycap.rarity.displayName.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.2)
                    .foregroundStyle(drop.keycap.rarity.color)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(hoveredDropId == drop.id
                      ? Color.primary.opacity(0.04)
                      : Color.clear)
        )
        .contentShape(Rectangle())
        .onHover { hovering in
            hoveredDropId = hovering ? drop.id : nil
        }
    }

    // MARK: - Permission

    private var permissionSection: some View {
        VStack(spacing: 8) {
            Text("Input Monitoring permission required")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Open Settings") {
                appState.permissionManager.openInputMonitoringSettings()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
    }

    // MARK: - Footer

    private var footerSection: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(.quaternary)
                .frame(height: 1)

            VStack(spacing: 4) {
                // Open Collection
                Button {
                    NotificationCenter.default.post(name: .openCollectionWindow, object: nil)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "square.grid.2x2")
                            .font(.system(size: 14))
                            .foregroundStyle(isCollectionHovering ? .primary : .secondary)
                        Text("Open Collection")
                            .font(.system(size: 12, weight: .medium))
                        Spacer()
                        Text("\(appState.uniqueCollectedCount)/\(KeycapCatalog.totalCombinations)")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundStyle(isCollectionHovering ? Color.accentColor : .secondary)
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(isCollectionHovering ? Color.primary.opacity(0.05) : Color.clear)
                    )
                }
                .buttonStyle(.plain)
                .onHover { isCollectionHovering = $0 }

                // Settings
                Button {
                    NotificationCenter.default.post(name: .openSettings, object: nil)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 14))
                            .foregroundStyle(isSettingsHovering ? .primary : .secondary)
                        Text("Settings")
                            .font(.system(size: 12, weight: .medium))
                        Spacer()
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(isSettingsHovering ? Color.primary.opacity(0.05) : Color.clear)
                    )
                }
                .buttonStyle(.plain)
                .onHover { isSettingsHovering = $0 }

                // Quit
                Button {
                    NSApplication.shared.terminate(nil)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "power")
                            .font(.system(size: 14))
                            .foregroundStyle(isQuitHovering ? .red : .secondary)
                        Text("Quit CapCha")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(isQuitHovering ? .red : .primary)
                        Spacer()
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(isQuitHovering ? Color.red.opacity(0.08) : Color.clear)
                    )
                }
                .buttonStyle(.plain)
                .onHover { isQuitHovering = $0 }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(.bar)
        }
    }
}
