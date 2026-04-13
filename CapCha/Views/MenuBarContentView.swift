import SwiftUI

struct MenuBarContentView: View {
    @ObservedObject var appState: AppState
    @State private var isCollectionHovering = false
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
            VStack(alignment: .leading, spacing: 6) {
                if appState.isMonitoring {
                    HStack {
                        Text("Keystrokes")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(appState.keystrokeCount)")
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.medium)
                    }

                    HStack {
                        Text("Collected")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(appState.collection.count) / \(KeycapCatalog.all.count)")
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.medium)
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
                    Text("\(appState.uniqueCollectedCount)/\(KeycapCatalog.all.count)")
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
