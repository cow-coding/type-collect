import SwiftUI

struct WelcomeView: View {
    var onComplete: () -> Void

    @State private var currentStep = 0

    // Design tokens (kept inline until a proper redesign)
    private let surface = Color(red: 0.047, green: 0.055, blue: 0.071)
    private let surfaceContainerHigh = Color(red: 0.11, green: 0.125, blue: 0.15)
    private let onSurface = Color(red: 0.886, green: 0.898, blue: 0.937)
    private let outline = Color(red: 0.447, green: 0.459, blue: 0.494)
    private let primaryColor = Color(red: 0.757, green: 0.502, blue: 1.0)
    private let primaryDim = Color(red: 0.612, green: 0.282, blue: 0.918)

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
                    Text(currentStep < totalSteps - 1 ? "다음" : "시작하기")
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
        .frame(width: 480, height: 480)
        .background(surface)
    }

    // MARK: - Step 1: Title

    private var stepTitle: some View {
        VStack(spacing: 16) {
            Spacer()
            Image("MenuBarIcon")
                .resizable()
                .renderingMode(.template)
                .aspectRatio(contentMode: .fit)
                .frame(width: 56, height: 56)
                .foregroundColor(primaryColor)

            Text("TypeVillage")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(onSurface)

            Text("타이핑으로 마을을 키워보세요")
                .font(.system(size: 15))
                .foregroundColor(outline)
            Spacer()
        }
    }

    // MARK: - Step 2: Concept (placeholder — to be redesigned)

    private var stepConcept: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 24)
            Text("키 입력으로 XP 획득")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(onSurface)

            Text("타이핑할수록 마을이 레벨업합니다.\n새로운 건물과 장식이 해금되죠.")
                .font(.system(size: 13))
                .foregroundColor(outline)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            HStack(spacing: 12) {
                conceptEmoji("🌳", label: "Lv.1")
                conceptEmoji("🏠", label: "Lv.5")
                conceptEmoji("🪣", label: "Lv.10")
                conceptEmoji("🌾", label: "Lv.20")
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(surfaceContainerHigh)
            )
            .padding(.horizontal, 32)
        }
    }

    private func conceptEmoji(_ emoji: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(emoji)
                .font(.system(size: 36))
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .tracking(0.5)
                .foregroundColor(primaryColor)
        }
    }

    // MARK: - Step 3: Privacy

    private var stepPrivacy: some View {
        VStack(alignment: .leading, spacing: 16) {
            Spacer()
            HStack(spacing: 10) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 24))
                    .foregroundColor(primaryColor)

                Text("개인정보 보호")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(onSurface)
            }
            .padding(.horizontal, 32)

            Text("TypeVillage는 안심하고 사용할 수 있습니다")
                .font(.system(size: 13))
                .foregroundColor(outline)
                .padding(.horizontal, 32)

            VStack(spacing: 0) {
                privacyRow(
                    icon: "keyboard",
                    title: "키 입력 횟수만 감지",
                    detail: "어떤 키를 눌렀는지, 무엇을 입력했는지는 알 수 없습니다"
                )
                privacyRow(
                    icon: "internaldrive",
                    title: "로컬 저장만 사용",
                    detail: "모든 데이터는 기기에만 저장되며 외부로 전송되지 않습니다"
                )
                privacyRow(
                    icon: "xmark.circle",
                    title: "추적 없음",
                    detail: "분석, 광고, 사용자 추적 기능이 없습니다",
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
                    .fill(outline.opacity(0.1))
                    .frame(height: 0.5)
                    .padding(.leading, 50)
            }
        }
    }
}
