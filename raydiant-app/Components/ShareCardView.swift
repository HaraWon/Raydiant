import SwiftUI

struct ShareCardView: View {
    var data: TodayGlowData

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [RaydiantColors.pink, RaydiantColors.orange, RaydiantColors.yellow],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Content
            VStack(spacing: 16) {
                // Logo + title
                HStack(spacing: 10) {
                    RaydiantLogoView(size: 32)
                    Text("Raydiant")
                        .font(RaydiantFonts.rounded(22, weight: .bold))
                        .foregroundStyle(.white)
                    Spacer()
                    Text("Your UV, for you.")
                        .font(RaydiantFonts.rounded(11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                }

                Divider().background(Color.white.opacity(0.3))

                // City + score
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(data.cityName)
                            .font(RaydiantFonts.rounded(26, weight: .bold))
                            .foregroundStyle(.white)
                        Text(data.glowLabel.rawValue)
                            .font(RaydiantFonts.rounded(14, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.85))
                        Text(data.glowAdvice)
                            .font(RaydiantFonts.rounded(12, weight: .regular))
                            .foregroundStyle(.white.opacity(0.75))
                            .lineLimit(2)
                    }
                    Spacer()
                    ScoreRing(score: data.glowScore, size: 90, lineWidth: 9, animate: false)
                }

                // Best window
                if let window = data.bestTanWindow {
                    HStack {
                        Image(systemName: "sun.max.fill")
                            .foregroundStyle(RaydiantColors.yellow)
                        Text("Best glow: \(window.formatted)")
                            .font(RaydiantFonts.rounded(13, weight: .semibold))
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(24)
        }
        .frame(width: 340, height: 220)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 8)
    }

    var shareText: String {
        var text = "\(data.cityName) is \(data.glowScore)/100 on Raydiant today ☀️"
        if let window = data.bestTanWindow {
            text += " Best glow window: \(window.formatted)."
        }
        text += " Your UV, for you. — raydiant.app"
        return text
    }
}
