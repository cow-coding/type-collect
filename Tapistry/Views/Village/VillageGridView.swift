import SwiftUI

/// Isometric (quarter-view) Minecraft-style grass block
struct GrassBlockView: View {
    let size: CGFloat

    private var halfW: CGFloat { size / 2 }
    private var quarterH: CGFloat { size / 4 }

    var body: some View {
        Canvas { context, canvasSize in
            let cx = canvasSize.width / 2
            let midY = quarterH
            let botY = quarterH * 3

            // Top face
            var topFace = Path()
            topFace.move(to: CGPoint(x: cx, y: 0))
            topFace.addLine(to: CGPoint(x: cx + halfW, y: midY))
            topFace.addLine(to: CGPoint(x: cx, y: midY * 2))
            topFace.addLine(to: CGPoint(x: cx - halfW, y: midY))
            topFace.closeSubpath()
            context.fill(topFace, with: .color(Color(red: 0.42, green: 0.78, blue: 0.28)))

            // Left face
            var leftFace = Path()
            leftFace.move(to: CGPoint(x: cx - halfW, y: midY))
            leftFace.addLine(to: CGPoint(x: cx, y: midY * 2))
            leftFace.addLine(to: CGPoint(x: cx, y: botY))
            leftFace.addLine(to: CGPoint(x: cx - halfW, y: botY - midY))
            leftFace.closeSubpath()
            context.fill(leftFace, with: .color(Color(red: 0.55, green: 0.36, blue: 0.22)))

            // Grass edge on left face
            var leftGrass = Path()
            leftGrass.move(to: CGPoint(x: cx - halfW, y: midY))
            leftGrass.addLine(to: CGPoint(x: cx, y: midY * 2))
            leftGrass.addLine(to: CGPoint(x: cx, y: midY * 2 + 3))
            leftGrass.addLine(to: CGPoint(x: cx - halfW, y: midY + 3))
            leftGrass.closeSubpath()
            context.fill(leftGrass, with: .color(Color(red: 0.34, green: 0.62, blue: 0.20)))

            // Right face
            var rightFace = Path()
            rightFace.move(to: CGPoint(x: cx, y: midY * 2))
            rightFace.addLine(to: CGPoint(x: cx + halfW, y: midY))
            rightFace.addLine(to: CGPoint(x: cx + halfW, y: botY - midY))
            rightFace.addLine(to: CGPoint(x: cx, y: botY))
            rightFace.closeSubpath()
            context.fill(rightFace, with: .color(Color(red: 0.44, green: 0.28, blue: 0.17)))

            // Grass edge on right face
            var rightGrass = Path()
            rightGrass.move(to: CGPoint(x: cx, y: midY * 2))
            rightGrass.addLine(to: CGPoint(x: cx + halfW, y: midY))
            rightGrass.addLine(to: CGPoint(x: cx + halfW, y: midY + 3))
            rightGrass.addLine(to: CGPoint(x: cx, y: midY * 2 + 3))
            rightGrass.closeSubpath()
            context.fill(rightGrass, with: .color(Color(red: 0.28, green: 0.52, blue: 0.16)))

            // Edges
            context.stroke(topFace, with: .color(Color.black.opacity(0.25)), lineWidth: 0.5)
            context.stroke(leftFace, with: .color(Color.black.opacity(0.15)), lineWidth: 0.5)
            context.stroke(rightFace, with: .color(Color.black.opacity(0.15)), lineWidth: 0.5)
        }
        .frame(width: size, height: quarterH * 3)
    }
}

/// 4x4 isometric grid
struct VillageGridView: View {
    @ObservedObject var village: VillageState
    @State private var selectedCell: (Int, Int)?

    let blockSize: CGFloat = 72

    private var blockH: CGFloat { blockSize / 4 * 3 }
    private var stepX: CGFloat { blockSize / 2 }
    private var stepY: CGFloat { blockSize / 4 }

    private struct Cell: Identifiable {
        let row: Int
        let col: Int
        var id: Int { row * 100 + col }
    }

