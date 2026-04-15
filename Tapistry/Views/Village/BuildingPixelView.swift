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

// MARK: - Color palette

enum SpriteColors {
    // Foliage
    static let leaf         = Color(red: 0.36, green: 0.68, blue: 0.28)
    static let leafDark     = Color(red: 0.22, green: 0.48, blue: 0.16)
    static let leafLight    = Color(red: 0.55, green: 0.82, blue: 0.40)

    // Wood
    static let bark         = Color(red: 0.48, green: 0.30, blue: 0.15)
    static let barkDark     = Color(red: 0.30, green: 0.18, blue: 0.08)
    static let barkLight    = Color(red: 0.62, green: 0.42, blue: 0.22)
    static let plank        = Color(red: 0.72, green: 0.54, blue: 0.32)
    static let plankDark    = Color(red: 0.50, green: 0.34, blue: 0.16)

    // House
    static let roof         = Color(red: 0.80, green: 0.30, blue: 0.24)
    static let roofDark     = Color(red: 0.58, green: 0.18, blue: 0.14)
    static let roofLight    = Color(red: 0.92, green: 0.46, blue: 0.36)
    static let wall         = Color(red: 0.94, green: 0.86, blue: 0.66)
    static let wallDark     = Color(red: 0.72, green: 0.60, blue: 0.40)
    static let wallLight    = Color(red: 1.0,  green: 0.96, blue: 0.82)
    static let window       = Color(red: 0.48, green: 0.76, blue: 0.94)
    static let windowDark   = Color(red: 0.28, green: 0.52, blue: 0.72)
    static let door         = Color(red: 0.42, green: 0.24, blue: 0.12)
    static let doorLight    = Color(red: 0.58, green: 0.36, blue: 0.18)
    static let chimney      = Color(red: 0.52, green: 0.50, blue: 0.52)
    static let chimneyDark  = Color(red: 0.30, green: 0.28, blue: 0.30)

    // Stone
    static let stone        = Color(red: 0.62, green: 0.62, blue: 0.64)
    static let stoneDark    = Color(red: 0.42, green: 0.42, blue: 0.46)
    static let stoneLight   = Color(red: 0.78, green: 0.78, blue: 0.80)

    // Windmill
    static let millRoof     = Color(red: 0.58, green: 0.32, blue: 0.20)
    static let millRoofDark = Color(red: 0.38, green: 0.20, blue: 0.12)
    static let millBody     = Color(red: 0.94, green: 0.90, blue: 0.80)
    static let millBodyDark = Color(red: 0.72, green: 0.66, blue: 0.54)
    static let millBlade    = Color(red: 0.98, green: 0.96, blue: 0.90)
    static let millBladeDark = Color(red: 0.72, green: 0.68, blue: 0.54)
    static let millHub      = Color(red: 0.32, green: 0.22, blue: 0.14)

    // Flowers / nature
    static let grass        = Color(red: 0.44, green: 0.76, blue: 0.30)
    static let grassDark    = Color(red: 0.30, green: 0.58, blue: 0.18)
    static let flowerPink   = Color(red: 0.96, green: 0.56, blue: 0.72)
    static let flowerYellow = Color(red: 0.98, green: 0.86, blue: 0.30)
    static let flowerWhite  = Color(red: 0.98, green: 0.96, blue: 0.94)
    static let flowerPurple = Color(red: 0.74, green: 0.56, blue: 0.92)

    // Farm / dirt
    static let dirt         = Color(red: 0.46, green: 0.30, blue: 0.18)
    static let dirtDark     = Color(red: 0.30, green: 0.20, blue: 0.12)
    static let dirtLight    = Color(red: 0.60, green: 0.42, blue: 0.26)
    static let sprout       = Color(red: 0.40, green: 0.72, blue: 0.30)

    // Lamp
    static let lampPole     = Color(red: 0.28, green: 0.28, blue: 0.30)
    static let lampHead     = Color(red: 0.44, green: 0.44, blue: 0.48)
    static let lampGlow     = Color(red: 1.0,  green: 0.94, blue: 0.62)
    static let lampGlowSoft = Color(red: 1.0,  green: 0.88, blue: 0.42).opacity(0.55)

    // Shop
    static let shopAwning   = Color(red: 0.92, green: 0.36, blue: 0.36)
    static let shopAwning2  = Color(red: 0.98, green: 0.96, blue: 0.90)
    static let shopWall     = Color(red: 0.96, green: 0.82, blue: 0.58)
    static let shopWallDark = Color(red: 0.72, green: 0.58, blue: 0.36)
    static let shopSign     = Color(red: 0.82, green: 0.68, blue: 0.36)
    static let shopSignDark = Color(red: 0.50, green: 0.38, blue: 0.18)

    // Water (well)
    static let water        = Color(red: 0.22, green: 0.42, blue: 0.64)
    static let waterDark    = Color(red: 0.14, green: 0.28, blue: 0.44)

    // Shadow
    static let shadow       = Color.black.opacity(0.22)
    static let shadowLight  = Color.black.opacity(0.12)
}

