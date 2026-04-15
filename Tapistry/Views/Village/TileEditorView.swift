import SwiftUI

/// Zoomed tile editor — a popover that shows a single tile at ~3× size with its 3×3
/// sub-cell grid. The user picks a ground (whole-tile layer), then taps a sub-cell and
/// places an object or decoration into that specific cell.
///
/// `Cancel` reverts the tile to the snapshot taken at open time; `Done` / ✕ / outside
/// click keep the edits.
struct TileEditorView: View {
    @ObservedObject var village: VillageState
    @ObservedObject var settings = AppSettings.shared
    let row: Int
    let col: Int
    let onClose: () -> Void

    /// Snapshot of the tile taken on appear so Cancel can restore it.
    @State private var snapshot: VillageTile? = nil
    @State private var selectedSub: (Int, Int) = (1, 1)
    @State private var layer: TileLayer = .object

    private var lang: AppLanguage { settings.language }

    /// Enlarged block size for the editor preview. Matches the popover width roughly.
    private let editorBlockSize: CGFloat = 200

    private var tile: VillageTile { village.grid[row][col] }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            header
            groundRow
            Divider()
            previewArea
            Divider()
            subCellCaption
            layerTabs
            palette
            Spacer(minLength: 4)
            footerButtons
        }
        .padding(14)
        .frame(width: 320)
        .onAppear {
            if snapshot == nil {
                snapshot = village.grid[row][col]
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text(L10n.tileLabel(row: row + 1, col: col + 1, lang: lang))
                .font(.system(size: 13, weight: .bold))
            Spacer()
            Button(action: closeKeep) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.cancelAction)
        }
    }

    // MARK: - Ground row (whole-tile layer)

    private var groundRow: some View {
        let unlockedGrounds = village.unlockedBuildings.filter { $0.layer == .ground }
        let currentGround = tile.ground

        return VStack(alignment: .leading, spacing: 4) {
            Text(L10n.layerGround.resolve(lang))
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.secondary)

            HStack(spacing: 6) {
                // None (clear ground)
                Button {
                    village.placeGround(nil, row: row, col: col)
                } label: {
                    VStack(spacing: 1) {
                        Image(systemName: "circle.slash")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        Text(L10n.noneLabel.resolve(lang))
                            .font(.system(size: 8))
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 44, height: 38)
                    .background(groundButtonBg(isSelected: currentGround == nil))
                }
                .buttonStyle(.plain)

                ForEach(unlockedGrounds) { g in
                    Button {
                        village.placeGround(g, row: row, col: col)
                    } label: {
                        VStack(spacing: 1) {
                            BuildingPixelView(building: g, size: 26)
                                .clipShape(IsometricDiamond())
                                .frame(width: 26, height: 14)
                            Text(g.name.resolve(lang))
                                .font(.system(size: 8))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        .frame(width: 44, height: 38)
                        .background(groundButtonBg(isSelected: currentGround == g.id))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func groundButtonBg(isSelected: Bool) -> some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(isSelected ? Color.orange.opacity(0.22) : Color.white.opacity(0.04))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(isSelected ? Color.orange : .clear, lineWidth: 1)
            )
    }

    // MARK: - Zoomed preview

    private var previewArea: some View {
        HStack {
            Spacer()
            VillageTileView(
                tile: tile,
                blockSize: editorBlockSize,
                isSelected: false,
                selectedSubCell: selectedSub,
                onSubCellTap: { sr, sc in selectedSub = (sr, sc) }
            )
            .frame(
                width: editorBlockSize,
                height: editorBlockSize * 0.75 + 8
            )
            Spacer()
        }
    }

    // MARK: - Sub-cell caption + layer tabs

    private var subCellCaption: some View {
        let currentId = currentSubCellId()
        let label: String = {
            if let id = currentId, let b = BuildingCatalog.find(id) {
                return b.name.resolve(lang)
            }
            return L10n.tapSubCell.resolve(lang)
        }()

        return HStack(spacing: 6) {
            Text("\(L10n.subCellLabel.resolve(lang)) (\(selectedSub.0 + 1), \(selectedSub.1 + 1))")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.secondary)
            Text("—")
                .foregroundColor(.secondary)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.primary)
        }
    }

    private var layerTabs: some View {
        HStack(spacing: 4) {
            ForEach([TileLayer.object, TileLayer.decoration], id: \.self) { l in
                Button { layer = l } label: {
                    Text(layerLabel(l))
                        .font(.system(size: 10, weight: .semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(layer == l ? Color.orange.opacity(0.25) : Color.white.opacity(0.05))
                        )
                        .foregroundColor(layer == l ? .orange : .secondary)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Palette (object or decoration)

    private var palette: some View {
        let unlocked = village.unlockedBuildings.filter { $0.layer == layer }
        let currentId = currentSubCellId()

        return Group {
            if unlocked.isEmpty {
                Text(L10n.noUnlocked.resolve(lang))
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 50), spacing: 6)], spacing: 6) {
                    if currentId != nil {
                        Button {
                            village.removeSubCell(
                                row: row, col: col,
                                subRow: selectedSub.0, subCol: selectedSub.1,
                                layer: layer
                            )
                        } label: {
                            paletteCell(content: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16))
                                    .foregroundColor(.red.opacity(0.75))
                            }, label: L10n.remove.resolve(lang), isSelected: false, isRemove: true)
                        }
                        .buttonStyle(.plain)
                    }

                    ForEach(unlocked) { b in
                        Button {
                            village.placeSubCell(
                                b,
                                row: row, col: col,
                                subRow: selectedSub.0, subCol: selectedSub.1,
                                layer: layer
                            )
                        } label: {
                            paletteCell(content: {
                                BuildingPixelView(building: b, size: 28)
                                    .frame(width: 28, height: 28)
                            }, label: b.name.resolve(lang), isSelected: currentId == b.id, isRemove: false)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func paletteCell<Content: View>(
        @ViewBuilder content: () -> Content,
        label: String,
        isSelected: Bool,
        isRemove: Bool
    ) -> some View {
        VStack(spacing: 2) {
            content()
                .frame(height: 28)
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .frame(width: 46, height: 48)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    isRemove ? Color.red.opacity(0.05)
                    : (isSelected ? Color.orange.opacity(0.2) : Color.white.opacity(0.05))
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(isSelected ? Color.orange : .clear, lineWidth: 1)
        )
    }

    // MARK: - Footer

    private var footerButtons: some View {
        HStack {
            Button(L10n.cancel.resolve(lang), action: cancel)
                .buttonStyle(.bordered)
                .keyboardShortcut(.cancelAction)

            Spacer()

            Button(L10n.done.resolve(lang), action: closeKeep)
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
        }
    }

    // MARK: - Actions

    private func closeKeep() { onClose() }

    private func cancel() {
        if let snap = snapshot {
            village.replaceTile(snap, row: row, col: col)
        }
        onClose()
    }

    // MARK: - Helpers

    private func layerLabel(_ layer: TileLayer) -> String {
        switch layer {
        case .ground: return L10n.layerGround.resolve(lang)
        case .object: return L10n.layerObject.resolve(lang)
        case .decoration: return L10n.layerDecoration.resolve(lang)
        }
    }

    private func currentSubCellId() -> String? {
        let cell = tile.subCells[selectedSub.0][selectedSub.1]
        switch layer {
        case .ground: return nil  // ground is tile-wide
        case .object: return cell.object
        case .decoration: return cell.decoration
        }
    }
}
