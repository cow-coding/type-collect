import SwiftUI

struct CollectionGrid: View {
    @ObservedObject var appState: AppState
    let filter: CollectionFilter
    @State private var selectedCollected: CollectedKeycap?

    private var filteredCollection: [CollectedKeycap] {
        switch filter {
        case .all:
            return appState.collection
        case .rarity(let rarity):
            return appState.collection.filter { $0.keycap.rarity == rarity }
        case .set(let setName):
            return appState.collection.filter { $0.keycap.setName == setName }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if filteredCollection.isEmpty {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "keyboard")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("No keycaps yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Keep typing to collect!")
                        .font(.caption)
                        .foregroundColor(.secondary.opacity(0.7))
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 100), spacing: 12)],
                        spacing: 12
                    ) {
                        ForEach(filteredCollection) { collected in
                            KeycapCardView(
                                keycap: collected.keycap,
                                isCollected: true,
                                count: collected.count
                            )
                            .onTapGesture {
                                selectedCollected = collected
                            }
                        }
                    }
                    .padding(16)
                }
            }

            // Stats bar
            HStack {
                Text("\(filteredCollection.count) keycaps")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(KeycapCatalog.totalCombinations) possible combinations")
                    .font(.caption)
                    .foregroundColor(.secondary.opacity(0.6))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.bar)
        }
        .sheet(item: $selectedCollected) { collected in
            KeycapDetailView(
                keycap: collected.keycap,
                collected: collected
            )
        }
    }
}
