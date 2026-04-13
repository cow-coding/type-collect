import SwiftUI

/// Isometric keycap shape - tapered sides with concave top dish
struct KeycapShapeView: View {
    let primaryColor: String
    let legendCharacter: String
    let isCollected: Bool
    let size: CGFloat

    var body: some View {
        let baseColor = isCollected ? Color(hex: primaryColor) : Color.gray.opacity(0.25)
        let textColor = isCollected ? legendColor : Color.gray.opacity(0.4)

        Canvas { context, canvasSize in
            let w = canvasSize.width
            let h = canvasSize.height
            let cx = w / 2

            // Top face (smaller rhombus)
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

            // Base (wider, bottom point)
            let baseBottom = CGPoint(x: cx, y: h * 0.88)
            let baseLeft = CGPoint(x: w * 0.06, y: h * 0.56)
            let baseRight = CGPoint(x: w * 0.94, y: h * 0.56)

            // Left side
            let leftSide = Path { p in
                p.move(to: CGPoint(x: topCenter.x - topW, y: topCenter.y))
                p.addLine(to: CGPoint(x: topCenter.x, y: topCenter.y + topH))
                p.addLine(to: baseBottom)
                p.addLine(to: baseLeft)
                p.closeSubpath()
            }

            // Right side
            let rightSide = Path { p in
                p.move(to: CGPoint(x: topCenter.x + topW, y: topCenter.y))
                p.addLine(to: CGPoint(x: topCenter.x, y: topCenter.y + topH))
                p.addLine(to: baseBottom)
                p.addLine(to: baseRight)
                p.closeSubpath()
            }

            // Draw sides (darker shades)
            context.fill(leftSide, with: .color(darken(baseColor, by: 0.25)))
            context.fill(rightSide, with: .color(darken(baseColor, by: 0.12)))

            // Draw top face
            context.fill(topFace, with: .color(baseColor))

            // Dish (concave surface - slightly darker)
            let dishInset: CGFloat = 0.35
            let dishCenter = topCenter
            let dishW = topW * (1 - dishInset)
            let dishH = topH * (1 - dishInset)

            let dish = Path { p in
                p.move(to: CGPoint(x: dishCenter.x, y: dishCenter.y - dishH))
                p.addLine(to: CGPoint(x: dishCenter.x + dishW, y: dishCenter.y))
                p.addLine(to: CGPoint(x: dishCenter.x, y: dishCenter.y + dishH))
                p.addLine(to: CGPoint(x: dishCenter.x - dishW, y: dishCenter.y))
                p.closeSubpath()
            }
            context.fill(dish, with: .color(darken(baseColor, by: 0.06)))

            // Outline
            let outlineColor: Color = isCollected ? .black.opacity(0.35) : .gray.opacity(0.25)
            context.stroke(topFace, with: .color(outlineColor), lineWidth: 1.5)
            context.stroke(leftSide, with: .color(outlineColor), lineWidth: 1.5)
            context.stroke(rightSide, with: .color(outlineColor), lineWidth: 1.5)

            // Highlight on top edges
            if isCollected {
                let highlight = Path { p in
                    p.move(to: CGPoint(x: topCenter.x, y: topY))
                    p.addLine(to: CGPoint(x: topCenter.x + topW, y: topCenter.y))
                }
                let highlight2 = Path { p in
                    p.move(to: CGPoint(x: topCenter.x, y: topY))
                    p.addLine(to: CGPoint(x: topCenter.x - topW, y: topCenter.y))
                }
                context.stroke(highlight, with: .color(.white.opacity(0.3)), lineWidth: 1.5)
                context.stroke(highlight2, with: .color(.white.opacity(0.2)), lineWidth: 1.5)
            }
        }
        .frame(width: size, height: size)
        .overlay(
            // Legend character or lock icon
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
        // Approximate darkening by blending with black
        return color.opacity(1.0 - Double(amount) * 0.5)
    }
}
