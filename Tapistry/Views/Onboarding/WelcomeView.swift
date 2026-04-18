import SwiftUI

struct WelcomeView: View {
    var onComplete: () -> Void

    @ObservedObject private var settings = AppSettings.shared
    @State private var currentStep = 0

    private var lang: AppLanguage { settings.language }

    // Design tokens (dark-only palette; window is dark)
    private let surface = Color(red: 0.047, green: 0.055, blue: 0.071)
    private let surfaceContainerHigh = Color(red: 0.11, green: 0.125, blue: 0.15)
    private let onSurface = Color(red: 0.886, green: 0.898, blue: 0.937)
    private let outline = Color(red: 0.55, green: 0.57, blue: 0.62)
    private let primaryColor = Color(red: 0.45, green: 0.78, blue: 0.52)     // meadow green
    private let primaryDim = Color(red: 0.30, green: 0.58, blue: 0.36)

    private let totalSteps = 3

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch currentStep {
                case 0: stepTitle
                case 1: stepConcept
                default: stepPrivacy
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
            .animation(.easeInOut(duration: 0.3), value: currentStep)

            VStack(spacing: 16) {
                HStack(spacing: 8) {
                    ForEach(0..<totalSteps, id: \.self) { i in
                        Circle()
                            .fill(i == currentStep ? primaryColor : outline.opacity(0.3))
                            .frame(width: 6, height: 6)
                            .animation(.easeOut(duration: 0.2), value: currentStep)
                    }
                }

                Button {
                    if currentStep < totalSteps - 1 {
                        currentStep += 1
                    } else {
                        AppSettings.shared.hasCompletedOnboarding = true
                        onComplete()
                    }
                } label: {
                    Text(currentStep < totalSteps - 1
                         ? L10n.welcomeNext.resolve(lang)
                         : L10n.welcomeGetStarted.resolve(lang))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [primaryDim, primaryColor],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 28)
        }
        .frame(width: 480, height: 520)
        .background(surface)
    }

    // MARK: - Step 1: Title

    private var stepTitle: some View {
        VStack(spacing: 18) {
            Spacer()
            LogoHouseView(size: 128)

            Text("Tapistry")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(onSurface)

            Text(L10n.welcomeTagline.resolve(lang))
                .font(.system(size: 14))
                .foregroundColor(outline)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.horizontal, 40)
            Spacer()
        }
    }

    // MARK: - Step 2: Concept (live pixel-art preview)

    private var stepConcept: some View {
        VStack(spacing: 18) {
            Spacer().frame(height: 28)

            Text(L10n.welcomeConceptTitle.resolve(lang))
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(onSurface)

            Text(L10n.welcomeConceptBody.resolve(lang))
                .font(.system(size: 13))
                .foregroundColor(outline)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            // Live preview row — real animated sprites
            HStack(spacing: 20) {
                previewCell(id: "tree",     levelLabel: "Lv.1",  name: L10n.welcomePreviewTree.resolve(lang))
                previewCell(id: "house",    levelLabel: "Lv.5",  name: L10n.welcomePreviewHouse.resolve(lang))
                previewCell(id: "windmill", levelLabel: "Lv.20", name: L10n.welcomePreviewWindmill.resolve(lang))
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(surfaceContainerHigh)
            )
            .padding(.horizontal, 32)
        }
    }

    private func previewCell(id: String, levelLabel: String, name: String) -> some View {
        let building = BuildingCatalog.find(id)
        return VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.black.opacity(0.25))
                    .frame(width: 92, height: 92)

                if let b = building {
                    BuildingPixelView(building: b, size: 76)
                }
            }
            Text(name)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(onSurface)
            Text(levelLabel)
                .font(.system(size: 9, weight: .heavy, design: .monospaced))
                .tracking(0.6)
                .foregroundColor(primaryColor)
        }
    }

    // MARK: - Step 3: Privacy

    private var stepPrivacy: some View {
        VStack(alignment: .leading, spacing: 14) {
            Spacer()
            HStack(spacing: 10) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 24))
                    .foregroundColor(primaryColor)

                Text(L10n.welcomePrivacyTitle.resolve(lang))
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(onSurface)
            }
            .padding(.horizontal, 32)

            Text(L10n.welcomePrivacySubtitle.resolve(lang))
                .font(.system(size: 13))
                .foregroundColor(outline)
                .padding(.horizontal, 32)

            VStack(spacing: 0) {
                privacyRow(
                    icon: "keyboard",
                    title: L10n.welcomePrivacyRow1Title.resolve(lang),
                    detail: L10n.welcomePrivacyRow1Detail.resolve(lang)
                )
                privacyRow(
                    icon: "internaldrive",
                    title: L10n.welcomePrivacyRow2Title.resolve(lang),
                    detail: L10n.welcomePrivacyRow2Detail.resolve(lang)
                )
                privacyRow(
                    icon: "chart.bar.xaxis",
                    title: L10n.welcomePrivacyRow3Title.resolve(lang),
                    detail: L10n.welcomePrivacyRow3Detail.resolve(lang),
                    isLast: true
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(surfaceContainerHigh)
            )
            .padding(.horizontal, 32)
            Spacer()
        }
    }

    private func privacyRow(icon: String, title: String, detail: String, isLast: Bool = false) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(primaryColor)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(onSurface)
                Text(detail)
                    .font(.system(size: 10))
                    .foregroundColor(outline)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) {
            if !isLast {
                Rectangle()
                    .fill(outline.opacity(0.12))
                    .frame(height: 0.5)
                    .padding(.leading, 50)
            }
        }
    }
}
