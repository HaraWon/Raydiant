import SwiftUI

struct ScoreRing: View {
    var score: Int
    var size: CGFloat = 140
    var lineWidth: CGFloat = 12
    var animate: Bool = true

    @State private var displayScore: Int = 0
    @State private var ringProgress: Double = 0

    private var progress: Double { Double(score) / 100.0 }

    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: lineWidth)
                .frame(width: size, height: size)

            // Filled arc
            Circle()
                .trim(from: 0, to: ringProgress)
                .stroke(
                    LinearGradient(
                        colors: [RaydiantColors.yellow, RaydiantColors.orange, RaydiantColors.pink],
                        startPoint: .topTrailing,
                        endPoint: .bottomLeading
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))

            // Score label
            VStack(spacing: 2) {
                Text("\(displayScore)")
                    .font(RaydiantFonts.rounded(size * 0.28, weight: .bold))
                    .foregroundStyle(.white)
                Text("/ 100")
                    .font(RaydiantFonts.rounded(size * 0.1, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .onAppear { startAnimation() }
        .onChange(of: score) { startAnimation() }
    }

    private func startAnimation() {
        guard animate else {
            displayScore = score
            ringProgress = progress
            return
        }
        displayScore = 0
        ringProgress = 0
        withAnimation(.easeOut(duration: 1.2)) {
            ringProgress = progress
        }
        // Count-up number
        let steps = score
        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * (1.1 / Double(max(1, steps)))) {
                displayScore = i
            }
        }
    }
}

struct SmallScoreRing: View {
    var score: Int
    var size: CGFloat = 52
    var lineWidth: CGFloat = 5

    @State private var progress: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(colors: [RaydiantColors.yellow, RaydiantColors.orange], startPoint: .top, endPoint: .bottom),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            Text("\(score)")
                .font(RaydiantFonts.rounded(size * 0.3, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                progress = Double(score) / 100.0
            }
        }
    }
}
