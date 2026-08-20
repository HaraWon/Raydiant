import SwiftUI

struct ForecastView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedDay: DayForecast?

    var body: some View {
        ZStack {
            GradientBackground(uvIndex: 5, animated: false)

            ScrollView {
                LazyVStack(spacing: 12) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("14-Day Forecast")
                                .font(RaydiantFonts.rounded(26, weight: .bold))
                                .foregroundStyle(.white)
                            Text(appState.cityName)
                                .font(RaydiantFonts.rounded(14, weight: .regular))
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        Spacer()
                        Image(systemName: "calendar")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)
                    .padding(.bottom, 8)

                    if appState.isLoading && appState.forecastData.isEmpty {
                        ForEach(0..<7, id: \.self) { _ in
                            shimmerCard
                                .padding(.horizontal, 20)
                        }
                    } else if appState.forecastData.isEmpty {
                        emptyState
                    } else {
                        ForEach(Array(appState.forecastData.enumerated()), id: \.element.id) { idx, day in
                            Button {
                                selectedDay = day
                                if appState.userProfile.hapticsEnabled { HapticService.light() }
                            } label: {
                                ForecastDayCard(day: day, isToday: idx == 0)
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.bottom, 100)
            }
        }
        .sheet(item: $selectedDay) { day in
            ForecastDetailView(day: day)
        }
        .task { if appState.forecastData.isEmpty { await appState.fetchWeatherForCurrentLocation() } }
    }

    var shimmerCard: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(Color.white.opacity(0.1))
            .frame(height: 80)
            .shimmer()
    }

    var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "cloud.fill")
                .font(.system(size: 44))
                .foregroundStyle(.white.opacity(0.4))
            Text("Forecast not available")
                .font(RaydiantFonts.rounded(16, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
            Button { appState.refresh() } label: {
                Text("Refresh")
                    .font(RaydiantFonts.rounded(14, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Capsule())
            }
        }
        .padding(.top, 40)
    }
}

struct ForecastDetailView: View {
    var day: DayForecast
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            GradientBackground(uvIndex: day.maxUV, animated: true)

            ScrollView {
                VStack(spacing: 20) {
                    // Handle
                    Capsule()
                        .fill(Color.white.opacity(0.4))
                        .frame(width: 36, height: 4)
                        .padding(.top, 12)

                    // Date
                    Text(day.date.dayLabel)
                        .font(RaydiantFonts.rounded(28, weight: .bold))
                        .foregroundStyle(.white)

                    // Score
                    ScoreRing(score: day.glowScore, size: 130, lineWidth: 12)

                    // Labels
                    HStack(spacing: 10) {
                        RiskPill(label: day.glowLabel.rawValue, color: day.glowLabel.color)
                        UVIndexBadge(uvIndex: day.maxUV)
                        RiskPill(label: day.riskLabel, color: day.maxUV.uvRiskColor)
                    }

                    // Advice
                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Summary", systemImage: "text.bubble.fill")
                                .font(RaydiantFonts.rounded(13, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.7))
                            Text(day.advice)
                                .font(RaydiantFonts.rounded(15, weight: .medium))
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.horizontal, 24)

                    // Windows
                    if let bestWindow = day.bestTanWindow {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Tan Windows", systemImage: "clock.sun.fill")
                                    .font(RaydiantFonts.rounded(14, weight: .semibold))
                                    .foregroundStyle(.white)

                                HStack(spacing: 10) {
                                    Image(systemName: "sun.max.fill")
                                        .foregroundStyle(RaydiantColors.yellow)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Best tan window")
                                            .font(RaydiantFonts.rounded(12)).foregroundStyle(.white.opacity(0.65))
                                        Text(bestWindow.formatted)
                                            .font(RaydiantFonts.rounded(16, weight: .semibold)).foregroundStyle(.white)
                                    }
                                }

                                if let sunrise = day.sunrise, let sunset = day.sunset {
                                    Divider().background(Color.white.opacity(0.2))
                                    HStack {
                                        Label(sunrise, format: .dateTime.hour().minute())
                                            .font(RaydiantFonts.rounded(13)).foregroundStyle(.white.opacity(0.6))
                                            .labelStyle(.titleAndIcon)
                                        Spacer()
                                        Label(sunset, format: .dateTime.hour().minute())
                                            .font(RaydiantFonts.rounded(13)).foregroundStyle(.white.opacity(0.6))
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }

                    Button { dismiss() } label: {
                        Text("Close")
                            .font(RaydiantFonts.rounded(15, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.white.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                }
            }
        }
    }
}

// Shimmer effect modifier
extension View {
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.15), .clear],
                        startPoint: .init(x: phase, y: 0.5),
                        endPoint: .init(x: phase + 0.5, y: 0.5)
                    )
                    .blendMode(.overlay)
                }
            )
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 1.5
                }
            }
    }
}
