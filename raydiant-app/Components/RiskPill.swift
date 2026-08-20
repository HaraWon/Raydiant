import SwiftUI

struct RiskPill: View {
    var label: String
    var color: Color

    var body: some View {
        Text(label)
            .font(RaydiantFonts.rounded(12, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule().fill(color.opacity(0.85))
            )
    }
}

struct UVIndexBadge: View {
    var uvIndex: Double

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 11, weight: .semibold))
            Text(String(format: "UV %.1f", uvIndex))
                .font(RaydiantFonts.rounded(12, weight: .semibold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Capsule().fill(uvIndex.uvRiskColor.opacity(0.85)))
    }
}
