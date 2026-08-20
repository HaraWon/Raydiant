import SwiftUI

struct TodayView: View {
    @EnvironmentObject var appState: AppState
    @State private var spfAppliedAt: Date? = nil
    @State private var showShareSheet = false
    @State private var showShareCard = false
    @State private var expandedCards: Set<String> = []

    var body: some View {
        ZStack {
            GradientBackground(uvIndex: appState.todayData?.currentUV ?? 5, animated: true)

            if appState.isLoading && appState.todayData == nil {
                loadingView
            } else if let data = appState.todayData {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Header
                        headerView(data: data)
                            .padding(.horizontal, 20)
                            .padding(.top, 60)

                        // Error banner
                        if let err = appState.errorMessage {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.yellow)
                                Text(err)
                                    .font(RaydiantFonts.rounded(12))
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                            .padding(12)
                            .background(Color.black.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal, 20)
                        }

                        // Hero card
                        heroCard(data: data)
                            .padding(.horizontal, 20)

                        // UV Graph card
                        uvGraphCard(data: data)
                            .padding(.horizontal, 20)

                        // Tan Window card
                        tanWindowCard(data: data)
                            .padding(.horizontal, 20)

                        // Sunscreen timer
                        TimerCard(
                            uvIndex: data.currentUV,
                            appliedAt: $spfAppliedAt,
                            hapticsEnabled: appState.userProfile.hapticsEnabled
                        )
                        .padding(.horizontal, 20)

                        // Expandable cards header
                        HStack {
                            Text("More insights")
                                .font(RaydiantFonts.rounded(16, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.85))
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 4)

                        // Expandable section
                        LazyVStack(spacing: 12) {
                            expandableCard(id: "burn", title: "Burn Risk", icon: "flame.fill") {
                                burnRiskContent(data: data)
                            }
                            expandableCard(id: "hyperpig", title: "Hyperpigmentation Risk", icon: "circle.lefthalf.filled") {
                                riskContent(label: data.hyperpigmentationRisk.rawValue, color: data.hyperpigmentationRisk.color, advice: data.hyperpigmentationAdvice)
                            }
                            expandableCard(id: "makeup", title: "Makeup Survival", icon: "drop.fill") {
                                simpleContent(label: data.makeupSurvival, advice: data.makeupAdvice, icon: "drop.fill")
                            }
                            expandableCard(id: "hair", title: "Hair Frizz", icon: "wind") {
                                simpleContent(label: data.hairFrizzRisk, advice: data.hairFrizzAdvice, icon: "wind")
                            }
                            expandableCard(id: "sweat", title: "Sweatiness", icon: "thermometer.medium") {
                                simpleContent(label: data.sweatinessLevel, advice: data.sweatinessAdvice, icon: "thermometer.medium")
                            }
                            expandableCard(id: "beach", title: "Beach Day Score", icon: "beach.umbrella.fill") {
                                beachContent(data: data)
                            }
                            if let photoWindow = data.photoWindow {
                                expandableCard(id: "photo", title: "Golden Hour Photo Window", icon: "camera.fill") {
                                    photoContent(window: photoWindow)
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        // Last updated
                        Text("Updated \(data.lastUpdated, style: .relative) ago")
                            .font(RaydiantFonts.rounded(11, weight: .regular))
                            .foregroundStyle(.white.opacity(0.4))
                            .padding(.vertical, 16)
                    }
                    .padding(.bottom, 100)
                }
                .refreshable { appState.refresh() }
            } else {
                emptyState
            }

            // Share card overlay
            if showShareCard, let data = appState.todayData {
                shareCardOverlay(data: data)
            }
        }
        .task { if appState.todayData == nil { await appState.fetchWeatherForCurrentLocation() } }
        .sheet(isPresented: $showShareSheet) {
            if let data = appState.todayData {
                ShareSheet(text: ShareCardView(data: data).shareText)
            }
        }
    }

    // MARK: – Header

