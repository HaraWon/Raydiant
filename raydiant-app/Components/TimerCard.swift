import SwiftUI

struct TimerCard: View {
    var uvIndex: Double
    @Binding var appliedAt: Date?
    var hapticsEnabled: Bool

    @State private var now = Date()
    private let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    private var reapplyMinutes: Int {
        SunscreenCalculator.reapplyMinutes(uvIndex: uvIndex, isBeachMode: false, isSwimming: false)
    }

    private var minutesRemaining: Int {
        guard let applied = appliedAt else { return reapplyMinutes }
        let elapsed = Int(now.timeIntervalSince(applied) / 60)
        return max(0, reapplyMinutes - elapsed)
    }

    private var progress: Double {
        guard appliedAt != nil else { return 1.0 }
        return Double(minutesRemaining) / Double(reapplyMinutes)
    }

    private var urgency: Color {
        if minutesRemaining <= 0 { return .red }
        if minutesRemaining <= 20 { return RaydiantColors.orange }
        return RaydiantColors.yellow
    }

    var body: some View {
        GlassCard {
            VStack(spacing: 14) {
                HStack {
                    Label("Sunscreen Timer", systemImage: "clock.fill")
                        .font(RaydiantFonts.rounded(14, weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                    RiskPill(label: SunscreenCalculator.urgencyMessage(uvIndex: uvIndex), color: urgency)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 10)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(LinearGradient(colors: [RaydiantColors.yellow, urgency], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * progress, height: 10)
                            .animation(.easeOut(duration: 0.5), value: progress)
                    }
                }
                .frame(height: 10)

                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(appliedAt == nil ? "Tap when you apply SPF" : SunscreenCalculator.reapplyMessage(minutesRemaining: minutesRemaining, uvIndex: uvIndex))
                            .font(RaydiantFonts.rounded(18, weight: .bold))
                            .foregroundStyle(.white)
                        if let applied = appliedAt {
                            Text("Applied at \(applied, style: .time)")
                                .font(RaydiantFonts.rounded(12, weight: .regular))
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                    Spacer()

                    Button {
                        if hapticsEnabled { HapticService.success() }
                        appliedAt = Date()
                        NotificationService.scheduleSunscreenReminder(in: reapplyMinutes)
                    } label: {
                        Text(appliedAt == nil ? "I applied SPF" : "Reapplied!")
                            .font(RaydiantFonts.rounded(13, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(
                                Capsule()
                                    .fill(LinearGradient(colors: [RaydiantColors.orange, RaydiantColors.pink], startPoint: .leading, endPoint: .trailing))
                            )
                    }
                }
            }
        }
        .onReceive(timer) { now = $0 }
    }
}
