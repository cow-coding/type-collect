import SwiftUI

enum CollectionFilter: Hashable {
    case all
    case rarity(Rarity)
    case set(String)
}

struct CollectionView: View {
    @ObservedObject var appState: AppState
    @State private var selectedFilter: CollectionFilter = .all

    #if DEBUG
    @State private var debugCollection = AppState.makeTestCollection()
    #endif

    var body: some View {
        NavigationSplitView {
            CollectionSidebar(
                appState: appState,
                selectedFilter: $selectedFilter,
                overrideCollection: activeCollection
            )
            .navigationSplitViewColumnWidth(min: 170, ideal: 180, max: 200)
        } detail: {
            CollectionGrid(
                appState: appState,
                filter: selectedFilter,
                overrideCollection: activeCollection
            )
        }
    }

    private var activeCollection: [CollectedKeycap]? {
        #if DEBUG
        return debugCollection
        #else
        return nil
        #endif
    }
}
