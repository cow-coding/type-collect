import SwiftUI

struct MenuBarContentView: View {
    @ObservedObject var appState: AppState
    @ObservedObject var settings = AppSettings.shared

    @State private var isSettingsHovering = false
    @State private var isQuitHovering = false

    private var lang: AppLanguage { settings.language }

    var body: some View {
        VStack(spacing: 0) {
            headerBar

            if appState.isMonitoring {
                xpBar
            } else {
                permissionBanner
            }

            VillageGridView(village: appState.village)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)

            #if DEBUG
            debugControls
            #endif

            Spacer()
            footerSection
        }
        .frame(width: 280)
    }

    private var headerBar: some View {
        HStack(spacing: 8) {
            Image("MenuBarIcon")
                .resizable()
                .renderingMode(.template)
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
                .foregroundStyle(.blue)

            Text(L10n.appName.resolve(lang))
                .font(.system(size: 14, weight: .bold))
                .tracking(-0.3)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: 40)
        .background(.bar)
    }

    private var xpBar: some View {
        HStack(spacing: 8) {
            Text("Lv.\(appState.village.level)")
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .foregroundColor(.orange)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.1))
                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            LinearGradient(
                                colors: [.orange, .yellow],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * appState.village.levelProgress)
                }
            }
            .frame(height: 6)

            if let nextXP = appState.village.xpForNextLevel {
                Text("\(appState.village.xp)/\(nextXP)")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
            } else {
                Text(L10n.max.resolve(lang))
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.orange)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private var permissionBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14))
                .foregroundStyle(.orange)

            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.permissionTitle.resolve(lang))
                    .font(.system(size: 11, weight: .semibold))
                Text(L10n.permissionDetail.resolve(lang))
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(L10n.permissionOpen.resolve(lang)) {
                appState.permissionManager.openInputMonitoringSettings()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Rectangle().fill(Color.orange.opacity(0.08)))
        .overlay(
            Rectangle()
                .fill(Color.orange.opacity(0.3))
                .frame(height: 0.5),
            alignment: .bottom
        )
    }

    #if DEBUG
    private var debugControls: some View {
        VStack(spacing: 4) {
            Divider().padding(.horizontal, 12)
            Text("DEBUG")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.red.opacity(0.6))

            HStack(spacing: 4) {
                Button("Lv1") { appState.village.setLevel(1) }
                Button("Lv5") { appState.village.setLevel(5) }
                Button("Lv10") { appState.village.setLevel(10) }
                Button("Lv20") { appState.village.setLevel(20) }
                Button("+100XP") { appState.village.addXP(100) }
            }
            .font(.system(size: 9))
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
    #endif

    private var footerSection: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(.quaternary)
                .frame(height: 1)

            VStack(spacing: 4) {
                Button {
                    NotificationCenter.default.post(name: .openSettings, object: nil)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 14))
                            .foregroundStyle(isSettingsHovering ? .primary : .secondary)
                        Text(L10n.settings.resolve(lang))
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

                Button {
                    NSApplication.shared.terminate(nil)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "power")
                            .font(.system(size: 14))
                            .foregroundStyle(isQuitHovering ? .red : .secondary)
                        Text(L10n.quit.resolve(lang))
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
