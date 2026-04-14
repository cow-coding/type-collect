import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = AppSettings.shared

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
        .frame(width: 420, height: 360)
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
