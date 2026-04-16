import SwiftUI

/// Zoomed tile editor — a popover that shows a single tile at ~3× size with its 2×2
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
    @State private var selectedSub: (Int, Int)? = (1, 1)
    @State private var layer: TileLayer = .object
    @State private var coinsSpent: Int = 0  // track for cancel-refund

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
                    let canAfford = village.cash >= g.price
                    Button {
                        if village.spendCash(g.price) {
                            coinsSpent += g.price
                            village.placeGround(g, row: row, col: col)
                        }
                    } label: {
                        VStack(spacing: 1) {
                            BuildingPixelView(building: g, size: 26)
                                .clipShape(IsometricDiamond())
                                .frame(width: 26, height: 14)
                                .opacity(canAfford ? 1.0 : 0.4)
                            Text(g.name.resolve(lang))
                                .font(.system(size: 7))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                            Text("\(g.price)💰")
                                .font(.system(size: 7, weight: .medium))
                                .foregroundColor(canAfford ? .yellow : .secondary)
                        }
                        .frame(width: 44, height: 42)
                        .background(groundButtonBg(isSelected: currentGround == g.id))
                    }
                    .buttonStyle(.plain)
                    .disabled(!canAfford)
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
            .background(
                // Tap outside the diamond to deselect sub-cell
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { selectedSub = nil }
            )
            Spacer()
        }
    }

    // MARK: - Sub-cell caption + layer tabs

    private var subCellCaption: some View {
        guard let sel = selectedSub else {
            return AnyView(
                Text(L10n.tapSubCell.resolve(lang))
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            )
        }

        let currentId = currentSubCellId()
        let label: String = {
            if let id = currentId, let b = BuildingCatalog.find(id) {
                return b.name.resolve(lang)
            }
            return L10n.tapSubCell.resolve(lang)
        }()

        return AnyView(HStack(spacing: 6) {
            Text("\(L10n.subCellLabel.resolve(lang)) (\(sel.0 + 1), \(sel.1 + 1))")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.secondary)
            Text("—")
                .foregroundColor(.secondary)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.primary)
        })
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
            if selectedSub == nil {
                Text(L10n.tapSubCell.resolve(lang))
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            } else if unlocked.isEmpty {
                Text(L10n.noUnlocked.resolve(lang))
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            } else if let sel = selectedSub {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 50), spacing: 6)], spacing: 6) {
                    if let cid = currentId, let building = BuildingCatalog.find(cid) {
                        let refund = building.price / 2
                        Button {
                            village.addCash(refund)
                            village.removeSubCell(
                                row: row, col: col,
                                subRow: sel.0, subCol: sel.1,
                                layer: layer
                            )
                        } label: {
                            paletteCell(content: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16))
                                    .foregroundColor(.red.opacity(0.75))
                            }, label: "+\(refund)💰", isSelected: false, isRemove: true)
                        }
                        .buttonStyle(.plain)
                    }

                    ForEach(unlocked) { b in
                        let canAfford = village.cash >= b.price
                        Button {
                            if village.spendCash(b.price) {
                                coinsSpent += b.price
                                village.placeSubCell(
                                    b,
                                    row: row, col: col,
                                    subRow: sel.0, subCol: sel.1,
                                    layer: layer
                                )
                            }
                        } label: {
                            paletteCell(content: {
                                BuildingPixelView(building: b, size: 28)
                                    .frame(width: 28, height: 28)
                                    .opacity(canAfford ? 1.0 : 0.4)
                            }, label: b.name.resolve(lang), price: b.price, canAfford: canAfford, isSelected: currentId == b.id, isRemove: false)
                        }
                        .buttonStyle(.plain)
                        .disabled(!canAfford)
                    }
                }
            }
        }
    }

    private func paletteCell<Content: View>(
        @ViewBuilder content: () -> Content,
        label: String,
        price: Int = 0,
        canAfford: Bool = true,
        isSelected: Bool,
        isRemove: Bool
    ) -> some View {
        VStack(spacing: 1) {
            content()
                .frame(height: 24)
            Text(label)
                .font(.system(size: 8))
                .foregroundColor(.secondary)
                .lineLimit(1)
            if !isRemove {
                Text("\(price)💰")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(canAfford ? .yellow : .secondary)
            }
        }
        .frame(width: 46, height: 52)
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
        // Refund coins spent during this editor session
        if coinsSpent > 0 {
            village.addCash(coinsSpent)
        }
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
        guard let sel = selectedSub else { return nil }
        let cell = tile.subCells[sel.0][sel.1]
        switch layer {
        case .ground: return nil  // ground is tile-wide
        case .object: return cell.object
        case .decoration: return cell.decoration
        }
    }
}