// MARK: - Sprite definitions

private enum Sprites {
    // MARK: Tree (32×32, split into canopy + trunk for sway)

    static let treeCanopy = PixelArt(
        rows: [
            "................................",
            "............gGGGGGGgg...........",
            "..........gGGGLLLLLGGGg.........",
            ".........gGGGLLLLLLGGGGg........",
            "........gGLLLGGGGGLLLLGGg.......",
            ".......gGLLGGGGddGGLLLGGGGg.....",
            "......gGGLGGGddGGGGLLGGGGGGg....",
            "......gGGGGGddGGGGGGGGGGGGGGg...",
            ".....gGLGGGGGGGGGLLGGGGLGGGGGg..",
            ".....gGGGGLLGGdGGLLGGGGGGGGGGGg.",
            "....gGGGGLLLGGGdGGGGGGLGGGGGGGg.",
            "....gGGLLGGGGGGGGGGGGLLGGdGGGGg.",
            "....gGGGGGGGGGGdGGGGLLGGGGGGGg..",
            "....gGGdGGGGGGddGGGGGGGGGGGGg...",
            ".....gGGGddGGGGGGGGGLLGGGGGGg...",
            "......gGGGGGGGGGGGGGLLGGGGg.....",
            ".......gGGGGGGGGGGGGGGGGg.......",
        ],
        colors: [
            "G": SpriteColors.leaf,
            "g": SpriteColors.leafDark,
            "L": SpriteColors.leafLight,
            "d": SpriteColors.leafDark,
        ]
    )

    static let treeTrunk = PixelArt(
        rows: [
            "..............BBBB..............",
            "..............BBBB..............",
            ".............bBBBBb.............",
            ".............bBBBBb.............",
            ".............bBBBBb.............",
            "............bBBBBBBb............",
            "............bBBBBBBb............",
            "...........bbBBBBBBbb...........",
            "..........bbbBBBBBBbbb..........",
            ".........bbbbbbbbbbbbbb.........",
            "........xxxxxxxxxxxxxxxx........",
            ".........xxxxxxxxxxxxxx.........",
            "...........xxxxxxxxxx...........",
            "................................",
            "................................",
        ],
        colors: [
            "B": SpriteColors.bark,
            "b": SpriteColors.barkDark,
            "x": SpriteColors.shadow,
        ]
    )

    // MARK: House (32×32)

    /// Iso house — horizontally mirrored from the first POC so the door-face (south)
    /// is on the RIGHT of the sprite, matching the viewer convention that buildings
    /// "face east" (entrance points to the right in screen space). The east-face
    /// shadow panel is now on the LEFT. Walls still rectangular with slight iso
    /// trim on top/bottom edges; roof is a pyramid with the peak on the RIGHT-center.
    static let house = PixelArt(
        rows: [
            "................................",
            "................................",
            "................................",
            "................................",
            "................................",
            "................................",
            ".........cCCc...................",
            "..........CC....................",
            "..........CC....................",
            "..........CC......R.............",
            "..........CC....rrRRR...........",
            "..........CC..rrrrRRRRR.........",
            "..........CCrrrrrRRRRRRRRR......",
            "..........CCrrrrrRRRRRRRRRRW....",
            "........rrrrrrrrRRRRRRRRRWWn....",
            "......rrrrrrrrrrRRRRRRRWWnnn....",
            "....EErrrrrrrrrRRRRRRWWnnnnn....",
            "....eeEErrrrrrrRRRRWWnnnnnnn....",
            "....eeeeEErrrrRRRWWnnXXXnnnn....",
            "....eeXXXeEErrRWWnnnnXXXnnnn....",
            "....eeXXXeEErWWnnnnnnnnnnnnn....",
            "....EeeeeeeeEWnnDDDnnnnnnnnW....",
            "....EeeeeeeeEWnnDdDnnnnnW.......",
            "....EeeeeeeeEWnnDhDnnnW.........",
            "......EeeeeEWnnDdDnW............",
            "........EeeeEWnnDDD.............",
            "..........EeEWnnW...............",
            "............EWW.................",
            "................................",
            "................................",
            "................................",
            "................................",
        ],
        colors: [
            "R": SpriteColors.roof,          // south roof face (now on RIGHT of sprite)
            "r": SpriteColors.roofDark,      // east roof face (now on LEFT, in shadow)
            "C": SpriteColors.chimney,       // chimney body (light side)
            "c": SpriteColors.chimneyDark,   // chimney cap shadow
            "W": SpriteColors.wallDark,      // south wall trim
            "n": SpriteColors.wall,          // south wall body
            "E": SpriteColors.plankDark,     // east wall trim
            "e": SpriteColors.wallDark,      // east wall body
            "X": SpriteColors.window,
            "D": SpriteColors.door,
            "d": SpriteColors.doorLight,
            "h": SpriteColors.shopSign,      // doorknob
            "K": SpriteColors.plankDark,     // base trim
        ]
    )

