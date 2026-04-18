import SwiftUI

struct MenuBarContentView: View {
    @ObservedObject var appState: AppState
    @ObservedObject var settings = AppSettings.shared
    /// Observe village directly so cashBar/xpBar re-render immediately
    /// when cash or xp changes (appState doesn't re-publish nested changes).
    @ObservedObject var village: VillageState

    @State private var isSettingsHovering = false
    @State private var isQuitHovering = false
    @State private var showSellAllAlert = false

    private var lang: AppLanguage { settings.language }

    var body: some View {
        VStack(spacing: 0) {
            headerBar

            if appState.isMonitoring {
                xpBar
                cashBar
            } else {
                permissionBanner
            }

            VillageGridView(village: village)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .offset(y: -10)

            Spacer()
            footerSection
        }
        .frame(width: 320)
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
            Text("Lv.\(village.level)")
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
                        .frame(width: geo.size.width * village.levelProgress)
                }
            }
            .frame(height: 6)

            if let nextXP = village.xpForNextLevel {
                Text("\(village.xp)/\(nextXP)")
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

    private var cashBar: some View {
        HStack(spacing: 6) {
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 11))
                .foregroundColor(.yellow)
            Text("\(village.cash)")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.yellow)
                .contentTransition(.numericText())
                .animation(.spring(duration: 0.3), value: village.cash)
            Text(L10n.coins.resolve(lang))
                .font(.system(size: 9))
                .foregroundColor(.secondary)
            Spacer()
            Image(systemName: "keyboard")
                .font(.system(size: 9))
                .foregroundColor(.secondary)
            Text("\(appState.todayKeystrokeCount) \(L10n.todayLabel.resolve(lang))")
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary)

            if potentialRefund > 0 {
                Button {
                    showSellAllAlert = true
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "trash")
                            .font(.system(size: 9))
                        Text("+\(potentialRefund)💰")
                            .font(.system(size: 9, weight: .semibold, design: .rounded))
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.red.opacity(0.15))
                    )
                    .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                .alert("마을 전체 판매", isPresented: $showSellAllAlert) {
                    Button("취소", role: .cancel) {}
                    Button("판매", role: .destructive) {
                        village.sellAll()
                    }
                } message: {
                    Text("설치한 모든 건물·지면을 제거하고 50% 환불받습니다 (+\(potentialRefund)💰).")
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 6)
    }

    /// Sum of 50% refunds for every placed element. Shown next to the
    /// sell-all button so the user sees the reward before committing.
    private var potentialRefund: Int {
        var total = 0
        for r in 0..<village.gridSize {
            for c in 0..<village.gridSize {
                let tile = village.grid[r][c]
                if let gid = tile.ground, let b = BuildingCatalog.find(gid) {
                    total += b.price / 2
                }
                for sr in 0..<VillageTile.subGridSize {
                    for sc in 0..<VillageTile.subGridSize {
                        let cell = tile.subCells[sr][sc]
                        if let oid = cell.object, let b = BuildingCatalog.find(oid) {
                            total += b.price / 2
                        }
                        if let did = cell.decoration, let b = BuildingCatalog.find(did) {
                            total += b.price / 2
                        }
                    }
                }
            }
        }
        return total
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