    func headerView(data: TodayGlowData) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(data.cityName)
                    .font(RaydiantFonts.rounded(22, weight: .bold))
                    .foregroundStyle(.white)
                Text(Date(), style: .date)
                    .font(RaydiantFonts.rounded(13, weight: .regular))
                    .foregroundStyle(.white.opacity(0.65))
            }
            Spacer()
            Button {
                if appState.userProfile.hapticsEnabled { HapticService.light() }
                showShareCard = true
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }
        }
    }

    // MARK: – Hero Card

    func heroCard(data: TodayGlowData) -> some View {
        GlassCard {
            HStack(alignment: .center, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        RiskPill(label: data.glowLabel.rawValue, color: data.glowLabel.color)
                        UVIndexBadge(uvIndex: data.currentUV)
                    }
                    Text(data.glowAdvice)
                        .font(RaydiantFonts.rounded(14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.88))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                ScoreRing(score: data.glowScore, size: 110, lineWidth: 10)
            }
        }
    }

    // MARK: – UV Graph

    func uvGraphCard(data: TodayGlowData) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label("UV Today", systemImage: "sun.max.fill")
                        .font(RaydiantFonts.rounded(14, weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                    RiskPill(label: "UV: \(GlowScoreCalculator.uvRiskLabel(for: data.currentUV))", color: data.currentUV.uvRiskColor)
                }
                if !data.hourlyUV.isEmpty {
                    UVGraphView(hourlyUV: data.hourlyUV, height: 110)
                        .padding(.top, 4)
                        .padding(.bottom, 18)
                } else {
                    Text("UV graph not available")
                        .font(RaydiantFonts.rounded(13))
                        .foregroundStyle(.white.opacity(0.5))
                }
                HStack(spacing: 6) {
                    Image(systemName: "square.fill").foregroundStyle(.red.opacity(0.4)).font(.system(size: 9))
                    Text("Danger zone (UV 8+)")
                        .font(RaydiantFonts.rounded(11)).foregroundStyle(.white.opacity(0.5))
                    Spacer()
                    Image(systemName: "rectangle.fill").foregroundStyle(.white.opacity(0.4)).font(.system(size: 9))
                    Text("Current hour")
                        .font(RaydiantFonts.rounded(11)).foregroundStyle(.white.opacity(0.5))
                }
            }
        }
    }

    // MARK: – Tan Window

    func tanWindowCard(data: TodayGlowData) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Label("Tan Windows", systemImage: "clock.sun.fill")
                    .font(RaydiantFonts.rounded(14, weight: .semibold))
                    .foregroundStyle(.white)

                VStack(spacing: 10) {
                    if let best = data.bestTanWindow {
                        windowRow(icon: "sun.max.fill", color: RaydiantColors.yellow, label: "Best tan window", value: best.formatted)
                    }
                    if let lower = data.lowerRiskWindow {
                        windowRow(icon: "sun.min.fill", color: RaydiantColors.orange, label: "Lower-risk glow window", value: lower.formatted)
                    }
                    if let avoid = data.avoidWindow {
                        windowRow(icon: "exclamationmark.triangle.fill", color: .red.opacity(0.8), label: "Avoid direct sun", value: avoid.formatted)
                    }
                    if data.bestTanWindow == nil && data.lowerRiskWindow == nil {
                        Text("No significant UV today — great day for sensitive skin.")
                            .font(RaydiantFonts.rounded(13)).foregroundStyle(.white.opacity(0.7))
                    }
                }
            }
        }
    }

    func windowRow(icon: String, color: Color, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(RaydiantFonts.rounded(12, weight: .regular))
                    .foregroundStyle(.white.opacity(0.65))
                Text(value)
                    .font(RaydiantFonts.rounded(15, weight: .semibold))
                    .foregroundStyle(.white)
            }
            Spacer()
        }
    }

    // MARK: – Expandable Cards

    func expandableCard<Content: View>(id: String, title: String, icon: String, @ViewBuilder content: @escaping () -> Content) -> some View {
        let isExpanded = expandedCards.contains(id)
        return GlassCard(padding: 14) {
            VStack(spacing: 12) {
                Button {
                    if appState.userProfile.hapticsEnabled { HapticService.light() }
                    withAnimation(.spring(duration: 0.3)) {
                        if isExpanded { expandedCards.remove(id) } else { expandedCards.insert(id) }
                    }
                } label: {
                    HStack {
                        Label(title, systemImage: icon)
                            .font(RaydiantFonts.rounded(14, weight: .semibold))
                            .foregroundStyle(.white)
                        Spacer()
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }

                if isExpanded {
                    content()
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }

    func burnRiskContent(data: TodayGlowData) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                RiskPill(label: data.burnRisk.label, color: data.currentUV.uvRiskColor)
                Text(data.burnRisk.rangeText)
                    .font(RaydiantFonts.rounded(15, weight: .bold))
                    .foregroundStyle(.white)
            }
            Text(data.burnRisk.message)
                .font(RaydiantFonts.rounded(13)).foregroundStyle(.white.opacity(0.75))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    func riskContent(label: String, color: Color, advice: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            RiskPill(label: label, color: color)
            Text(advice)
                .font(RaydiantFonts.rounded(13)).foregroundStyle(.white.opacity(0.75))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    func simpleContent(label: String, advice: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(RaydiantFonts.rounded(16, weight: .bold)).foregroundStyle(.white)
            Text(advice)
                .font(RaydiantFonts.rounded(13)).foregroundStyle(.white.opacity(0.75))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    func beachContent(data: TodayGlowData) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .bottom, spacing: 6) {
                Text("\(data.beachDayScore)")
                    .font(RaydiantFonts.rounded(28, weight: .bold)).foregroundStyle(.white)
                Text("/ 100")
                    .font(RaydiantFonts.rounded(14)).foregroundStyle(.white.opacity(0.6))
                    .padding(.bottom, 4)
            }
            Text(data.beachDayAdvice)
                .font(RaydiantFonts.rounded(13)).foregroundStyle(.white.opacity(0.75))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    func photoContent(window: TimeWindow) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(window.formatted)
                .font(RaydiantFonts.rounded(18, weight: .bold)).foregroundStyle(.white)
            Text("Golden hour — soft directional light and warm tones. Perfect for outdoor photos.")
                .font(RaydiantFonts.rounded(13)).foregroundStyle(.white.opacity(0.75))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: – Share Overlay

    func shareCardOverlay(data: TodayGlowData) -> some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { showShareCard = false }

            VStack(spacing: 20) {
                ShareCardView(data: data)
                HStack(spacing: 16) {
                    Button { showShareCard = false } label: {
                        Text("Done")
                            .font(RaydiantFonts.rounded(16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.white.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    Button {
                        showShareCard = false
                        showShareSheet = true
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .font(RaydiantFonts.rounded(16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(LinearGradient(colors: [RaydiantColors.pink, RaydiantColors.orange], startPoint: .leading, endPoint: .trailing))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.2), value: showShareCard)
    }

    // MARK: – Loading / Empty

    var loadingView: some View {
        VStack(spacing: 24) {
            SunPulseIcon(size: 60)
            Text("Finding your glow...")
                .font(RaydiantFonts.rounded(18, weight: .semibold))
                .foregroundStyle(.white)
        }
    }

    var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 44))
                .foregroundStyle(.white.opacity(0.5))
            Text("Couldn't load data")
                .font(RaydiantFonts.rounded(18, weight: .semibold))
                .foregroundStyle(.white)
            Button { appState.refresh() } label: {
                Text("Try again")
                    .font(RaydiantFonts.rounded(15, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Capsule())
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var text: String

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [text], applicationActivities: nil)
    }

    func updateUIViewController(_ uvc: UIActivityViewController, context: Context) {}
}
