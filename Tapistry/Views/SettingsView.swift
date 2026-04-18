import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = AppSettings.shared
    var village: VillageState? = nil

    private var lang: AppLanguage { settings.language }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(L10n.settingsTitle.resolve(lang))
                .font(.title2)
                .fontWeight(.bold)

            GroupBox(L10n.general.resolve(lang)) {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle(L10n.launchAtLogin.resolve(lang), isOn: $settings.launchAtLogin)
                    Toggle(L10n.showNotifications.resolve(lang), isOn: $settings.showDropNotifications)

                    HStack {
                        Text(L10n.language.resolve(lang))
                        Spacer()
                        Picker("", selection: $settings.language) {
                            ForEach(AppLanguage.allCases) { l in
                                Text(l.displayName).tag(l)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.segmented)
                        .frame(width: 180)
                    }
                }
                .padding(8)
            }

            GroupBox(L10n.about.resolve(lang)) {
                VStack(alignment: .leading, spacing: 8) {
                    infoRow(L10n.version.resolve(lang),
                            value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—")
                }
                .padding(8)
            }

            #if DEBUG
            if let village = village {
                DebugSection(village: village)
            }
            #endif

            Spacer()

            HStack {
                Spacer()
                Button(L10n.close.resolve(lang)) {
                    NSApp.keyWindow?.close()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(width: 420, height: 440)
    }


    private func infoRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

#if DEBUG
private struct DebugSection: View {
    @ObservedObject var village: VillageState

    var body: some View {
        GroupBox("Debug") {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Text("Level")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                    Spacer()
                    ForEach([1, 5, 10, 15, 20], id: \.self) { lv in
                        Button("Lv\(lv)") { village.setLevel(lv) }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                    }
                }

                HStack(spacing: 6) {
                    Text("XP")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                    Spacer()
                    Button("+10") { village.addXP(10) }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    Button("+100") { village.addXP(100) }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    Button("+1000") { village.addXP(1000) }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    Button("Unlock All") { village.unlockAll() }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                }

                HStack(spacing: 6) {
                    Text("Coins")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                    Spacer()
                    Button("+10") { village.addCash(10) }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    Button("+100") { village.addCash(100) }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    Button("+1000") { village.addCash(1000) }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    Button("Reset") { village.resetCash() }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                }

                HStack {
                    Text("Current")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Lv.\(village.level) · \(village.xp) XP · 💰\(village.cash)")
                        .font(.system(size: 11, design: .monospaced))
                }
            }
            .padding(8)
        }
    }
}
#endif
