import SwiftUI

struct CollectionSidebar: View {
    @ObservedObject var appState: AppState
    @Binding var selectedFilter: CollectionFilter
    var overrideCollection: [CollectedKeycap]?

    private var collection: [CollectedKeycap] {
        overrideCollection ?? appState.collection
    }

    // Design tokens
    private let surfaceContainerHigh = DesignTokens.surfaceContainerHigh
    private let outline = DesignTokens.outline
    private let onSurface = DesignTokens.onSurface
    private let primaryColor = DesignTokens.primary

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // App title with icon
            HStack(spacing: 8) {
                Image("MenuBarIcon")
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .foregroundColor(primaryColor)
                Text("TypeVillage")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(onSurface)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 20)
            .padding(.bottom, 16)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Vault section
                    sectionHeader("VAULT")
                    VStack(spacing: 2) {
                        navRow(
                            icon: "square.grid.2x2",
                            label: "Vault",
                            filter: .all,
                            count: collection.count
                        )
                    }

                    // Rarity section
                    sectionHeader("RARITY")
                    VStack(spacing: 2) {
                        ForEach(Rarity.allCases, id: \.self) { rarity in
                            let count = collection.filter { $0.keycap.rarity == rarity }.count
                            rarityRow(rarity: rarity, count: count)
                        }
                    }

                    // Sets section
                    sectionHeader("SETS")
                    VStack(spacing: 2) {
                        ForEach(setNames, id: \.self) { setName in
                            let count = collection.filter { $0.keycap.setName == setName }.count
                            setRow(name: setName, count: count)
                        }
                    }
                }
                .padding(.horizontal, 12)
            }

            Spacer()
        }
        .background(.ultraThinMaterial)
        .listStyle(.sidebar)
    }

    private var setNames: [String] {
        KeycapCatalog.sets.map { $0.name }
    }

    // MARK: - Section Header

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 10, weight: .bold))
            .tracking(2)
            .foregroundColor(outline)
            .padding(.horizontal, 12)
            .padding(.top, 4)
    }

    // MARK: - Nav Row (Vault/Marketplace)

    private func navRow(icon: String, label: String, filter: CollectionFilter, count: Int) -> some View {
        let isSelected = selectedFilter == filter
        return Button {
            selectedFilter = filter
        } label: {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
                Spacer()
                Text("\(count)")
                    .font(.system(size: 11))
                    .foregroundColor(outline)
            }
            .foregroundColor(isSelected ? primaryColor : outline)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? surfaceContainerHigh.opacity(0.5) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Rarity Row

    private func rarityRow(rarity: Rarity, count: Int) -> some View {
        let filter = CollectionFilter.rarity(rarity)
        let isSelected = selectedFilter == filter
        return Button {
            selectedFilter = filter
        } label: {
            HStack(spacing: 10) {
                // Glow dot
                Circle()
                    .fill(rarity.color)
                    .frame(width: 6, height: 6)
                    .shadow(color: rarity.color.opacity(0.8), radius: 4, x: 0, y: 0)

                Text(rarity.displayName)
                    .font(.system(size: 13))

                Spacer()

                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 11))
                        .foregroundColor(outline)
                }
            }
            .foregroundColor(isSelected ? onSurface : outline)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .contentShape(Rectangle())
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? surfaceContainerHigh.opacity(0.5) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Set Row

    private func setRow(name: String, count: Int) -> some View {
        let filter = CollectionFilter.set(name)
        let isSelected = selectedFilter == filter
        return Button {
            selectedFilter = filter
        } label: {
            HStack(spacing: 10) {
                Text(name)
                    .font(.system(size: 13))
                    .lineLimit(1)
                Spacer()
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 11))
                        .foregroundColor(outline)
                }
            }
            .foregroundColor(isSelected ? onSurface : outline)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .contentShape(Rectangle())
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? surfaceContainerHigh.opacity(0.5) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}