    // MARK: Windmill tower + blades (32×32 each)

    static let windmillTower = PixelArt(
        rows: [
            "................................",
            "...............rr...............",
            "..............rRRr..............",
            ".............rRRRRr.............",
            "............rRRRRRRr............",
            "...........rRRRRRRRRr...........",
            "..........rRRRRRRRRRRr..........",
            ".........rRRRHHHHHHRRRr.........",
            "........rRRRHHHHHHHHRRRr........",
            ".......rRRRRHHHHHHHHRRRRr.......",
            "........WWWWWWWWWWWWWWWW........",
            "........WnnnnnnnnnnnnnnW........",
            "........WnnnnnnnnnnnnnnW........",
            "........WnXXXnnnnnnnXXXW........",
            "........WnXXXnnnnnnnXXXW........",
            "........WnXXXnnnnnnnXXXW........",
            "........WnnnnnnnnnnnnnnW........",
            "........WnnnnnnnnnnnnnnW........",
            "........WnnnnnnnnnnnnnnW........",
            "........WnnnnnDDDDnnnnnW........",
            "........WnnnnnDddDnnnnnW........",
            "........WnnnnnDdhDnnnnnW........",
            "........WnnnnnDddDnnnnnW........",
            "........WnnnnnDddDnnnnnW........",
            "........WnnnnnDDDDnnnnnW........",
            "........WWWWWWWWWWWWWWWW........",
            ".......KKKKKKKKKKKKKKKKKK.......",
            "......xxxxxxxxxxxxxxxxxxxx......",
            ".......xxxxxxxxxxxxxxxxxx.......",
            "................................",
            "................................",
            "................................",
        ],
        colors: [
            "R": SpriteColors.millRoof,
            "r": SpriteColors.millRoofDark,
            "H": SpriteColors.millHub,
            "W": SpriteColors.millBodyDark,
            "n": SpriteColors.millBody,
            "X": SpriteColors.window,
            "D": SpriteColors.door,
            "d": SpriteColors.doorLight,
            "h": SpriteColors.shopSign,
            "K": SpriteColors.plankDark,
            "x": SpriteColors.shadow,
        ]
    )

    static let windmillBlades = PixelArt(
        rows: [
            "..............BBB...............",
            "..............BBB...............",
            "..............BBB...............",
            "..............BBB...............",
            "..............BBB...............",
            "..............BBB...............",
            "..............bBB...............",
            "..............bBB...............",
            "..............bBB...............",
            "..............bBB...............",
            "..............bBB...............",
            "..............bBB...............",
            "..............bBB...............",
            "BBBBBBBBBBBBBBHHHBBBBBBBBBBBBBBB",
            "bbbbbbbbbbbbbbhhhBBBBBBBBBBBBBBB",
            "..............bbbbbbbbbbbbbbbbbb",
            "..............bBB...............",
            "..............bBB...............",
            "..............bBB...............",
            "..............bBB...............",
            "..............bBB...............",
            "..............bBB...............",
            "..............bBB...............",
            "..............bBB...............",
            "..............bBB...............",
            "..............bBB...............",
            "..............bBB...............",
            "..............bBB...............",
            "..............bBB...............",
            "..............bBB...............",
            "................................",
            "................................",
        ],
        colors: [
            "B": SpriteColors.millBlade,
            "b": SpriteColors.millBladeDark,
            "H": SpriteColors.millHub,
            "h": SpriteColors.millHub,
        ]
    )

    // MARK: Well (32×32)

    static let well = PixelArt(
        rows: [
            "................................",
            "................................",
            "..........WWWWWWWWWWWW..........",
            ".........WRRRRRRRRRRRRW.........",
            "........WRRRRRRRRRRRRRRW........",
            ".......WRRRRRRRRRRRRRRRRW.......",
            "......WRRRRRRRRRRRRRRRRRRW......",
            "......WrrrrrrrrrrrrrrrrrrW......",
            "................................",
            ".............BBBBBB.............",
            ".............BbbbbB.............",
            ".............BbbbbB.............",
            ".............BbbbbB.............",
            ".............BbbbbB.............",
            ".......SSSSSSSSSSSSSSSSSS.......",
            "......SssssssssssssssssssS......",
            ".....SssSSSSSSSSSSSSSSSSssS.....",
            ".....Sswwwwwwwwwwwwwwwwwws......",
            ".....SsOOOOOOOOOOOOOOOOOOs......",
            ".....SsOOOOOOOOOOOOOOOOOOs......",
            ".....SssSSSSSSSSSSSSSSSSssS.....",
            ".....SssssssssssssssssssS.......",
            "......SSSSSSSSSSSSSSSSSS........",
            "................................",
            "................................",
            "................................",
            "................................",
            "................................",
            "................................",
            "................................",
            "................................",
            "................................",
        ],
        colors: [
            "W": SpriteColors.millRoofDark,
            "R": SpriteColors.millRoof,
            "r": SpriteColors.millRoofDark,
            "B": SpriteColors.bark,
            "b": SpriteColors.barkDark,
            "S": SpriteColors.stoneDark,
            "s": SpriteColors.stone,
            "w": SpriteColors.water,
            "O": SpriteColors.waterDark,
            "x": SpriteColors.shadow,
        ]
    )

