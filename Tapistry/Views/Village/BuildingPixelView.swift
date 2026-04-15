import SwiftUI

// MARK: - Pixel art primitives

/// A multi-line string sprite + color map. Each char in `rows` resolves to a color via `colors`.
/// Characters not in the map render as transparent.
struct PixelArt {
    let rows: [String]
    let colors: [Character: Color]

    var gridWidth: Int { rows.first?.count ?? 0 }
    var gridHeight: Int { rows.count }
}

/// Renders a PixelArt as crisp filled rectangles via a single Canvas pass.
/// Sized by `width`; height is derived from the sprite's aspect ratio so pixels stay square.
struct PixelSpriteView: View {
    let art: PixelArt
    let width: CGFloat

    var height: CGFloat {
        guard art.gridWidth > 0, art.gridHeight > 0 else { return 0 }
        return width * CGFloat(art.gridHeight) / CGFloat(art.gridWidth)
    }

    var body: some View {
        Canvas { ctx, cs in
            let cols = CGFloat(art.gridWidth)
            let rowsN = CGFloat(art.gridHeight)
            guard cols > 0, rowsN > 0 else { return }
            let pw = cs.width / cols
            let ph = cs.height / rowsN

            for (y, row) in art.rows.enumerated() {
                for (x, ch) in row.enumerated() {
                    guard let color = art.colors[ch] else { continue }
                    // Tiny overlap to avoid hairline gaps between pixels
                    let rect = CGRect(
                        x: CGFloat(x) * pw,
                        y: CGFloat(y) * ph,
                        width: pw + 0.5,
                        height: ph + 0.5
                    )
                    ctx.fill(Path(rect), with: .color(color))
                }
            }
        }
        .frame(width: width, height: height)
    }
}

// MARK: - Sprite definitions

private enum Sprites {
    static let leaf        = Color(red: 0.36, green: 0.68, blue: 0.28)
    static let leafDark    = Color(red: 0.24, green: 0.50, blue: 0.18)
    static let leafLight   = Color(red: 0.52, green: 0.80, blue: 0.38)
    static let bark        = Color(red: 0.42, green: 0.26, blue: 0.13)
    static let barkDark    = Color(red: 0.28, green: 0.17, blue: 0.08)

    static let roof        = Color(red: 0.78, green: 0.28, blue: 0.22)
    static let roofDark    = Color(red: 0.56, green: 0.17, blue: 0.12)
    static let wall        = Color(red: 0.94, green: 0.84, blue: 0.65)
    static let wallDark    = Color(red: 0.74, green: 0.62, blue: 0.42)
    static let window      = Color(red: 0.45, green: 0.72, blue: 0.92)
    static let door        = Color(red: 0.38, green: 0.22, blue: 0.10)
    static let chimney     = Color(red: 0.48, green: 0.48, blue: 0.50)
    static let chimneyDark = Color(red: 0.28, green: 0.28, blue: 0.30)

    static let millBody    = Color(red: 0.92, green: 0.88, blue: 0.78)
    static let millBodyDark = Color(red: 0.70, green: 0.64, blue: 0.50)
    static let millRoof    = Color(red: 0.58, green: 0.32, blue: 0.20)
    static let millBlade   = Color(red: 0.98, green: 0.95, blue: 0.88)
    static let millBladeDark = Color(red: 0.70, green: 0.65, blue: 0.50)
    static let millHub     = Color(red: 0.30, green: 0.22, blue: 0.14)

