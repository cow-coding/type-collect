import SwiftUI

struct KeycapShapeView: View {
    let primaryColor: String
    let legendCharacter: String
    let rarity: Rarity
    let isCollected: Bool
    let size: CGFloat

    var body: some View {
        let baseColor = isCollected ? Color(hex: primaryColor) : Color.gray.opacity(0.25)
        let textColor = isCollected ? legendColor : Color.gray.opacity(0.4)

        ZStack {
            // Background glow for Rare+
            if isCollected {
                rarityGlow
            }

            Canvas { context, canvasSize in
                let w = canvasSize.width
                let h = canvasSize.height
                let cx = w / 2

                let topY = h * 0.08
                let topW = w * 0.38
                let topH = h * 0.22
                let topCenter = CGPoint(x: cx, y: h * 0.28)

                let topFace = Path { p in
                    p.move(to: CGPoint(x: topCenter.x, y: topY))
                    p.addLine(to: CGPoint(x: topCenter.x + topW, y: topCenter.y))
                    p.addLine(to: CGPoint(x: topCenter.x, y: topCenter.y + topH))
                    p.addLine(to: CGPoint(x: topCenter.x - topW, y: topCenter.y))
                    p.closeSubpath()
                }

                let baseBottom = CGPoint(x: cx, y: h * 0.88)
                let baseLeft = CGPoint(x: w * 0.06, y: h * 0.56)
                let baseRight = CGPoint(x: w * 0.94, y: h * 0.56)

                let leftSide = Path { p in
                    p.move(to: CGPoint(x: topCenter.x - topW, y: topCenter.y))
                    p.addLine(to: CGPoint(x: topCenter.x, y: topCenter.y + topH))
                    p.addLine(to: baseBottom)
                    p.addLine(to: baseLeft)
                    p.closeSubpath()
                }

                let rightSide = Path { p in
                    p.move(to: CGPoint(x: topCenter.x + topW, y: topCenter.y))
                    p.addLine(to: CGPoint(x: topCenter.x, y: topCenter.y + topH))
                    p.addLine(to: baseBottom)
                    p.addLine(to: baseRight)
                    p.closeSubpath()
                }

                // Fill sides
                context.fill(leftSide, with: .color(darken(baseColor, by: 0.25)))
                context.fill(rightSide, with: .color(darken(baseColor, by: 0.12)))

                // Fill top
                context.fill(topFace, with: .color(baseColor))

                // Dish
                let dishInset: CGFloat = 0.35
                let dishW = topW * (1 - dishInset)
                let dishH = topH * (1 - dishInset)
                let dish = Path { p in
                    p.move(to: CGPoint(x: topCenter.x, y: topCenter.y - dishH))
                    p.addLine(to: CGPoint(x: topCenter.x + dishW, y: topCenter.y))
                    p.addLine(to: CGPoint(x: topCenter.x, y: topCenter.y + dishH))
                    p.addLine(to: CGPoint(x: topCenter.x - dishW, y: topCenter.y))
                    p.closeSubpath()
                }
                context.fill(dish, with: .color(darken(baseColor, by: 0.06)))

                // Outline - thicker for higher rarities
                let outlineWidth: CGFloat = isCollected ? rarityOutlineWidth : 1.0
                let outlineColor: Color = isCollected ? rarityOutlineColor : .gray.opacity(0.25)
                context.stroke(topFace, with: .color(outlineColor), lineWidth: outlineWidth)
                context.stroke(leftSide, with: .color(outlineColor), lineWidth: outlineWidth)
                context.stroke(rightSide, with: .color(outlineColor), lineWidth: outlineWidth)

                // Highlight - stronger for higher rarities
                if isCollected {
                    let hlAlpha = highlightAlpha
                    let highlight = Path { p in
                        p.move(to: CGPoint(x: topCenter.x, y: topY))
                        p.addLine(to: CGPoint(x: topCenter.x + topW, y: topCenter.y))
                    }
                    let highlight2 = Path { p in
                        p.move(to: CGPoint(x: topCenter.x, y: topY))
                        p.addLine(to: CGPoint(x: topCenter.x - topW, y: topCenter.y))
                    }
                    context.stroke(highlight, with: .color(.white.opacity(hlAlpha)), lineWidth: highlightWidth)
                    context.stroke(highlight2, with: .color(.white.opacity(hlAlpha * 0.7)), lineWidth: highlightWidth)

                    // Epic+ inner shine on dish
                    if rarity >= .epic {
                        let shine = Path { p in
                            p.move(to: CGPoint(x: topCenter.x, y: topCenter.y - dishH * 0.5))
                            p.addLine(to: CGPoint(x: topCenter.x + dishW * 0.5, y: topCenter.y))
                        }
                        context.stroke(shine, with: .color(.white.opacity(0.5)), lineWidth: 1.5)
                    }
                }
            }
            .frame(width: size, height: size)
            .overlay(
                Group {
                    if isCollected {
                        Text(legendCharacter)
                            .font(.system(size: size * 0.22, weight: .bold, design: .monospaced))
                            .foregroundColor(textColor)
                            .offset(y: -size * 0.22)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: size * 0.18))
                            .foregroundColor(.gray.opacity(0.4))
                            .offset(y: -size * 0.22)
                    }
                }
            )
        }
    }

    // MARK: - Rarity Visual Properties

    @ViewBuilder
    private var rarityGlow: some View {
        switch rarity {
        case .common:
            EmptyView()
        case .uncommon:
            RoundedRectangle(cornerRadius: 8)
                .fill(rarity.color.opacity(0.08))
                .frame(width: size * 0.85, height: size * 0.85)
                .blur(radius: 4)
        case .rare:
            RoundedRectangle(cornerRadius: 8)
                .fill(rarity.color.opacity(0.15))
                .frame(width: size * 0.9, height: size * 0.9)
                .blur(radius: 6)
        case .epic:
            RoundedRectangle(cornerRadius: 8)
                .fill(rarity.color.opacity(0.25))
                .frame(width: size * 0.95, height: size * 0.95)
                .blur(radius: 10)
        case .legendary:
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.orange.opacity(0.3))
                .frame(width: size, height: size)
                .blur(radius: 14)
        case .eternal:
            TimelineView(.animation) { timeline in
                let t = timeline.date.timeIntervalSinceReferenceDate
                let hue = t.truncatingRemainder(dividingBy: 3.0) / 3.0
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hue: hue, saturation: 0.6, brightness: 1.0).opacity(0.35))
                    .frame(width: size, height: size)
                    .blur(radius: 16)
            }
        }
    }

    private var rarityOutlineWidth: CGFloat {
        switch rarity {
        case .common: return 1.0
        case .uncommon: return 1.5
        case .rare: return 2.0
        case .epic: return 2.5
        case .legendary: return 3.0
        case .eternal: return 3.0
        }
    }

    private var rarityOutlineColor: Color {
        switch rarity {
        case .common: return .black.opacity(0.3)
        case .uncommon: return rarity.color.opacity(0.5)
        case .rare: return rarity.color.opacity(0.6)
        case .epic: return rarity.color.opacity(0.7)
        case .legendary: return Color.orange.opacity(0.8)
        case .eternal: return .purple.opacity(0.8)
        }
    }

    private var highlightAlpha: Double {
        switch rarity {
        case .common: return 0.15
        case .uncommon: return 0.35
        case .rare: return 0.45
        case .epic: return 0.55
        case .legendary: return 0.65
        case .eternal: return 0.7
        }
    }

    private var highlightWidth: CGFloat {
        switch rarity {
        case .common, .uncommon: return 1.5
        case .rare: return 2.0
        case .epic: return 2.5
        case .legendary, .eternal: return 3.0
        }
    }

    // MARK: - Helpers

    private var legendColor: Color {
        let hex = primaryColor.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0
        let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
        return luminance > 0.5 ? .black.opacity(0.7) : .white.opacity(0.9)
    }

    private func darken(_ color: Color, by amount: CGFloat) -> Color {
        return color.opacity(1.0 - Double(amount) * 0.5)
    }
}