    // MARK: Farm (32×32)

    static let farm = PixelArt(
        rows: [
            "................................",
            "................................",
            "................................",
            "................................",
            "................................",
            "................................",
            "................................",
            "......ssssssssssssssssssssss....",
            ".....sSSSSSSSSSSSSSSSSSSSSSSs...",
            "....sSDDDDDDDDDDDDDDDDDDDDDDSs..",
            "....sSDdDDDdDDDdDDDdDDDdDDDDSs..",
            "....sSDDsssDssssDssssDssssDDSs..",
            "....sSDDDDDDDDDDDDDDDDDDDDDDSs..",
            "....sSDDsssDssssDssssDssssDDSs..",
            "....sSDdDDDdDDDdDDDdDDDdDDDDSs..",
            "....sSDDsssDssssDssssDssssDDSs..",
            "....sSDDDDDDDDDDDDDDDDDDDDDDSs..",
            "....sSDDsssDssssDssssDssssDDSs..",
            "....sSDdDDDdDDDdDDDdDDDdDDDDSs..",
            "....sSDDDDDDDDDDDDDDDDDDDDDDSs..",
            "....sSSSSSSSSSSSSSSSSSSSSSSSSs..",
            "....ssssssssssssssssssssssssss..",
            "................................",
            "................................",
            "................................",
            "................................",
            "................................",
            "................................",
            "................................",
            "................................",
            "................................",
            "................................",
        ],
        colors: [
            "D": SpriteColors.dirt,
            "d": SpriteColors.dirtLight,
            "S": SpriteColors.dirtDark,
            "s": SpriteColors.sprout,
        ]
    )

    // MARK: Shop (32×32)

    static let shop = PixelArt(
        rows: [
            "................................",
            "................................",
            "................................",
            ".........gggggggggggggggg.......",
            ".........gSSSSSSSSSSSSSSg.......",
            ".........gSgSggSgSSgSgSSg.......",
            ".........gSggSggSSggSSggg.......",
            ".........gSSSSSSSSSSSSSSg.......",
            ".........gggggggggggggggg.......",
            "........aAAAAAAAAAAAAAAAAa......",
            "........aBBBBBBBBBBBBBBBBa......",
            "........aAAAAAAAAAAAAAAAAa......",
            "........aBBBBBBBBBBBBBBBBa......",
            "......WWWWWWWWWWWWWWWWWWWW......",
            "......WnnnnnnnnnnnnnnnnnnW......",
            "......WnXXXXnnnnnnnnXXXXnW......",
            "......WnXXXXnnnnnnnnXXXXnW......",
            "......WnXXXXnnnnnnnnXXXXnW......",
            "......WnXXXXnnnnnnnnXXXXnW......",
            "......WnnnnnnnnnnnnnnnnnnW......",
            "......WnnnnnnnDDDDnnnnnnnW......",
            "......WnnnnnnnDddDnnnnnnnW......",
            "......WnnnnnnnDdhDnnnnnnnW......",
            "......WnnnnnnnDddDnnnnnnnW......",
            "......WnnnnnnnDddDnnnnnnnW......",
            "......WnnnnnnnDDDDnnnnnnnW......",
            "......WWWWWWWWWWWWWWWWWWWW......",
            ".....KKKKKKKKKKKKKKKKKKKKKK.....",
            "....xxxxxxxxxxxxxxxxxxxxxxxx....",
            ".....xxxxxxxxxxxxxxxxxxxxxx.....",
            "................................",
            "................................",
        ],
        colors: [
            "S": SpriteColors.shopSign,
            "g": SpriteColors.shopSignDark,
            "A": SpriteColors.shopAwning,
            "a": SpriteColors.shopSignDark,
            "B": SpriteColors.shopAwning2,
            "W": SpriteColors.shopWallDark,
            "n": SpriteColors.shopWall,
            "X": SpriteColors.window,
            "D": SpriteColors.door,
            "d": SpriteColors.doorLight,
            "h": SpriteColors.shopSign,
            "K": SpriteColors.plankDark,
            "x": SpriteColors.shadow,
        ]
    )

    // MARK: Flowers ground (32×32, tileable)

