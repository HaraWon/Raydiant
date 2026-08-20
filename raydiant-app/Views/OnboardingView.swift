import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentStep = 0
    @State private var searchText = ""
    @State private var cityResults: [GeocodingResult] = []
    @State private var isSearching = false
    @State private var locationDenied = false

    private let totalSteps = 6
    private let weatherService = WeatherService()

    var body: some View {
        ZStack {
            GradientBackground(uvIndex: 6, animated: true)

            VStack(spacing: 0) {
                // Progress bar
                if currentStep > 0 {
                    ProgressBar(current: currentStep, total: totalSteps - 1)
                        .padding(.horizontal, 24)
                        .padding(.top, 60)
                        .transition(.opacity)
                }

                // Step content
                Group {
                    switch currentStep {
                    case 0: stepWelcome
                    case 1: stepGoal
                    case 2: stepSkinTone
                    case 3: stepExperience
                    case 4: stepConcerns
                    case 5: stepLocation
                    default: EmptyView()
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .id(currentStep)

                Spacer()
            }
        }
        .animation(.spring(duration: 0.4), value: currentStep)
    }

    // MARK: – Step 0: Welcome
    var stepWelcome: some View {
        VStack(spacing: 32) {
            Spacer()
            RaydiantLogoView(size: 90, animate: true)
            VStack(spacing: 10) {
                Text("Welcome to Raydiant")
                    .font(RaydiantFonts.rounded(34, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                Text("Your UV, for you.")
                    .font(RaydiantFonts.rounded(18, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(.horizontal, 32)

            Text("Smart UV tracking, tan windows, and beauty insights — personalized for you.")
                .font(RaydiantFonts.rounded(15, weight: .regular))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()

            Button { advance() } label: {
                Text("Get started")
                    .font(RaydiantFonts.rounded(18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.white.opacity(0.25))
                            .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.white.opacity(0.5), lineWidth: 1))
                    )
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 50)
        }
    }

    // MARK: – Step 1: Goal
    var stepGoal: some View {
        OnboardingStepWrapper(title: "What's your goal?", subtitle: "We'll personalise your experience around this.") {
            VStack(spacing: 12) {
                ForEach(Goal.allCases, id: \.self) { goal in
                    OnboardingOptionButton(
                        label: goal.rawValue,
                        icon: goal.icon,
                        isSelected: appState.userProfile.goal == goal
                    ) {
                        appState.userProfile.goal = goal
                        if appState.userProfile.hapticsEnabled { HapticService.light() }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { advance() }
                    }
                }
            }
        }
    }

    // MARK: – Step 2: Skin Tone
    var stepSkinTone: some View {
        OnboardingStepWrapper(title: "Your skin profile", subtitle: "This helps estimate burn time and risk. No stereotypes — just skin science.") {
            VStack(spacing: 10) {
                VStack(spacing: 8) {
                    ForEach(SkinTone.allCases, id: \.self) { tone in
                        OnboardingOptionButton(
                            label: tone.rawValue,
                            isSelected: appState.userProfile.skinTone == tone
                        ) {
                            appState.userProfile.skinTone = tone
                            if appState.userProfile.hapticsEnabled { HapticService.light() }
                        }
                    }
                }
                .padding(.bottom, 6)

                // Burn tendency
                Text("How easily do you burn?")
                    .font(RaydiantFonts.rounded(15, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.85))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)

                VStack(spacing: 8) {
                    ForEach(BurnTendency.allCases, id: \.self) { burn in
                        OnboardingOptionButton(
                            label: burn.rawValue,
                            isSelected: appState.userProfile.burnTendency == burn
                        ) {
                            appState.userProfile.burnTendency = burn
                            if appState.userProfile.hapticsEnabled { HapticService.light() }
                        }
                    }
                }
            }

            nextButton()
        }
    }

    // MARK: – Step 3: Experience
    var stepExperience: some View {
        OnboardingStepWrapper(title: "Tanning experience?", subtitle: "Helps us give you the right advice for where you're at.") {
            VStack(spacing: 12) {
                ForEach(TanningExperience.allCases, id: \.self) { exp in
                    OnboardingOptionButton(
                        label: exp.rawValue,
                        icon: exp.icon,
                        isSelected: appState.userProfile.tanningExperience == exp
                    ) {
                        appState.userProfile.tanningExperience = exp
                        if appState.userProfile.hapticsEnabled { HapticService.light() }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { advance() }
                    }
                }
            }
        }
    }

    // MARK: – Step 4: Beauty Concerns
    var stepConcerns: some View {
        OnboardingStepWrapper(title: "Beauty concerns?", subtitle: "Pick all that apply — we'll give you extra insight on these.") {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(BeautyConcern.allCases, id: \.self) { concern in
                    MultiSelectOptionButton(
                        label: concern.rawValue,
                        icon: concern.icon,
                        isSelected: appState.userProfile.concerns.contains(concern)
                    ) {
                        if appState.userProfile.hapticsEnabled { HapticService.light() }
                        if appState.userProfile.concerns.contains(concern) {
                            appState.userProfile.concerns.removeAll { $0 == concern }
                        } else {
                            appState.userProfile.concerns.append(concern)
                        }
                    }
                }
            }
            nextButton()
        }
    }

    // MARK: – Step 5: Location
    var stepLocation: some View {
        OnboardingStepWrapper(
            title: "Where are you?",
            subtitle: "Raydiant uses your location to find your best UV and glow windows."
        ) {
            VStack(spacing: 16) {
                if locationDenied {
                    // Manual city search
                    VStack(spacing: 10) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.white.opacity(0.6))
                            TextField("Search city...", text: $searchText)
                                .font(RaydiantFonts.rounded(16))
                                .foregroundStyle(.white)
                                .tint(.white)
                                .onSubmit { searchCity() }
                                .onChange(of: searchText) {
                                    if searchText.count > 2 { searchCity() }
                                }
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.15))
                                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.white.opacity(0.3), lineWidth: 1))
                        )

                        if !cityResults.isEmpty {
                            VStack(spacing: 0) {
                                ForEach(cityResults) { city in
                                    Button {
                                        Task {
                                            await appState.fetchWeatherForCity(city)
                                            appState.completeOnboarding()
                                        }
                                    } label: {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(city.name)
                                                    .font(RaydiantFonts.rounded(15, weight: .semibold))
                                                    .foregroundStyle(.white)
                                                Text(city.displayName)
                                                    .font(RaydiantFonts.rounded(12))
                                                    .foregroundStyle(.white.opacity(0.6))
                                            }
                                            Spacer()
                                            Image(systemName: "arrow.right")
                                                .foregroundStyle(.white.opacity(0.4))
                                        }
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 12)
                                    }
                                    Divider().background(Color.white.opacity(0.1))
                                }
                            }
                            .background(Color.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                }

                if !locationDenied {
                    Button {
                        Task {
                            let loc = await appState.locationService.requestLocation()
                            if loc == nil || appState.locationService.isLocationDenied {
                                locationDenied = true
                            } else {
                                await appState.fetchWeatherForCurrentLocation()
                                appState.completeOnboarding()
                            }
                        }
                    } label: {
                        Label("Use my location", systemImage: "location.fill")
                            .font(RaydiantFonts.rounded(16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(LinearGradient(colors: [RaydiantColors.pink, RaydiantColors.orange], startPoint: .leading, endPoint: .trailing))
                            )
                    }

                    Button {
                        locationDenied = true
                    } label: {
                        Text("Search for a city instead")
                            .font(RaydiantFonts.rounded(14, weight: .medium))
                            .foregroundStyle(.white.opacity(0.7))
                            .underline()
                    }
                }

                Button {
                    // Use default city (Singapore)
                    Task {
                        await appState.fetchWeather(lat: AppConstants.defaultLatitude, lon: AppConstants.defaultLongitude)
                        appState.cityName = AppConstants.defaultCity
                        appState.completeOnboarding()
                    }
                } label: {
                    Text("Skip — use Singapore as default")
                        .font(RaydiantFonts.rounded(13, weight: .regular))
                        .foregroundStyle(.white.opacity(0.5))
                        .underline()
                }
            }
        }
    }

    // MARK: – Helpers

    private func advance() {
        if currentStep < totalSteps - 1 {
            currentStep += 1
        }
    }

    private func nextButton() -> some View {
        Button { advance() } label: {
            Text("Continue")
                .font(RaydiantFonts.rounded(17, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.2))
                        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.white.opacity(0.4), lineWidth: 1))
                )
        }
        .padding(.top, 8)
    }

    private func searchCity() {
        guard !searchText.isEmpty else { return }
        isSearching = true
        Task {
            do {
                cityResults = try await weatherService.searchCity(searchText)
            } catch {
                cityResults = []
            }
            isSearching = false
        }
    }
}

struct ProgressBar: View {
    var current: Int
    var total: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<total, id: \.self) { i in
                Capsule()
                    .fill(i < current ? Color.white : Color.white.opacity(0.3))
                    .frame(height: 4)
                    .animation(.spring(duration: 0.3), value: current)
            }
        }
    }
}

struct OnboardingStepWrapper<Content: View, Extra: View>: View {
    var title: String
    var subtitle: String
    @ViewBuilder var content: () -> Content
    @ViewBuilder var extra: () -> Extra

    init(title: String, subtitle: String, @ViewBuilder content: @escaping () -> Content, @ViewBuilder extra: @escaping () -> Extra = { EmptyView() }) {
        self.title = title
        self.subtitle = subtitle
        self.content = content
        self.extra = extra
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(RaydiantFonts.rounded(28, weight: .bold))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(RaydiantFonts.rounded(15, weight: .regular))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.top, 24)

                content()
                extra()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}
