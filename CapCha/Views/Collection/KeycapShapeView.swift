import SwiftUI

struct KeycapShapeView: View {
    let primaryColor: String
    let legendCharacter: String
    let rarity: Rarity
    let isCollected: Bool
    let size: CGFloat
    var widthUnit: CGFloat = 1.0
    var setName: String = ""

    private var assetName: String {
        KeycapCatalog.assetName(for: widthUnit)
    }

    /// Offset to position legend on the isometric top face
    private var legendYOffset: CGFloat {
        -size * 0.15
    }

    /// Isometric rotation angle for text on top face
    private var legendRotation: Angle {
        .degrees(-45)
    }

    var body: some View {
        ZStack {
            if isCollected { rarityGlow }

            keycapImage
                .overlay(legendOverlay)
        }
    }

    // MARK: - Keycap Image

    @ViewBuilder
    private var keycapImage: some View {
        if let nsImage = NSImage(named: assetName) {
            let tint = KeycapCatalog.tintColor(for: setName)
            Image(nsImage: nsImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: size)
                .colorMultiply(isCollected ? tintToColor(tint) : Color.gray.opacity(0.5))
                .saturation(isCollected ? 1.0 : 0.0)
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(isCollected ? Color(hex: primaryColor) : Color.gray.opacity(0.3))
                .frame(width: size, height: size)
        }
    }

    // MARK: - Legend Overlay

    @ViewBuilder
    private var legendOverlay: some View {
        if isCollected {
            if legendCharacter != "Space" {
                legendView(textColor: legendTextColor)
                    .rotationEffect(legendRotation)
                    .offset(y: legendYOffset)
            }
            // Space: no legend
        } else {
            Image(systemName: "lock.fill")
                .font(.system(size: size * 0.14))
                .foregroundColor(.gray.opacity(0.5))
                .offset(y: legendYOffset)
        }
    }

    @ViewBuilder
    private func legendView(textColor: Color) -> some View {
        if legendCharacter == "BS" {
            Image(systemName: "delete.backward")
                .font(.system(size: legendFontSize * 0.85, weight: .bold))
                .foregroundColor(textColor)
        } else if legendCharacter == "Enter" {
            Image(systemName: "return")
                .font(.system(size: legendFontSize * 0.85, weight: .bold))
                .foregroundColor(textColor)
        } else if legendCharacter == "Tab" {
            Image(systemName: "arrow.right.to.line")
                .font(.system(size: legendFontSize * 0.8, weight: .bold))
                .foregroundColor(textColor)
        } else if legendCharacter == "Caps" {
            Image(systemName: "capslock")
                .font(.system(size: legendFontSize * 0.8, weight: .bold))
                .foregroundColor(textColor)
        } else if legendCharacter == "Shift" {
            Image(systemName: "shift")
                .font(.system(size: legendFontSize * 0.85, weight: .bold))
                .foregroundColor(textColor)
        } else if legendCharacter == "Ctrl" {
            Image(systemName: "control")
                .font(.system(size: legendFontSize * 0.75, weight: .bold))
                .foregroundColor(textColor)
        } else if legendCharacter == "Alt" {
            Image(systemName: "option")
                .font(.system(size: legendFontSize * 0.75, weight: .bold))
                .foregroundColor(textColor)
        } else if legendCharacter == "Cmd" {
            Image(systemName: "command")
                .font(.system(size: legendFontSize * 0.75, weight: .bold))
                .foregroundColor(textColor)
        } else if legendCharacter == "Fn" {
            Text("fn")
                .font(.system(size: legendFontSize * 0.7, weight: .bold))
                .foregroundColor(textColor)
        } else if legendCharacter == "Esc" {
            Text("Esc")
                .font(.system(size: legendFontSize * 0.7, weight: .bold))
                .foregroundColor(textColor)
        } else {
            Text(legendCharacter)
                .font(.system(size: adjustedFontSize, weight: .bold, design: .monospaced))
                .foregroundColor(textColor)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
    }

    // MARK: - Sizing

    private var legendFontSize: CGFloat {
        if widthUnit >= 5.0 { return size * 0.14 }
        if widthUnit >= 2.0 { return size * 0.18 }
        if widthUnit > 1.0 { return size * 0.20 }
        return size * 0.24
    }

    /// Scale down font for longer text legends
    private var adjustedFontSize: CGFloat {
        let len = legendCharacter.count
        if len <= 1 { return legendFontSize }
        if len == 2 { return legendFontSize * 0.85 }
        if len == 3 { return legendFontSize * 0.65 }
        if len == 4 { return legendFontSize * 0.55 }
        return legendFontSize * 0.45
    }

    // MARK: - Color Helpers

    private func tintToColor(_ tint: (hue: Double, saturation: Double, brightness: Double)) -> Color {
        Color(hue: tint.hue, saturation: tint.saturation, brightness: tint.brightness)
    }

    /// Auto contrast: dark text on bright keycaps, light text on dark keycaps
    private var legendTextColor: Color {
        let tint = KeycapCatalog.tintColor(for: setName)
        let brightness = tint.brightness * (1.0 - tint.saturation * 0.5)
        return brightness > 0.7 ? .black.opacity(0.7) : .white.opacity(0.9)
    }

    // MARK: - Rarity Effects

    @ViewBuilder
    private var rarityGlow: some View {
        let glowSize = size * 1.2
        switch rarity {
        case .common:
            EmptyView()
        case .uncommon:
            Circle()
                .fill(rarity.color.opacity(0.08))
                .frame(width: glowSize, height: glowSize)
                .blur(radius: 4)
        case .rare:
            Circle()
                .fill(rarity.color.opacity(0.15))
                .frame(width: glowSize, height: glowSize)
                .blur(radius: 6)
        case .epic:
            Circle()
                .fill(rarity.color.opacity(0.25))
                .frame(width: glowSize, height: glowSize)
                .blur(radius: 10)
        case .legendary:
            Circle()
                .fill(Color.orange.opacity(0.3))
                .frame(width: glowSize, height: glowSize)
                .blur(radius: 14)
        case .eternal:
            TimelineView(.animation) { timeline in
                let t = timeline.date.timeIntervalSinceReferenceDate
                let hue = t.truncatingRemainder(dividingBy: 3.0) / 3.0
                Circle()
                    .fill(Color(hue: hue, saturation: 0.6, brightness: 1.0).opacity(0.35))
                    .frame(width: glowSize, height: glowSize)
                    .blur(radius: 16)
            }
        }
    }
}