    static let flowersGround = PixelArt(
        rows: [
            "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
            "GgGgGgGgGgGgGgGgGgGgGgGgGgGgGgGg",
            "GGyGGGGGGGpGGGGGGGGwGGGGGGGuGGGG",
            "GyyyGGGGGpppGGGGGGwwwGGGGGuuuGGG",
            "GGyGGGGGGGpGGGGGGGGwGGGGGGGuGGGG",
            "GgGgGgGgGgGgGgGgGgGgGgGgGgGgGgGg",
            "GGGGGGGpGGGGGGGuGGGGGGyGGGGGGGGG",
            "GGGGGGpppGGGGGGuuuGGGGyyyGGGGGGG",
            "GGGGGGGpGGGGGGGuGGGGGGGyGGGGGGGG",
            "GgGgGgGgGgGgGgGgGgGgGgGgGgGgGgGg",
            "GGwGGGGGGGGyGGGGGGGGpGGGGGGGGuGG",
            "GwwwGGGGGGyyyGGGGGGpppGGGGGGuuuG",
            "GGwGGGGGGGGyGGGGGGGGpGGGGGGGGuGG",
            "GgGgGgGgGgGgGgGgGgGgGgGgGgGgGgGg",
            "GGGGGpGGGGGGGyGGGGGGGwGGGGGGGGGG",
            "GGGGpppGGGGGGyyyGGGGGwwwGGGGGGGG",
            "GGGGGpGGGGGGGyGGGGGGGwGGGGGGGGGG",
            "GgGgGgGgGgGgGgGgGgGgGgGgGgGgGgGg",
            "GGuGGGGGGGpGGGGGGGGwGGGGGGGyGGGG",
            "GuuuGGGGGpppGGGGGGwwwGGGGGyyyGGG",
            "GGuGGGGGGGpGGGGGGGGwGGGGGGGyGGGG",
            "GgGgGgGgGgGgGgGgGgGgGgGgGgGgGgGg",
            "GGGGGGGyGGGGGGGuGGGGGGpGGGGGGGGG",
            "GGGGGGyyyGGGGGGuuuGGGGpppGGGGGGG",
            "GGGGGGGyGGGGGGGuGGGGGGGpGGGGGGGG",
            "GgGgGgGgGgGgGgGgGgGgGgGgGgGgGgGg",
            "GGwGGGGGGGGpGGGGGGGGyGGGGGGGGuGG",
            "GwwwGGGGGGpppGGGGGGyyyGGGGGGuuuG",
            "GGwGGGGGGGGpGGGGGGGGyGGGGGGGGuGG",
            "GgGgGgGgGgGgGgGgGgGgGgGgGgGgGgGg",
            "GGGGpGGGGGGGuGGGGGGGyGGGGGGGwGGG",
            "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",
        ],
        colors: [
            "G": SpriteColors.grass,
            "g": SpriteColors.grassDark,
            "p": SpriteColors.flowerPink,
            "y": SpriteColors.flowerYellow,
            "w": SpriteColors.flowerWhite,
            "u": SpriteColors.flowerPurple,
        ]
    )

    // MARK: Stone Path ground (32×32)

    static let stonePathGround = PixelArt(
        rows: [
            "GgGgGgGgGgGgGgGgGgGgGgGgGgGgGgGg",
            "GSSSSsSGGsSSSsSSSGGSSSsSSSssSSSG",
            "GSssSssSGsSssSssSGSssSsssSsSSsSG",
            "GssSSsssGsssSSssSsSssSSSsSsSSSsG",
            "GgGgGgGgGgGgGgGgGgGgGgGgGgGgGgGg",
            "GSssSSSsSGSsSSsSSsGSSSsSSsSSsSSG",
            "GSSSssSssGSssSsSSSGSssSSSssSSsSG",
            "GSssSsSSSGSsSSSssSGSsSSsSSSsSSSG",
            "GgGgGgGgGgGgGgGgGgGgGgGgGgGgGgGg",
            "GsSSsSSSSGSSsSSSsSGSsSSsSsSSSsSG",
            "GSssSsSSsGSsSsSSsSGSSSsSSSsSSsSG",
            "GSSsSSSSSGsSSsSSsSGSsSsSsSSSsSSG",
            "GgGgGgGgGgGgGgGgGgGgGgGgGgGgGgGg",
            "GSSSsSSsSGSsSsSSSsGsSsSSsSSsSSsG",
            "GsSsSSSsSGSSsSSsSSGSsSsSsSsSSsSG",
            "GSsSSsSsSGSSsSSSsSGSsSsSSsSsSSsG",
            "GgGgGgGgGgGgGgGgGgGgGgGgGgGgGgGg",
            "GSsSsSsSsGSsSsSsSsGsSsSSsSSSsSSG",
            "GsSSsSsSsGsSsSSsSSGSsSSSSsSsSSsG",
            "GSSSsSsSsGsSSSsSSsGSsSsSsSsSsSSG",
            "GgGgGgGgGgGgGgGgGgGgGgGgGgGgGgGg",
            "GSsSsSSSsGSSSSssSSGSsSsSSsSSSssG",
            "GssSsSsSSGSsSsSSSsGSSSsSSSsSSsSG",
            "GSsSSsSSsGSsSSsSSsGSsSsSsSSSSSsG",
            "GgGgGgGgGgGgGgGgGgGgGgGgGgGgGgGg",
            "GSsSsSsSsGsSSsSsSSGSsSSsSsSSsSSG",
            "GsSSsSsSSGSSsSSsSSGSsSSsSsSSsSsG",
            "GSsSsSSsSGSsSsSSsSGsSsSsSsSsSSsG",
            "GgGgGgGgGgGgGgGgGgGgGgGgGgGgGgGg",
            "GSSsSsSsSGsSsSsSsSGSSsSSsSsSSsSG",
            "GssSsSSSsGSSsSsSSsGSsSsSsSSsSSsG",
            "GgGgGgGgGgGgGgGgGgGgGgGgGgGgGgGg",
        ],
        colors: [
            "G": SpriteColors.grass,
            "g": SpriteColors.grassDark,
            "S": SpriteColors.stone,
            "s": SpriteColors.stoneLight,
        ]
    )