    /// Tiles sorted by (row + col) ascending so foreground draws on top
    private var sortedCells: [Cell] {
        var cells: [Cell] = []
        for row in 0..<village.gridSize {
            for col in 0..<village.gridSize {
                cells.append(Cell(row: row, col: col))
            }
        }
        return cells.sorted { ($0.row + $0.col) < ($1.row + $1.col) }
    }

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Sort by (row + col) so foreground tiles are drawn on top
                ForEach(sortedCells, id: \.id) { cell in
                    VillageTileView(
                        tile: village.grid[cell.row][cell.col],
                        blockSize: blockSize,
                        isSelected: selectedCell?.0 == cell.row && selectedCell?.1 == cell.col
                    )
                    .offset(
                        x: CGFloat(cell.col - cell.row) * stepX,
                        y: CGFloat(cell.col + cell.row) * stepY
                    )
                    .onTapGesture {
                        selectedCell = (cell.row, cell.col)
                    }
                }
            }
            .frame(
                width: blockSize * CGFloat(village.gridSize),
                height: blockH + stepY * CGFloat(village.gridSize * 2)
            )
        }
        .popover(isPresented: Binding(
            get: { selectedCell != nil },
            set: { if !$0 { selectedCell = nil } }
        )) {
            if let (row, col) = selectedCell {
                TileEditorView(
                    village: village,
                    row: row,
                    col: col,
                    onClose: { selectedCell = nil }
                )
            }
        }
    }
}

/// A single tile: grass block + whole-tile ground + 3×3 sub-cells of objects & decorations.
struct VillageTileView: View {
    let tile: VillageTile
    let blockSize: CGFloat
    let isSelected: Bool

    /// Editor preview: highlight a specific sub-cell with a small yellow diamond.
    var selectedSubCell: (Int, Int)? = nil
    /// Editor preview: invoke when a sub-cell diamond is tapped.
    var onSubCellTap: ((Int, Int) -> Void)? = nil

    @State private var selectionPulse: Bool = false

    // GrassBlockView height = blockSize * 0.75; top face occupies top half
    // In a centered ZStack, the top face center sits at -blockSize/8 relative to ZStack center
    private var topFaceOffsetY: CGFloat { -blockSize / 8 }

    // Iso geometry for the 2×2 sub-grid on top of the tile's top-face diamond.
    // Each sub-cell is a mini diamond of size (blockSize/2 × blockSize/4).
    // Half-step between sub-cells:
    private var subStepX: CGFloat { blockSize / 4 }
    private var subStepY: CGFloat { blockSize / 8 }
    /// Y of the (row=0, col=0) sub-cell center, relative to ZStack center.
    private var subOriginY: CGFloat { topFaceOffsetY - blockSize / 8 }
    /// Rendered size of a sub-cell object sprite — sized to fit within the sub-cell
    /// diamond (blockSize/2 wide) so neighbors don't spill into each other.
    private var subObjectSize: CGFloat { blockSize / 2 }

    private struct Renderable: Identifiable {
        let subRow: Int
        let subCol: Int
        let building: BuildingType
        let isDecoration: Bool
        var id: String { "\(subRow)-\(subCol)-\(isDecoration ? "d" : "o")" }
        /// Lower z draws first (behind). Within the same sub-cell decoration goes on top.
        var zOrder: Int { (subRow + subCol) * 2 + (isDecoration ? 1 : 0) }
    }

    private var renderables: [Renderable] {
        var r: [Renderable] = []
        for sr in 0..<VillageTile.subGridSize {
            for sc in 0..<VillageTile.subGridSize {
                let cell = tile.subCells[sr][sc]
                if let oid = cell.object, let b = BuildingCatalog.find(oid) {
                    r.append(Renderable(subRow: sr, subCol: sc, building: b, isDecoration: false))
                }
                if let did = cell.decoration, let b = BuildingCatalog.find(did) {
                    r.append(Renderable(subRow: sr, subCol: sc, building: b, isDecoration: true))
                }
            }
        }
        return r.sorted { $0.zOrder < $1.zOrder }
    }

    private func subCellOffset(subRow: Int, subCol: Int) -> CGSize {
        let x = CGFloat(subCol - subRow) * subStepX
        let y = CGFloat(subCol + subRow) * subStepY + subOriginY
        return CGSize(width: x, height: y)
    }

