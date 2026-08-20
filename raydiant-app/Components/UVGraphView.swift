import SwiftUI

struct UVGraphView: View {
    var hourlyUV: [(hour: Int, uv: Double)]
    var height: CGFloat = 110

    private var maxUV: Double { max(hourlyUV.map(\.uv).max() ?? 1, 1) }
    private var currentHour: Int { Calendar.current.component(.hour, from: Date()) }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                // Gradient fill under curve
                areaShape(width: geo.size.width, height: geo.size.height)
                    .fill(
                        LinearGradient(
                            colors: [
                                RaydiantColors.orange.opacity(0.7),
                                RaydiantColors.pink.opacity(0.3),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                // Curve line
                lineShape(width: geo.size.width, height: geo.size.height)
                    .stroke(
                        LinearGradient(
                            colors: [RaydiantColors.yellow, RaydiantColors.orange, RaydiantColors.pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
                    )

                // Danger zone shading (UV >= 8)
                dangerOverlay(width: geo.size.width, height: geo.size.height)
                    .fill(Color.red.opacity(0.12))

                // Current hour indicator
                currentHourLine(width: geo.size.width, height: geo.size.height)

                // Hour labels
                hourLabels(width: geo.size.width, height: geo.size.height)
            }
        }
        .frame(height: height)
    }

    private var daytimePoints: [(hour: Int, uv: Double)] {
        hourlyUV.filter { $0.uv > 0 || ($0.hour >= 5 && $0.hour <= 20) }
    }

    private func xPosition(for hour: Int, width: CGFloat) -> CGFloat {
        let totalHours = 24.0
        return CGFloat(hour) / totalHours * width
    }

    private func yPosition(for uv: Double, height: CGFloat) -> CGFloat {
        let margin: CGFloat = 8
        return height - margin - CGFloat(uv / maxUV) * (height - margin * 2)
    }

    private func lineShape(width: CGFloat, height: CGFloat) -> Path {
        var path = Path()
        let points = hourlyUV.sorted { $0.hour < $1.hour }
        guard !points.isEmpty else { return path }

        path.move(to: CGPoint(x: xPosition(for: points[0].hour, width: width),
                              y: yPosition(for: points[0].uv, height: height)))
        for point in points.dropFirst() {
            path.addLine(to: CGPoint(x: xPosition(for: point.hour, width: width),
                                     y: yPosition(for: point.uv, height: height)))
        }
        return path
    }

    private func areaShape(width: CGFloat, height: CGFloat) -> Path {
        var path = lineShape(width: width, height: height)
        let sorted = hourlyUV.sorted { $0.hour < $1.hour }
        guard let last = sorted.last, let first = sorted.first else { return path }

        path.addLine(to: CGPoint(x: xPosition(for: last.hour, width: width), y: height))
        path.addLine(to: CGPoint(x: xPosition(for: first.hour, width: width), y: height))
        path.closeSubpath()
        return path
    }

    private func dangerOverlay(width: CGFloat, height: CGFloat) -> Path {
        var path = Path()
        let dangerPoints = hourlyUV.sorted { $0.hour < $1.hour }.filter { $0.uv >= 8 }
        guard !dangerPoints.isEmpty else { return path }

        let first = dangerPoints.first!
        let last = dangerPoints.last!
        let x1 = xPosition(for: first.hour, width: width)
        let x2 = xPosition(for: last.hour + 1, width: width)
        path.addRect(CGRect(x: x1, y: 0, width: x2 - x1, height: height))
        return path
    }

    private func currentHourLine(width: CGFloat, height: CGFloat) -> some View {
        let x = xPosition(for: currentHour, width: width)
        return Rectangle()
            .fill(Color.white.opacity(0.5))
            .frame(width: 1.5, height: height)
            .offset(x: x - width / 2)
    }

    private func hourLabels(width: CGFloat, height: CGFloat) -> some View {
        ForEach([6, 9, 12, 15, 18], id: \.self) { hour in
            let x = xPosition(for: hour, width: width)
            Text(hourLabel(hour))
                .font(RaydiantFonts.rounded(9, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))
                .position(x: x, y: height + 10)
        }
    }

    private func hourLabel(_ hour: Int) -> String {
        if hour == 12 { return "12PM" }
        if hour < 12 { return "\(hour)AM" }
        return "\(hour - 12)PM"
    }
}
