import SwiftUI

struct BuildingPickerView: View {
    @ObservedObject var village: VillageState
    @ObservedObject var settings = AppSettings.shared
    let row: Int
    let col: Int
    let onClose: () -> Void

    @State private var selectedLayer: TileLayer = .object

    private var lang: AppLanguage { settings.language }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(L10n.tileLabel(row: row + 1, col: col + 1, lang: lang))
                    .font(.system(size: 12, weight: .bold))
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 4) {
                ForEach(TileLayer.allCases, id: \.self) { layer in
                    Button {
                        selectedLayer = layer
                    } label: {
                        Text(layerLabel(layer))
                            .font(.system(size: 10, weight: .semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(selectedLayer == layer ? Color.orange.opacity(0.25) : Color.white.opacity(0.05))
                            )
                            .foregroundColor(selectedLayer == layer ? .orange : .secondary)
                    }
                    .buttonStyle(.plain)
                }
            }

            Divider()

            let unlocked = village.unlockedBuildings.filter { $0.layer == selectedLayer }
            let currentId = currentPlacedId()

            if unlocked.isEmpty {
                Text(L10n.noUnlocked.resolve(lang))
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 54), spacing: 6)], spacing: 6) {
                    if currentId != nil {
                        Button {
                            village.remove(row: row, col: col, layer: selectedLayer)
                        } label: {
                            VStack(spacing: 2) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 18))
                                    .foregroundColor(.red.opacity(0.7))
                                Text(L10n.remove.resolve(lang))
                                    .font(.system(size: 9))
                                    .foregroundColor(.secondary)
                            }
                            .frame(width: 50, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.red.opacity(0.05))
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    ForEach(unlocked) { b in
                        Button {
                            village.place(b, row: row, col: col, layer: selectedLayer)
                        } label: {
                            VStack(spacing: 2) {
                                Text(b.emoji)
                                    .font(.system(size: 22))
                                Text(b.name.resolve(lang))
                                    .font(.system(size: 9))
                                    .foregroundColor(.secondary)
                            }
                            .frame(width: 50, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(currentId == b.id ? Color.orange.opacity(0.2) : Color.white.opacity(0.05))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .strokeBorder(currentId == b.id ? Color.orange : .clear, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            let locked = BuildingCatalog.forLayer(selectedLayer).filter { $0.unlockLevel > village.level }
            if !locked.isEmpty {
                Divider().padding(.top, 4)
                Text(L10n.upcomingUnlocks.resolve(lang))
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.secondary)
                HStack(spacing: 4) {
                    ForEach(locked) { b in
                        VStack(spacing: 2) {
                            Text(b.emoji)
                                .font(.system(size: 16))
                                .opacity(0.3)
                            Text("Lv.\(b.unlockLevel)")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.secondary)
                        }
                        .frame(width: 40, height: 40)
                    }
                }
            }
        }
        .padding(12)
        .frame(width: 240)
    }

    private func layerLabel(_ layer: TileLayer) -> String {
        switch layer {
        case .ground: return L10n.layerGround.resolve(lang)
        case .object: return L10n.layerObject.resolve(lang)
        case .decoration: return L10n.layerDecoration.resolve(lang)
        }
    }

    private func currentPlacedId() -> String? {
        let tile = village.grid[row][col]
        switch selectedLayer {
        case .ground: return tile.ground
        case .object: return tile.object
        case .decoration: return tile.decoration
        }
    }
}