    static let tree = PixelArt(
        rows: [
            "....gGGGg....",
            "...gGLLGGg...",
            "..gGLLLLGGg..",
            ".gGLGGGGLGGg.",
            "gGGGGGGGGGGGg",
            "GGdGGGLLGGdGG",
            "GGGGGGLLGGGGG",
            ".gGGdGGGGdGG.",
            "..gGGGGGGGg..",
            "...gGGGGGg...",
            "....ggGGg....",
            ".....bBb.....",
            ".....bBb.....",
            ".....bBb.....",
            "....bBBBb....",
            "...xbbBbbx...",
        ],
        colors: [
            "G": Sprites.leaf,
            "g": Sprites.leafDark,
            "L": Sprites.leafLight,
            "d": Sprites.leafDark,
            "B": Sprites.bark,
            "b": Sprites.barkDark,
            "x": Color.black.opacity(0.18),
        ]
    )

    /// Tree canopy only — for sway animation
    static let treeCanopy = PixelArt(
        rows: Array(tree.rows.prefix(11)),
        colors: tree.colors
    )

    /// Tree trunk only — stays still
    static let treeTrunk = PixelArt(
        rows: Array(tree.rows.suffix(5)),
        colors: tree.colors
    )

    static let house = PixelArt(
        rows: [
            "......CC......",
            ".....cCCc.....",
            "....rRRRRr....",
            "...rRRRRRRr...",
            "..rRRRRRRRRr..",
            ".rRRRRRRRRRRr.",
            "rRRRRRRRRRRRRr",
            "WWWWWWWWWWWWWW",
            "WwXXwWWWWwXXwW",
            "WwXXwWWWWwXXwW",
            "WwwwwWWWWwwwwW",
            "WWWWWWDDWWWWWW",
            "WWWWWWDDWWWWWW",
            "WWWWWWDDWWWWWW",
        ],
        colors: [
            "R": Sprites.roof,
            "r": Sprites.roofDark,
            "C": Sprites.chimney,
            "c": Sprites.chimneyDark,
            "W": Sprites.wall,
            "w": Sprites.wallDark,
            "X": Sprites.window,
            "D": Sprites.door,
        ]
    )

    /// Windmill tower (no blades — blades are a separate rotating sprite)
    static let windmillTower = PixelArt(
        rows: [
            ".....rRRRRr.....",
            "....rRRRRRRr....",
            "...rRRRRRRRRr...",
            "..rRRHHHHHHRRr..",
            "..rRR.HHHH.RRr..",
            "..rRR.HHHH.RRr..",
            "..rRRHHHHHHRRr..",
            "..WWWWWWWWWWWW..",
            "..WwwwWWWWwwwW..",
            "..WwXXWWWWwXXW..",
            "..WwXXWWWWwXXW..",
            "..WwwwWWWWwwwW..",
            "..WWWWWDDWWWWW..",
            "..WWWWWDDWWWWW..",
            "..WWWWWDDWWWWW..",
            ".xWWWWWDDWWWWWx.",
        ],
        colors: [
            "R": Sprites.millRoof,
            "r": Sprites.millRoof.opacity(0.7),
            "H": Sprites.millHub,
            "W": Sprites.millBody,
            "w": Sprites.millBodyDark,
            "X": Sprites.window,
            "D": Sprites.door,
            "x": Color.black.opacity(0.18),
        ]
    )

    /// Windmill blades — rotates
    static let windmillBlades = PixelArt(
        rows: [
            "......B......",
            "......B......",
            "......B......",
            "......B......",
            "......B......",
            "......B......",
            "BBBBBBhBBBBBB",
            "......B......",
            "......B......",
            "......B......",
            "......B......",
            "......B......",
            "......B......",
        ],
        colors: [
            "B": Sprites.millBlade,
            "h": Sprites.millHub,
        ]
    )
}

// MARK: - Dispatcher

/// Renders a building using pixel-art for the upgraded set (tree/house/windmill),
/// falls back to emoji for everything else.
struct BuildingPixelView: View {
    let building: BuildingType
    let size: CGFloat

    var body: some View {
        switch building.id {
        case "tree":     TreePixelView(size: size)
        case "house":    HousePixelView(size: size)
        case "windmill": WindmillPixelView(size: size)
        default:         EmojiBuildingView(building: building, size: size)
        }
    }
}

