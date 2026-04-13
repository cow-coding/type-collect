import SwiftUI

struct CollectionSidebar: View {
    @ObservedObject var appState: AppState
    @Binding var selectedFilter: CollectionFilter

    private var collectedIDs: Set<String> {
        appState.collectedKeycapIDs
    }

    var body: some View {
        List(selection: $selectedFilter) {
            Section("Collection") {
                sidebarRow(
                    label: "All",
                    count: appState.uniqueCollectedCount,
                    total: KeycapCatalog.all.count,
                    filter: .all
                )
            }

            Section("Rarity") {
                ForEach(Rarity.allCases, id: \.self) { rarity in
                    let keycaps = KeycapCatalog.keycaps(for: rarity)
                    let collected = keycaps.filter { collectedIDs.contains($0.id) }.count
                    sidebarRow(
                        label: rarity.displayName,
                        count: collected,
                        total: keycaps.count,
                        filter: .rarity(rarity),
                        color: rarity.color
                    )
                }
            }

            Section("Sets") {
                ForEach(setNames, id: \.self) { setName in
                    let keycaps = KeycapCatalog.all.filter { $0.setName == setName }
                    let collected = keycaps.filter { collectedIDs.contains($0.id) }.count
                    sidebarRow(
                        label: setName,
                        count: collected,
                        total: keycaps.count,
                        filter: .set(setName)
                    )
                }
            }
        }
        .listStyle(.sidebar)
    }

    private var setNames: [String] {
        var seen = Set<String>()
        return KeycapCatalog.all.compactMap { keycap in
            if seen.contains(keycap.setName) { return nil }
            seen.insert(keycap.setName)
            return keycap.setName
        }
    }

    private func sidebarRow(
        label: String,
        count: Int,
        total: Int,
        filter: CollectionFilter,
        color: Color? = nil
    ) -> some View {
        HStack {
            if let color = color {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
            }
            Text(label)
                .lineLimit(1)
            Spacer()
            Text("\(count)/\(total)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .tag(filter)
    }
}
