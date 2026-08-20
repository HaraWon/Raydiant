import SwiftUI

struct RaydiantLogoView: View {
    var size: CGFloat = 60
    var animate: Bool = false

    @State private var pulseScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.5

    var body: some View {
        ZStack {
            // Glow pulse
            if animate {
                Circle()
                    .fill(RaydiantColors.orange.opacity(glowOpacity))
                    .frame(width: size * 1.3, height: size * 1.3)
                    .blur(radius: size * 0.3)
                    .scaleEffect(pulseScale)
            }

            // Background circle with gradient
            Circle()
                .fill(
                    LinearGradient(
                        colors: [RaydiantColors.pink, RaydiantColors.orange, RaydiantColors.yellow],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .shadow(color: RaydiantColors.orange.opacity(0.4), radius: size * 0.2, x: 0, y: 4)

            // Sun/spark icon
            Image(systemName: "sparkle")
                .font(.system(size: size * 0.45, weight: .bold))
                .foregroundStyle(.white)
        }
        .onAppear {
            guard animate else { return }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulseScale = 1.15
                glowOpacity = 0.2
            }
        }
    }
}

struct SunPulseIcon: View {
    var size: CGFloat = 40
    @State private var scale: CGFloat = 1.0

    var body: some View {
        ZStack {
            ForEach(0..<3) { i in
                Circle()
                    .stroke(Color.white.opacity(0.15 - Double(i) * 0.04), lineWidth: 1.5)
                    .frame(width: size + CGFloat(i) * 18, height: size + CGFloat(i) * 18)
                    .scaleEffect(scale)
                    .animation(
                        .easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(Double(i) * 0.3),
                        value: scale
                    )
            }
            Image(systemName: "sun.max.fill")
                .font(.system(size: size * 0.7))
                .foregroundStyle(
                    LinearGradient(colors: [RaydiantColors.yellow, RaydiantColors.orange], startPoint: .top, endPoint: .bottom)
                )
                .shadow(color: RaydiantColors.orange.opacity(0.5), radius: 8)
        }
        .onAppear { scale = 1.08 }
    }
}