private struct EmojiBuildingView: View {
    let building: BuildingType
    let size: CGFloat

    var body: some View {
        Text(building.emoji)
            .font(.system(size: size * 0.8))
    }
}

// MARK: - Tree (canopy sway)

private struct TreePixelView: View {
    let size: CGFloat
    @State private var sway: Double = 0

    // Full tree grid: 13 cols × 16 rows. Fit into size × size so pixelSize = size/16
    // and sprite width = 13/16 × size (centered horizontally in the square frame).
    private var spriteWidth: CGFloat { size * 13 / 16 }

    var body: some View {
        VStack(spacing: 0) {
            PixelSpriteView(art: Sprites.treeCanopy, width: spriteWidth)
                .rotationEffect(.degrees(sway), anchor: .bottom)
            PixelSpriteView(art: Sprites.treeTrunk, width: spriteWidth)
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                sway = 2.5
            }
        }
    }
}

// MARK: - House (chimney smoke)

private struct HousePixelView: View {
    let size: CGFloat

    // House grid: 14×14, pixels are square. Chimney is at cols 6-7, top.
    private var pixelSize: CGFloat { size / 14 }
    private var chimneyCenterX: CGFloat { pixelSize * 6.5 - size / 2 }

    var body: some View {
        ZStack {
            PixelSpriteView(art: Sprites.house, width: size)

            // Three smoke puffs, each on its own phase-offset loop
            ForEach(0..<3, id: \.self) { i in
                SmokePuff(
                    baseOffsetX: chimneyCenterX,
                    travelHeight: size * 0.35,
                    puffSize: pixelSize * 1.3,
                    phaseOffset: Double(i) * 0.33,
                    topOfHouseY: -size / 2 + pixelSize
                )
            }
        }
        .frame(width: size, height: size)
    }
}

/// A single smoke puff that rises from the chimney, drifts, fades, and loops.
/// Driven by TimelineView so each puff's phase is independent and stable across redraws.
private struct SmokePuff: View {
    let baseOffsetX: CGFloat
    let travelHeight: CGFloat
    let puffSize: CGFloat
    let phaseOffset: Double       // 0..1
    let topOfHouseY: CGFloat
    let duration: Double = 2.4

    var body: some View {
        TimelineView(.animation) { context in
            let t = context.date.timeIntervalSinceReferenceDate / duration + phaseOffset
            let p = t.truncatingRemainder(dividingBy: 1.0) // 0..1
            Circle()
                .fill(Color.white.opacity(0.75))
                .frame(width: puffSize, height: puffSize)
                .offset(
                    x: baseOffsetX + CGFloat(sin(p * .pi * 2)) * puffSize * 0.8,
                    y: topOfHouseY - CGFloat(p) * travelHeight
                )
                .opacity((1.0 - p) * 0.75)
                .blur(radius: 0.8)
        }
    }
}

// MARK: - Windmill (rotating blades)

private struct WindmillPixelView: View {
    let size: CGFloat
    @State private var angle: Double = 0

    /// Hub center in the 16×16 tower grid: col 7.5 (midpoint of HHHHHH cols 5-10), row 4.5
    private var hubCenterX: CGFloat { size * (7.5 / 16.0) }
    private var hubCenterY: CGFloat { size * (4.5 / 16.0) }

    var body: some View {
        ZStack(alignment: .topLeading) {
            PixelSpriteView(art: Sprites.windmillTower, width: size)

            // Blades centered on hub
            PixelSpriteView(art: Sprites.windmillBlades, width: size * (13.0 / 16.0))
                .rotationEffect(.degrees(angle))
                .offset(
                    x: hubCenterX - (size * 13.0 / 16.0) / 2,
                    y: hubCenterY - (size * 13.0 / 16.0) / 2
                )
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.linear(duration: 4.5).repeatForever(autoreverses: false)) {
                angle = 360
            }
        }
    }
}