    // MARK: Fence (32×32 decoration)

    /// Iso fence: two vertical posts (cols 7 and 23) with two rails sloping -0.5
    /// up-right. Shifted up-right so the lower-left post doesn't overflow below
    /// the tile while the upper-right spills naturally into neighboring cells.
    static let fence = PixelArt(
        rows: [
            "................................",
            "................................",
            "................................",
            "................................",
            "................................",
            "................................",
            ".......................P........",
            "......................PP........",
            "....................PP.P........",
            "..................PP...P........",
            "................PP.....P........",
            "..............PP.......P........",
            "............PP........PP........",
            "..........PP........PP.P........",
            ".......PPP........PP...P........",
            ".......P........PP..............",
            ".......P......PP................",
            ".......P....PP..................",
            ".......P..PP....................",
            ".......PPP......................",
            ".......P........................",
            ".......P........................",
            ".......P........................",
            "................................",
            "................................",
            "................................",
            "................................",
            "................................",
            "................................",
            "................................",
            "................................",
            "................................",
        ],
        colors: [
            "P": SpriteColors.plank,
            "p": SpriteColors.plankDark,
        ]
    )

    // MARK: Lamp (32×32 decoration)

    static let lamp = PixelArt(
        rows: [
            "................................",
            "................................",
            "................................",
            "................................",
            "................................",
            "................................",
            "................................",
            "................................",
            "................................",
            "................................",
            ".............YYYY...............",
            ".............YLLY...............",
            ".............YLLY...............",
            ".............YYYY...............",
            ".............HHHH...............",
            ".............HHHH...............",
            "..............PP................",
            "..............PP................",
            "..............PP................",
            "..............PP................",
            "..............PP................",
            "..............PP................",
            ".............pPPp...............",
            "............ppPPpp..............",
            "................................",
            "................................",
            "................................",
            "................................",
            "................................",
            "................................",
            "................................",
            "................................",
        ],
        colors: [
            "Y": SpriteColors.lampGlowSoft,
            "y": SpriteColors.lampGlow,
            "L": SpriteColors.lampGlow,
            "H": SpriteColors.lampHead,
            "P": SpriteColors.lampPole,
            "p": SpriteColors.shadow,
        ]
    )

    // MARK: LV UP! badge (32×16) — used on the level-up toast

    static let lvUpBadge = PixelArt(
        rows: [
            "................................",
            "................................",
            "................................",
            "................................",
            "................................",
            "...G....G...G..G...G.GGG..G.....",
            "...G....G...G..G...G.G..G.G.....",
            "...G....G...G..G...G.G..G.G.....",
            "...G....G...G..G...G.GGG..G.....",
            "...G....G...G..G...G.G....G.....",
            "...G.....G.G..G...G.G...........",
            "...GGGG...G.....GGG..G....G.....",
            "................................",
            "................................",
            "................................",
            "................................",
        ],
        colors: [
            "G": SpriteColors.leafLight,
        ]
    )

    // MARK: Logo house (32×32) — used in Welcome step 1

    static let logoHouse = PixelArt(
        rows: [
            "................................",
            "................................",
            "................................",
            "................................",
            "................................",
            "................................",
            "...............RR...............",
            "..............RrRR..............",
            ".............RrrrRR.............",
            "............RrrrrrRR............",
            "...........RrrrrrrrRR...........",
            "..........RrrrrrrrrrRR..........",
            ".........RrrrrrrrrrrrRR.........",
            "........RrrrrrrrrrrrrrRR........",
            ".......RrrrrrrrrrrrrrrrRR.......",
            "......RrrrrrrrrrrrrrrrrrRR......",
            ".....RRRRRRRRRRRRRRRRRRRRRR.....",
            ".....BBBBBBBBBBBBBBBBBBBBBB.....",
            "......WWWWWWWWWWWWWWWWWWWW......",
            "......WwwwwwwwwwwwwwwwwwwW......",
            "......WwXXxxwwwwwwwwxXXwwW......",
            "......WwXXxxwwwwwwwwxXXwwW......",
            "......WwXXxxwwwwwwwwxXXwwW......",
            "......WwwwwwwwwwwwwwwwwwwW......",
            "......WwwwwwwwwDDDDwwwwwwW......",
            "......WwwwwwwwDDDDDDwwwwwW......",
            "......WwwwwwwwDDDDDDwwwwwW......",
            "......WwwwwwwwDDdDDDwwwwwW......",
            "......WwwwwwwwDDDDDDwwwwwW......",
            "......BBBBBBBBBBBBBBBBBBBB......",
            ".....gGgGGgGGGgGGgGGGgGGgg......",
            "....gggggggggggggggggggggggg....",
        ],
        colors: [
            "R": SpriteColors.leafDark,
            "r": SpriteColors.leaf,
            "B": SpriteColors.barkDark,
            "W": SpriteColors.wallLight,
            "w": SpriteColors.wall,
            "X": SpriteColors.windowDark,
            "x": SpriteColors.window,
            "D": SpriteColors.door,
            "d": SpriteColors.doorLight,
            "G": SpriteColors.grass,
            "g": SpriteColors.grassDark,
        ]
    )
}

