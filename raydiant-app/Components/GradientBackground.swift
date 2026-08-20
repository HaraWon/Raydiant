import SwiftUI

struct GradientBackground: View {
    var uvIndex: Double = 5
    var animated: Bool = true

    @State private var phase: Double = 0

    private var colors: [Color] {
        RaydiantColors.gradient(for: Date().hourInt, uvIndex: uvIndex)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: colors,
                startPoint: animated ? .init(x: 0.2 + 0.1 * sin(phase), y: 0) : .topLeading,
                endPoint: animated ? .init(x: 0.8 + 0.1 * cos(phase), y: 1) : .bottomTrailing
            )
            .ignoresSafeArea()

            // Soft overlay orbs for depth
            GeometryReader { geo in
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: geo.size.width * 0.7)
                    .offset(x: -geo.size.width * 0.2, y: -geo.size.height * 0.1)
                    .blur(radius: 40)

                Circle()
                    .fill(Color.white.opacity(0.06))
                    .frame(width: geo.size.width * 0.5)
                    .offset(x: geo.size.width * 0.5, y: geo.size.height * 0.5)
                    .blur(radius: 50)
            }
            .ignoresSafeArea()
        }
        .onAppear {
            guard animated else { return }
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                phase = .pi
            }
        }
    }
}
