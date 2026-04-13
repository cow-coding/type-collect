import SwiftUI

enum CollectionFilter: Hashable {
    case all
    case rarity(Rarity)
    case set(String)
}

struct CollectionView: View {
    @ObservedObject var appState: AppState
    @State private var selectedFilter: CollectionFilter = .all

    var body: some View {
        NavigationSplitView {
            CollectionSidebar(
                appState: appState,
                selectedFilter: $selectedFilter
            )
            .navigationSplitViewColumnWidth(min: 160, ideal: 180, max: 220)
        } detail: {
            CollectionGrid(
                appState: appState,
                filter: selectedFilter
            )
        }
    }
}