// MARK: - Public sprite wrappers (for non-building UI like Welcome / LevelUp)

/// 32×32 Tapistry brand logo house. Used on the Welcome onboarding step 1.
struct LogoHouseView: View {
    let size: CGFloat
    var body: some View {
        PixelSpriteView(art: Sprites.logoHouse, width: size)
    }
}

/// "LV UP!" pixel-art badge — used on the level-up toast instead of the ⭐️ emoji.
/// Pulses slowly via a scale-based repeating animation.
struct LvUpBadgeView: View {
    let width: CGFloat
    @State private var pulse = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(SpriteColors.leafDark.opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(SpriteColors.leaf, lineWidth: 1.5)
                )
            PixelSpriteView(art: Sprites.lvUpBadge, width: width * 0.88)
        }
        .frame(width: width, height: width * 0.5)
        .scaleEffect(pulse ? 1.04 : 0.96)
        .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: pulse)
        .onAppear { pulse = true }
    }
}

// MARK: - Isometric diamond shape (for ground clipping)

private struct DiamondMask: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let cx = rect.midX, cy = rect.midY
        let hw = rect.width / 2, hh = rect.height / 2
        p.move(to: CGPoint(x: cx, y: cy - hh))
        p.addLine(to: CGPoint(x: cx + hw, y: cy))
        p.addLine(to: CGPoint(x: cx, y: cy + hh))
        p.addLine(to: CGPoint(x: cx - hw, y: cy))
        p.closeSubpath()
        return p
    }
}

// MARK: - Dispatcher

/// Renders a building using pixel-art for all known building types.
struct BuildingPixelView: View {
    let building: BuildingType
    let size: CGFloat

    var body: some View {
        switch building.id {
        case "tree":       TreePixelView(size: size)
        case "house":      HousePixelView(size: size)
        case "windmill":   WindmillPixelView(size: size)
        case "well":       WellPixelView(size: size)
        case "farm":       FarmPixelView(size: size)
        case "shop":       ShopPixelView(size: size)
        case "fence":      PixelSpriteView(art: Sprites.fence, width: size)
        case "lamp":       LampPixelView(size: size)
        case "flowers":    FlowersGroundView(size: size)
        case "stone_path": GroundPixelView(art: Sprites.stonePathGround, size: size)
        default:
            // Fallback to emoji for any unexpected id
            Text(building.emoji).font(.system(size: size * 0.8))
        }
    }
}

// MARK: - Ground (clipped to isometric diamond)

/// Renders a ground-layer sprite masked to the isometric top-face diamond.
private struct GroundPixelView: View {
    let art: PixelArt
    let size: CGFloat

    var body: some View {
        PixelSpriteView(art: art, width: size)
            .frame(width: size, height: size / 2)  // top face aspect
            .clipShape(DiamondMask())
    }
}

// MARK: - Flowers (wind sway)

/// Flowers ground layer with a horizontal shear that waves the petals
/// left-right like wind catching a meadow. The shear is applied based
/// on y with the reference at the diamond's vertical midline, so the
/// upper half of the clipped diamond sways while the lower half stays
/// relatively planted. Period ≈ 2.4 s, amplitude ±0.08 shear coefficient.
private struct FlowersGroundView: View {
    let size: CGFloat
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: false)) { ctx in
            let t = ctx.date.timeIntervalSinceReferenceDate
            let shear = 0.08 * sin(t * 2.0 * .pi / 2.4)
            PixelSpriteView(art: Sprites.flowersGround, width: size)
                .transformEffect(
                    CGAffineTransform(a: 1, b: 0, c: shear, d: 1,
                                      tx: -shear * size / 2, ty: 0)
                )
                .frame(width: size, height: size / 2)
                .clipShape(DiamondMask())
        }
    }
}

// MARK: - Well (water shimmer)

/// Well with a soft horizontal highlight drifting across the water surface, hinting
/// at ripples. The highlight is a thin bright strip whose horizontal position and
/// opacity cycle on out-of-phase sin waves so it feels organic rather than metronomic.
private struct WellPixelView: View {
    let size: CGFloat

