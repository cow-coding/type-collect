import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = AppSettings.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Settings")
                .font(.title2)
                .fontWeight(.bold)

            // General
            GroupBox("General") {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Launch at login", isOn: $settings.launchAtLogin)
                    Toggle("Show drop notifications", isOn: $settings.showDropNotifications)
                }
                .padding(8)
            }

            // Info
            GroupBox("About") {
                VStack(alignment: .leading, spacing: 8) {
                    infoRow("Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—")
                    infoRow("Keycap combinations", value: "\(KeycapCatalog.totalCombinations)")
                    infoRow("Keys", value: "\(KeycapCatalog.keys.count)")
                    infoRow("Sets", value: "\(KeycapCatalog.sets.count)")
                }
                .padding(8)
            }

            Spacer()

            HStack {
                Spacer()
                Button("Close") {
                    NSApp.keyWindow?.close()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(width: 400, height: 400)
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
