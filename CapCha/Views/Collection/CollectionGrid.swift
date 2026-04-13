import SwiftUI

struct CollectionGrid: View {
    @ObservedObject var appState: AppState
    let filter: CollectionFilter
    @State private var selectedKeycap: Keycap?

    private var filteredKeycaps: [Keycap] {
        switch filter {
        case .all:
            return KeycapCatalog.all
        case .rarity(let rarity):
            return KeycapCatalog.keycaps(for: rarity)
        case .set(let setName):
            return KeycapCatalog.all.filter { $0.setName == setName }
        }
    }

    private var progressText: String {
        let keycaps = filteredKeycaps
        let collected = keycaps.filter { appState.isCollected($0) }.count
        return "\(collected) / \(keycaps.count)"
    }

    private var progressValue: Double {
        let keycaps = filteredKeycaps
        guard !keycaps.isEmpty else { return 0 }
        let collected = keycaps.filter { appState.isCollected($0) }.count
        return Double(collected) / Double(keycaps.count)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 100), spacing: 12)],
                    spacing: 12
                ) {
                    ForEach(filteredKeycaps) { keycap in
                        KeycapCardView(
                            keycap: keycap,
                            isCollected: appState.isCollected(keycap)
                        )
                        .onTapGesture {
                            selectedKeycap = keycap
                        }
                    }
                }
                .padding(16)
            }

            // Progress bar
            VStack(spacing: 4) {
                ProgressView(value: progressValue)
                    .tint(.accentColor)
                Text(progressText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.bar)
        }
        .sheet(item: $selectedKeycap) { keycap in
            KeycapDetailView(
                keycap: keycap,
                collected: appState.collectedInstance(of: keycap)
            )
        }
    }
}