    /// Number of empty (dot-only) pixel rows at the bottom of each sprite's 32×32 grid.
    /// Used to shift the rendered sprite down so its *visual* bottom — not the sprite's
    /// bounding-box bottom — sits at the sub-cell iso anchor. Without this correction,
    /// sprites with bottom padding (well, farm, fence) appear to float above the tile.
    ///
    /// Ground layers and billboards return 0 (they don't use the sub-cell baseline).
    private func spriteBaselineRows(for building: BuildingType) -> Int {
        switch building.id {
        // well removed from catalog
        // farm removed from catalog
        case "fence":    return 6   // iso redraw: content rows 9-25, rows 26-31 empty
        case "windmill": return 3
        case "house":    return 4   // iso redraw: content rows 4-27, rows 28-31 empty
        case "shop":     return 4   // 48×48 sprite: 6 empty rows × (32/48) scale = 4
        case "tree":       return 5   // compact tree: raised toward cell center
        case "street_tree": return 4  // columnar tree: same adjustment
        case "lamp":       return 4   // compact lamp, anchored higher on sub-cell
        default:         return 0
        }
    }

    /// Iso Y-shear applied to each sprite.
    ///
    /// Negative b=-0.5 aligns the sprite's horizontal edges with the top-LEFT diamond
    /// edge (slope -1:2), so the building's south/front face is visible — i.e. it
    /// "faces" the viewer who looks from the south-east. This is the correct orientation
    /// for a building sitting on the tile with its entrance/windows facing the camera.
    ///
    /// Billboards (tree, lamp) and ground layers return 0 (no shear).
    private func isoShearY(for building: BuildingType) -> CGFloat {
        switch building.id {
        case "tree", "lamp", "street_tree":
            return 0
        case "flowers", "stone_path":
            return 0
        case "house", "fence", "shop":
            return 0          // iso perspective already in the sprite pixels
        default:
            return -0.5       // south face visible — top-right corner rises to match left diamond edge
        }
    }

    var body: some View {
        ZStack {
            // Base: grass block (always)
            GrassBlockView(size: blockSize)

            // Ground layer — tints & decorates the top face
            if let groundId = tile.ground,
               let building = BuildingCatalog.find(groundId) {
                GroundLayerView(building: building, blockSize: blockSize)
                    .offset(y: topFaceOffsetY)
                    .allowsHitTesting(false)
            }

            // Selection highlight on top face (diamond)
            if isSelected {
                IsometricDiamond()
                    .fill(Color.yellow.opacity(0.35))
                    .frame(width: blockSize, height: blockSize / 2)
                    .offset(y: topFaceOffsetY)
                    .overlay(
                        IsometricDiamond()
                            .stroke(Color.yellow, lineWidth: 2.5)
                            .frame(width: blockSize, height: blockSize / 2)
                            .offset(y: topFaceOffsetY)
                            .shadow(color: .yellow, radius: selectionPulse ? 6 : 2)
                    )
                    .animation(
                        .easeInOut(duration: 0.7).repeatForever(autoreverses: true),
                        value: selectionPulse
                    )
                    .onAppear { selectionPulse = true }
            }

            // Sub-cell contents — objects and decorations painted back-to-front.
            //
            // Structures get a negative Y-shear (b = -0.5) so their front/south face
            // is visible to the SE-looking camera. A hard-edged shadow offset to the
            // right (+x) and slightly down (+y) along the iso east slope simulates the
            // east/right wall of the building, giving genuine 3-D depth perception.
            //
            // Billboards (tree, lamp) stay upright — iso convention for tall elements.
            // Ground layers are already diamond-clipped.
            ForEach(renderables) { item in
                let off = subCellOffset(subRow: item.subRow, subCol: item.subCol)
                let shear = isoShearY(for: item.building)
                let baselineShift = CGFloat(spriteBaselineRows(for: item.building)) * subObjectSize / 32.0
                BuildingPixelView(building: item.building, size: subObjectSize)
                    .transformEffect(
                        CGAffineTransform(a: 1, b: shear, c: 0, d: 1, tx: 0, ty: 0)
                    )
                    // East-face depth: hard shadow offset along the iso +0.5 east slope.
                    // Only applied to structures (shear != 0); billboards and ground omit it.
                    .shadow(
                        color: shear != 0 ? Color(white: 0.12).opacity(0.50) : .clear,
                        radius: 0,
                        x: subObjectSize * 0.12,
                        y: subObjectSize * 0.06
                    )
                    // Sub-cell anchor: the sprite's visual bottom lands at the sub-cell
                    // diamond's BOTTOM VERTEX (blockSize/8 past its center for 2×2 grid).
                    // baselineShift further compensates for per-sprite bottom padding.
                    .offset(
                        x: off.width,
                        y: off.height + blockSize / 8 - subObjectSize / 2 + baselineShift
                    )
                    .allowsHitTesting(false)
            }

            // Editor mode: selection highlight (visual only, does not hit-test)
            if let sel = selectedSubCell {
                let off = subCellOffset(subRow: sel.0, subCol: sel.1)
                IsometricDiamond()
                    .fill(Color.yellow.opacity(0.30))
                    .overlay(
                        IsometricDiamond()
                            .stroke(Color.yellow, lineWidth: 1.5)
                    )
                    .frame(width: blockSize / 2, height: blockSize / 4)
                    .offset(x: off.width, y: off.height)
                    .allowsHitTesting(false)
            }

            // Editor mode: single tap-catcher over the top-face diamond that
            // resolves the tapped sub-cell mathematically from the tap location.
            // This avoids z-order ambiguity between 9 overlapping diamond hit
            // shapes and gives a generous tap target for every cell.
            if let handler = onSubCellTap {
                GeometryReader { geo in
                    Color.clear
                        .contentShape(TopFaceDiamondHitArea())
                        .gesture(
                            SpatialTapGesture(coordinateSpace: .local)
                                .onEnded { value in
                                    // Convert tap location into the ZStack's centered
                                    // coordinate space (origin at tile center), then
                                    // remove subOriginY so iso math is anchored at
                                    // sub-cell (0,0).
                                    let cx = geo.size.width / 2
                                    let cy = geo.size.height / 2
                                    let x = value.location.x - cx
                                    let y = value.location.y - cy - subOriginY
                                    // Forward mapping:
                                    //   x = (subCol - subRow) * subStepX
                                    //   y = (subCol + subRow) * subStepY
                                    // Inverse:
                                    let u = x / subStepX       // = subCol - subRow
                                    let v = y / subStepY       // = subCol + subRow
                                    let subCol = Int(((u + v) / 2).rounded())
                                    let subRow = Int(((v - u) / 2).rounded())
                                    let last = VillageTile.subGridSize - 1
                                    let r = max(0, min(last, subRow))
                                    let c = max(0, min(last, subCol))
                                    handler(r, c)
                                }
                        )
                }
            }
        }
        // Restrict hit area to the diamond top face so adjacent tiles don't overlap
        .contentShape(TopFaceDiamondHitArea())
    }
}

