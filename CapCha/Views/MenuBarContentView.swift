import SwiftUI

struct MenuBarContentView: View {
    @ObservedObject var appState: AppState
    @State private var isCollectionHovering = false
    @State private var isSettingsHovering = false
    @State private var isQuitHovering = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 6) {
                Image("MenuBarIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 16)
                Text("CapCha")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)

            Divider()

            // Stats
            VStack(alignment: .leading, spacing: 8) {
                if appState.isMonitoring {
                    HStack {
                        Text("Today")
                            .foregroundColor(.secondary)
                            .font(.system(size: 12))
                        Spacer()
                        Text("\(appState.todayKeystrokeCount.formatted())")
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.semibold)
                        Text("keystrokes")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Total")
                            .foregroundColor(.secondary)
                            .font(.system(size: 12))
                        Spacer()
                        Text("\(appState.keystrokeCount.formatted())")
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.semibold)
                        Text("keystrokes")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Collected")
                            .foregroundColor(.secondary)
                            .font(.system(size: 12))
                        Spacer()
                        Text("\(appState.uniqueCollectedCount)")
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.semibold)
                        Text("keycaps")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                } else {
                    VStack(spacing: 8) {
                        Text("Input Monitoring permission required")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Open Settings") {
                            appState.permissionManager.openInputMonitoringSettings()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            // Recent Drops
            if !appState.recentDrops.isEmpty {
                Divider()

                VStack(alignment: .leading, spacing: 4) {
                    Text("Recent Drops")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 2)

                    ForEach(appState.recentDrops.prefix(6)) { drop in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(drop.keycap.rarity.color)
                                .frame(width: 8, height: 8)
                            Text(drop.keycap.name)
                                .font(.system(size: 12))
                            Spacer()
                            if drop.keycap.rarity.isRainbow {
                                RainbowText(drop.keycap.rarity.displayName, font: .system(size: 10, weight: .bold))
                            } else {
                                Text(drop.keycap.rarity.displayName)
                                    .font(.system(size: 10))
                                    .foregroundColor(drop.keycap.rarity.color)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }

            Divider()

            // Collection button
            Button(action: {
                NotificationCenter.default.post(name: .openCollectionWindow, object: nil)
            }) {
                HStack {
                    Image(systemName: "square.grid.2x2")
                    Text("Open Collection")
                    Spacer()
                    Text("\(appState.uniqueCollectedCount)/\(KeycapCatalog.totalCombinations)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(isCollectionHovering ? Color.accentColor.opacity(0.12) : Color.clear)
                .cornerRadius(6)
                .foregroundColor(isCollectionHovering ? .accentColor : .primary)
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                isCollectionHovering = hovering
            }
            .padding(.horizontal, 6)
            .padding(.top, 6)

            // Settings
            Button(action: {
                NotificationCenter.default.post(name: .openSettings, object: nil)
            }) {
                HStack {
                    Image(systemName: "gearshape")
                    Text("Settings")
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(isSettingsHovering ? Color.primary.opacity(0.08) : Color.clear)
                .cornerRadius(6)
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                isSettingsHovering = hovering
            }
            .padding(.horizontal, 6)

            // Footer
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                HStack {
                    Image(systemName: "power")
                    Text("Quit CapCha")
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(isQuitHovering ? Color.red.opacity(0.15) : Color.clear)
                .cornerRadius(6)
                .foregroundColor(isQuitHovering ? .red : .primary)
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                isQuitHovering = hovering
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 6)
        }
        .frame(width: 280)
    }
}