    // Water rows in the 32×32 well sprite are rows 17–20 → mid-water at row 18.5.
    // Left/right bounds of the water area ≈ cols 6..25 (inclusive) → 19 cols wide.
    private var waterCenterY: CGFloat { size * (18.5 / 32.0 - 0.5) }
    private var waterW: CGFloat { size * 19.0 / 32.0 }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: false)) { ctx in
            let t = ctx.date.timeIntervalSinceReferenceDate
            let drift = 0.35 * sin(t * 2.0 * .pi / 3.0)         // -0.35..0.35
            let fade  = 0.5 + 0.5 * sin(t * 2.0 * .pi / 2.2)    // 0..1
            PixelSpriteView(art: Sprites.well, width: size)
                .overlay(
                    Rectangle()
                        .fill(Color.white.opacity(0.22 * fade))
                        .frame(width: waterW * 0.35, height: size * 0.04)
                        .offset(x: drift * waterW * 0.4, y: waterCenterY)
                        .blendMode(.screen)
                        .allowsHitTesting(false)
                )
        }
    }
}

// MARK: - Shop (awning flap)

/// Shop with a tiny rotational sway concentrated near the awning — 0.9° amplitude,
/// period ≈ 2.1 s, anchored slightly above center so the base of the building stays
/// planted while the cloth awning appears to catch a light breeze.
private struct ShopPixelView: View {
    let size: CGFloat
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: false)) { ctx in
            let t = ctx.date.timeIntervalSinceReferenceDate
            let deg = 0.9 * sin(t * 2.0 * .pi / 2.1)
            PixelSpriteView(art: Sprites.shop, width: size)
                .rotationEffect(.degrees(deg), anchor: .init(x: 0.5, y: 0.75))
        }
    }
}

// MARK: - Farm (gentle wind sway)

/// Farm crop with a small rotation wave — reads as wind catching the sprouts.
/// Period ≈ 2.6 s, amplitude ±1.2°.
private struct FarmPixelView: View {
    let size: CGFloat
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: false)) { ctx in
            let t = ctx.date.timeIntervalSinceReferenceDate
            let deg = 1.2 * sin(t * 2.0 * .pi / 2.6)
            PixelSpriteView(art: Sprites.farm, width: size)
                .rotationEffect(.degrees(deg), anchor: .bottom)
        }
    }
}

// MARK: - Tree (canopy sway)

private struct TreePixelView: View {
    let size: CGFloat
    @State private var sway: Double = 0

    // Full tree: 32 wide × (17 canopy + 15 trunk) = 32×32 at size scale
    private var spriteWidth: CGFloat { size }

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

    // House grid 32×32. Chimney at cols 10-11, rows 6-13 (iso redesign, on east roof).
    private var pixelSize: CGFloat { size / 32 }
    private var chimneyCenterX: CGFloat { pixelSize * 10.5 - size / 2 }

    var body: some View {
        ZStack {
            PixelSpriteView(art: Sprites.house, width: size)

            ForEach(0..<3, id: \.self) { i in
                SmokePuff(
                    baseOffsetX: chimneyCenterX,
                    travelHeight: size * 0.35,
                    puffSize: pixelSize * 2.2,
                    phaseOffset: Double(i) * 0.33,
                    topOfHouseY: -size / 2 + pixelSize * 2
                )
            }
        }
        .frame(width: size, height: size)
    }
}

private struct SmokePuff: View {
    let baseOffsetX: CGFloat
    let travelHeight: CGFloat
    let puffSize: CGFloat
    let phaseOffset: Double
    let topOfHouseY: CGFloat
    let duration: Double = 2.4

    var body: some View {
        TimelineView(.animation) { context in
            let t = context.date.timeIntervalSinceReferenceDate / duration + phaseOffset
            let p = t.truncatingRemainder(dividingBy: 1.0)
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

    // Tower grid (32×32): hub at col 15.5, row 8 (center of rows 7-9).
    // Blades grid (32×32): hub cross at col 15.5, row 13.5.
    private let bladeAnchor = UnitPoint(x: 15.5 / 32.0, y: 13.5 / 32.0)

    var body: some View {
        ZStack(alignment: .topLeading) {
            PixelSpriteView(art: Sprites.windmillTower, width: size)

            // Blade frame is size×size. For the blade's hub pixel to sit at the
            // tower's hub pixel, shift blade up by (13.5 - 8) × pixelSize.
            PixelSpriteView(art: Sprites.windmillBlades, width: size)
                .rotationEffect(.degrees(angle), anchor: bladeAnchor)
                .offset(y: size * (8.0 - 13.5) / 32.0)
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.linear(duration: 4.5).repeatForever(autoreverses: false)) {
                angle = 360
            }
        }
    }
}

// MARK: - Lamp (light flicker)

private struct LampPixelView: View {
    let size: CGFloat
    @State private var flicker: Double = 1.0

    var body: some View {
        PixelSpriteView(art: Sprites.lamp, width: size)
            .shadow(color: SpriteColors.lampGlow.opacity(flicker * 0.6), radius: 6)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                    flicker = 0.75
                }
            }
    }
}
