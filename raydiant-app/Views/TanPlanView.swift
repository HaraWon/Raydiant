import SwiftUI

enum TanPlanGoal: String, CaseIterable {
    case tan = "I want to tan"
    case lowerRisk = "Lower-risk tan"
    case photos = "Outdoor photos"
    case avoidBurn = "Avoid burning"
    case beach = "I'm going to the beach"

    var icon: String {
        switch self {
        case .tan: return "sun.max.fill"
        case .lowerRisk: return "sun.min.fill"
        case .photos: return "camera.fill"
        case .avoidBurn: return "shield.fill"
        case .beach: return "beach.umbrella.fill"
        }
    }
}

struct TanPlanView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedGoal: TanPlanGoal? = nil
    @State private var showPlan = false

    var plan: TanPlanResult? {
        guard let goal = selectedGoal, let data = appState.todayData else { return nil }
        return buildPlan(for: goal, data: data)
    }

    var body: some View {
        ZStack {
            GradientBackground(uvIndex: appState.todayData?.currentUV ?? 5, animated: true)

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "sparkles")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundStyle(LinearGradient(colors: [RaydiantColors.yellow, RaydiantColors.orange], startPoint: .top, endPoint: .bottom))
                            Text("Tan Plan")
                                .font(RaydiantFonts.rounded(28, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        Text("What's your goal today?")
                            .font(RaydiantFonts.rounded(15, weight: .regular))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .padding(.top, 60)

                    // Goal selection
                    VStack(spacing: 10) {
                        ForEach(TanPlanGoal.allCases, id: \.self) { goal in
                            OnboardingOptionButton(
                                label: goal.rawValue,
                                icon: goal.icon,
                                isSelected: selectedGoal == goal
                            ) {
                                if appState.userProfile.hapticsEnabled { HapticService.medium() }
                                withAnimation(.spring(duration: 0.3)) {
                                    selectedGoal = goal
                                    showPlan = true
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)

                    // Plan result
                    if showPlan, let plan = plan {
                        planResultView(plan: plan)
                            .padding(.horizontal, 24)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding(.bottom, 100)
            }
        }
    }

    @ViewBuilder
    func planResultView(_ plan: TanPlanResult) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                // Goal label
                HStack {
                    Image(systemName: selectedGoal?.icon ?? "sparkles")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(RaydiantColors.yellow)
                    Text(plan.goalLabel)
                        .font(RaydiantFonts.rounded(16, weight: .bold))
                        .foregroundStyle(.white)
                }

                Divider().background(Color.white.opacity(0.2))

                // Best time
                VStack(alignment: .leading, spacing: 4) {
                    Text("Best time today")
                        .font(RaydiantFonts.rounded(12, weight: .regular))
                        .foregroundStyle(.white.opacity(0.6))
                    Text(plan.bestTime)
                        .font(RaydiantFonts.rounded(22, weight: .bold))
                        .foregroundStyle(.white)
                }

                // Best day this week
                VStack(alignment: .leading, spacing: 4) {
                    Text("Best day this week")
                        .font(RaydiantFonts.rounded(12, weight: .regular))
                        .foregroundStyle(.white.opacity(0.6))
                    Text(plan.bestDay)
                        .font(RaydiantFonts.rounded(16, weight: .semibold))
                        .foregroundStyle(RaydiantColors.yellow)
                }

                Divider().background(Color.white.opacity(0.2))

                // What to bring
                VStack(alignment: .leading, spacing: 8) {
                    Text("What to bring")
                        .font(RaydiantFonts.rounded(13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.7))
                    ForEach(plan.whatToBring, id: \.self) { item in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(RaydiantColors.yellow)
                            Text(item)
                                .font(RaydiantFonts.rounded(14))
                                .foregroundStyle(.white.opacity(0.85))
                        }
                    }
                }

                // Risk warning
                if !plan.riskWarning.isEmpty {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(RaydiantColors.orange)
                        Text(plan.riskWarning)
                            .font(RaydiantFonts.rounded(13))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .padding(12)
                    .background(Color.orange.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                // SPF advice
                Text(plan.spfAdvice)
                    .font(RaydiantFonts.rounded(13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
                    .italic()

                // Body copy
                Text(plan.bodyCopy)
                    .font(RaydiantFonts.rounded(14))
                    .foregroundStyle(.white.opacity(0.75))
                    .padding(.top, 2)
            }
        }
    }

    private func buildPlan(for goal: TanPlanGoal, data: TodayGlowData) -> TanPlanResult {
        let bestTime: String
        switch goal {
        case .tan:
            bestTime = data.bestTanWindow?.formatted ?? "Morning hours — check the UV graph"
        case .lowerRisk, .avoidBurn:
            bestTime = data.lowerRiskWindow?.formatted ?? data.bestTanWindow?.formatted ?? "Early morning or late afternoon"
        case .photos:
            bestTime = data.photoWindow?.formatted ?? "Golden hour near sunset"
        case .beach:
            bestTime = data.bestTanWindow?.formatted ?? "Morning and late afternoon"
        }

        let bestDay: String
        if let best = appState.forecastData.max(by: { $0.glowScore < $1.glowScore }) {
            bestDay = best.date.dayLabel
        } else {
            bestDay = "Today"
        }

        let bring: [String]
        switch goal {
        case .tan: bring = ["SPF 30+", "Water bottle", "Sunglasses", "Tanning oil (optional)"]
        case .lowerRisk: bring = ["SPF 50+", "Hat or cap", "Light cover-up", "Water bottle"]
        case .avoidBurn: bring = ["SPF 50+", "Wide-brim hat", "Lightweight long sleeves", "Shade options"]
        case .photos: bring = ["Camera or phone", "Light reflector (optional)", "Water bottle", "SPF 30+"]
        case .beach: bring = ["SPF 50+ water-resistant", "Shade (umbrella)", "Water and snacks", "Sunglasses", "After-sun lotion"]
        }

        let riskWarning: String
        if data.currentUV >= 8 {
            riskWarning = "UV is very high today — even brief exposure without protection can cause burning."
        } else if data.currentUV >= 5 {
            riskWarning = "Moderate-to-high UV. Reapply SPF every 2 hours."
        } else {
            riskWarning = ""
        }

        let spf: String
        switch goal {
        case .tan: spf = "SPF 30 minimum — reapply every 2 hours."
        case .lowerRisk, .avoidBurn: spf = "SPF 50+ is your best protection today."
        case .photos: spf = "SPF 30 for golden hour — UV is lower but still present."
        case .beach: spf = "Water-resistant SPF 50+ — reapply after swimming or sweating."
        }

        let body: String
        switch goal {
        case .tan:
            body = "Your best tan plan is \(bestTime). Reapply SPF to maintain protection, and take shade breaks during peak UV hours."
        case .lowerRisk:
            body = "Your lower-risk glow window is \(bestTime). Early morning and late afternoon UV is effective but kinder to your skin."
        case .avoidBurn:
            body = "Stick to \(bestTime) for outdoor time. Avoid the midday UV spike and keep SPF topped up."
        case .photos:
            body = "Catch the golden hour at \(bestTime) — soft, directional light that's flattering and lower-risk. Perfect for photos."
        case .beach:
            body = "Best beach windows are \(bestTime). Bring a shade option for midday and keep SPF reapplied, especially after the water."
        }

        return TanPlanResult(
            goalLabel: goal.rawValue,
            bestTime: bestTime,
            bestDay: bestDay,
            whatToBring: bring,
            riskWarning: riskWarning,
            spfAdvice: spf,
            bodyCopy: body
        )
    }
}
