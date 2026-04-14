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

    var subtitle: String {
        switch self {
        case .standard: return "ROW 01-04"
        case .modifier: return "SYSTEM CONTROLS"
        case .wide: return "EXTENDED WIDTH"
        case .space: return "FOUNDATIONAL"
        }
    }
}

struct CollectionGrid: View {
    @ObservedObject var appState: AppState
    let filter: CollectionFilter
    var overrideCollection: [CollectedKeycap]?
    @State private var selectedCollected: CollectedKeycap?

    // Design tokens
    private let onSurface = Color(red: 0.886, green: 0.898, blue: 0.937)
    private let outline = Color(red: 0.447, green: 0.459, blue: 0.494)
    private let primaryColor = Color(red: 0.757, green: 0.502, blue: 1.0)
    private let surface = Color(red: 0.047, green: 0.055, blue: 0.071)
    private let surfaceContainer = Color(red: 0.09, green: 0.102, blue: 0.122)

    private var collection: [CollectedKeycap] {
        overrideCollection ?? appState.collection
    }

    private var filteredCollection: [CollectedKeycap] {
        switch filter {
        case .all:
            return collection
        case .rarity(let rarity):
            return collection.filter { $0.keycap.rarity == rarity }
        case .set(let setName):
            return collection.filter { $0.keycap.setName == setName }
        }
    }

    private func keycaps(for category: KeySizeCategory) -> [CollectedKeycap] {
        filteredCollection.filter { KeySizeCategory.from(widthUnit: $0.keycap.widthUnit) == category }
    }

    private var collectionProgress: Double {
        guard KeycapCatalog.totalCombinations > 0 else { return 0 }
        return Double(filteredCollection.count) / Double(KeycapCatalog.totalCombinations)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("The Collection")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(onSurface)

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 8)

            if filteredCollection.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "keyboard")
                        .font(.system(size: 44))
                        .foregroundColor(outline.opacity(0.4))
                    Text("No keycaps yet")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(outline)
                    Text("Keep typing to collect!")
                        .font(.system(size: 13))
                        .foregroundColor(outline.opacity(0.6))
                }
                Spacer()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        ForEach(KeySizeCategory.allCases, id: \.self) { category in
                            let items = keycaps(for: category)
                            if !items.isEmpty {
                                sectionView(title: category.rawValue, subtitle: category.subtitle, items: items, category: category)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 80)
                }
            }

            // Stats bar
            statsBar
        }
        .background(surface)
        .overlay {
            if let collected = selectedCollected {
                // Dimmed backdrop — tap to dismiss
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        selectedCollected = nil
                    }

                KeycapDetailView(
                    keycap: collected.keycap,
                    collected: collected,
                    onDismiss: { selectedCollected = nil }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                .shadow(color: .black.opacity(0.5), radius: 40, x: 0, y: 10)
            }
        }
        .animation(.easeOut(duration: 0.2), value: selectedCollected != nil)
    }

    // MARK: - Section View

    private func sectionView(title: String, subtitle: String, items: [CollectedKeycap], category: KeySizeCategory) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack(alignment: .lastTextBaseline, spacing: 10) {
                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(onSurface)

                Text(subtitle)
                    .font(.system(size: 10, weight: .bold))
                    .tracking(2)
                    .foregroundColor(outline)
            }

            LazyVGrid(
                columns: gridColumns(for: category),
                spacing: 14
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

    // MARK: - Stats Bar

    private var statsBar: some View {
        HStack(spacing: 16) {
            // Collection count
            Text("\(filteredCollection.count) KEYCAPS COLLECTED")
                .font(.system(size: 10, weight: .bold))
                .tracking(2)
                .foregroundColor(outline)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(surfaceContainer)
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(primaryColor)
                        .frame(width: geo.size.width * collectionProgress, height: 4)
                        .shadow(color: primaryColor.opacity(0.6), radius: 4, x: 0, y: 0)
                }
            }
            .frame(width: 80, height: 4)

            Spacer()

            Text("\(KeycapCatalog.totalCombinations) POSSIBLE COMBINATIONS")
                .font(.system(size: 10, weight: .bold))
                .tracking(2)
                .foregroundColor(outline)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 10)
        .background(
            Color.black.opacity(0.6)
                .background(.ultraThinMaterial)
        )
        .overlay(
            Rectangle()
                .fill(outline.opacity(0.1))
                .frame(height: 0.5),
            alignment: .top
        )
    }

    // MARK: - Grid Columns

    private func gridColumns(for category: KeySizeCategory) -> [GridItem] {
        switch category {
        case .standard:
            return [GridItem(.adaptive(minimum: 120), spacing: 14)]
        case .modifier:
            return [GridItem(.adaptive(minimum: 140), spacing: 14)]
        case .wide:
            return [GridItem(.adaptive(minimum: 160), spacing: 14)]
        case .space:
            return [GridItem(.adaptive(minimum: 220), spacing: 14)]
        }
    }
}
