import SwiftUI

enum KeySizeCategory: String, CaseIterable {
    case standard = "Standard Keys"
    case modifier = "Modifier Keys"
    case wide = "Wide Keys"
    case space = "Space Bar"

    static func from(widthUnit: CGFloat) -> KeySizeCategory {
        if widthUnit >= 5.0 { return .space }
        if widthUnit >= 2.0 { return .wide }
        if widthUnit > 1.0 { return .modifier }
        return .standard
    }
}

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

    private func keycaps(for category: KeySizeCategory) -> [CollectedKeycap] {
        filteredCollection.filter { KeySizeCategory.from(widthUnit: $0.keycap.widthUnit) == category }
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
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(KeySizeCategory.allCases, id: \.self) { category in
                            let items = keycaps(for: category)
                            if !items.isEmpty {
                                sectionView(title: category.rawValue, items: items, category: category)
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

    private func sectionView(title: String, items: [CollectedKeycap], category: KeySizeCategory) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                Text("(\(items.count))")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary.opacity(0.6))
                Spacer()
            }

            LazyVGrid(
                columns: gridColumns(for: category),
                spacing: 12
            ) {
                ForEach(items) { collected in
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
        }
    }

    private func gridColumns(for category: KeySizeCategory) -> [GridItem] {
        switch category {
        case .standard:
            return [GridItem(.adaptive(minimum: 90), spacing: 10)]
        case .modifier:
            return [GridItem(.adaptive(minimum: 110), spacing: 10)]
        case .wide:
            return [GridItem(.adaptive(minimum: 140), spacing: 10)]
        case .space:
            return [GridItem(.adaptive(minimum: 200), spacing: 10)]
        }
    }
}
