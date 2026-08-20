import SwiftUI

struct ForecastDayCard: View {
    var day: DayForecast
    var isToday: Bool

    var body: some View {
        GlassCard(cornerRadius: 18, padding: 14) {
            HStack(spacing: 14) {
                // Date column
                VStack(spacing: 2) {
                    Text(day.date.shortDayLabel)
                        .font(RaydiantFonts.rounded(12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.8))
                    if isToday {
                        Text("Today")
                            .font(RaydiantFonts.rounded(10, weight: .medium))
                            .foregroundStyle(RaydiantColors.yellow)
                    }
                }
                .frame(width: 48)

                // Score ring
                SmallScoreRing(score: day.glowScore, size: 46, lineWidth: 5)

                // Main info
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        RiskPill(label: day.glowLabel.rawValue, color: day.glowLabel.color)
                        UVIndexBadge(uvIndex: day.maxUV)
                    }
                    Text(day.advice)
                        .font(RaydiantFonts.rounded(12, weight: .regular))
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(1)
                    if let window = day.bestTanWindow {
                        Text("Best: \(window.formatted)")
                            .font(RaydiantFonts.rounded(11, weight: .medium))
                            .foregroundStyle(RaydiantColors.yellow)
                    }
                }
                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
    }
}