/// Ground layer: renders a pixel-art ground sprite clipped to the top-face diamond.
struct GroundLayerView: View {
    let building: BuildingType
    let blockSize: CGFloat

    var body: some View {
        BuildingPixelView(building: building, size: blockSize)
            // Faint outline so the edge reads cleanly against the grass
            .overlay(
                IsometricDiamond()
                    .stroke(Color.black.opacity(0.18), lineWidth: 0.5)
                    .frame(width: blockSize, height: blockSize / 2)
            )
    }
}

/// Decoration layer: places a pixel-art decoration in the tile's front-right.
struct DecorationLayerView: View {
    let building: BuildingType
    let blockSize: CGFloat

    var body: some View {
        // Smaller than full object; decorations are accents.
        let decoSize = blockSize * 0.65
        BuildingPixelView(building: building, size: decoSize)
            .offset(x: blockSize * 0.18, y: blockSize * 0.18)
    }
}

/// Hit-testing shape: an isometric diamond positioned at the top face of the grass block
struct TopFaceDiamondHitArea: Shape {
    func path(in rect: CGRect) -> Path {
        // Top face occupies the top half of the tile
        let cx = rect.midX
        let top: CGFloat = 0
        let mid = rect.height * 0.33  // Where top face meets sides (≈ quarterH of blockSize*0.75)
        let hw = rect.width / 2

        var p = Path()
        p.move(to: CGPoint(x: cx, y: top))
        p.addLine(to: CGPoint(x: cx + hw, y: mid))
        p.addLine(to: CGPoint(x: cx, y: mid * 2))
        p.addLine(to: CGPoint(x: cx - hw, y: mid))
        p.closeSubpath()
        return p
    }
}

/// Isometric diamond (rhombus) shape matching the top face of a grass block
struct IsometricDiamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cx = rect.midX
        let cy = rect.midY
        let hw = rect.width / 2
        let hh = rect.height / 2
        path.move(to: CGPoint(x: cx, y: cy - hh))
        path.addLine(to: CGPoint(x: cx + hw, y: cy))
        path.addLine(to: CGPoint(x: cx, y: cy + hh))
        path.addLine(to: CGPoint(x: cx - hw, y: cy))
        path.closeSubpath()
        return path
    }
}
