import SwiftUI

struct CollectionSidebar: View {
    @ObservedObject var appState: AppState
    @Binding var selectedFilter: CollectionFilter

    var body: some View {
        List(selection: $selectedFilter) {
            Section("Collection") {
                sidebarRow(
                    label: "All",
                    count: appState.collection.count,
                    filter: .all
                )
            }

            Section("Rarity") {
                ForEach(Rarity.allCases, id: \.self) { rarity in
                    let count = appState.collection.filter { $0.keycap.rarity == rarity }.count
                    sidebarRow(
                        label: rarity.displayName,
                        count: count,
                        filter: .rarity(rarity),
                        color: rarity.color
                    )
                }
            }

            Section("Sets") {
                ForEach(setNames, id: \.self) { setName in
                    let count = appState.collection.filter { $0.keycap.setName == setName }.count
                    sidebarRow(
                        label: setName,
                        count: count,
                        filter: .set(setName)
                    )
                }
            }
        }
        .listStyle(.sidebar)
    }

    private var setNames: [String] {
        KeycapCatalog.sets.map { $0.name }
    }

    private func sidebarRow(
        label: String,
        count: Int,
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
            Text("\(count)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .tag(filter)
    }
}
