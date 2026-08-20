import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var searchText = ""
    @State private var cityResults: [GeocodingResult] = []
    @State private var showCitySearch = false
    @State private var showResetAlert = false
    @State private var isSaved = false

    private let weatherService = WeatherService()

    var body: some View {
        ZStack {
            GradientBackground(uvIndex: 4, animated: false)

            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 12) {
                        RaydiantLogoView(size: 70, animate: false)
                        VStack(spacing: 4) {
                            Text("Your Profile")
                                .font(RaydiantFonts.rounded(26, weight: .bold))
                                .foregroundStyle(.white)
                            Text("Personalise your Raydiant experience")
                                .font(RaydiantFonts.rounded(13))
                                .foregroundStyle(.white.opacity(0.65))
                        }
                    }
                    .padding(.top, 60)

                    // Goal
                    profileSection(title: "Goal", icon: "sparkles") {
                        VStack(spacing: 8) {
                            ForEach(Goal.allCases, id: \.self) { goal in
                                OnboardingOptionButton(
                                    label: goal.rawValue, icon: goal.icon,
                                    isSelected: appState.userProfile.goal == goal
                                ) {
                                    appState.userProfile.goal = goal
                                }
                            }
                        }
                    }

                    // Skin profile
                    profileSection(title: "Skin Profile", icon: "person.fill") {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Skin tone")
                                .font(RaydiantFonts.rounded(13)).foregroundStyle(.white.opacity(0.6))
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                ForEach(SkinTone.allCases, id: \.self) { tone in
                                    Button {
                                        appState.userProfile.skinTone = tone
                                    } label: {
                                        VStack(spacing: 4) {
                                            Text(tone.emoji)
                                                .font(.system(size: 24))
                                            Text(tone.rawValue)
                                                .font(RaydiantFonts.rounded(11, weight: .medium))
                                                .foregroundStyle(.white)
                                                .multilineTextAlignment(.center)
                                        }
                                        .padding(.vertical, 10)
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(appState.userProfile.skinTone == tone ? Color.white.opacity(0.25) : Color.white.opacity(0.1))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .strokeBorder(appState.userProfile.skinTone == tone ? Color.white.opacity(0.5) : .clear, lineWidth: 1.5)
                                                )
                                        )
                                    }
                                }
                            }

                            Text("Burn tendency")
                                .font(RaydiantFonts.rounded(13)).foregroundStyle(.white.opacity(0.6))
                                .padding(.top, 4)
                            ForEach(BurnTendency.allCases, id: \.self) { burn in
                                OnboardingOptionButton(label: burn.rawValue, isSelected: appState.userProfile.burnTendency == burn) {
                                    appState.userProfile.burnTendency = burn
                                }
                            }

                            Text("Tanning experience")
                                .font(RaydiantFonts.rounded(13)).foregroundStyle(.white.opacity(0.6))
                                .padding(.top, 4)
                            ForEach(TanningExperience.allCases, id: \.self) { exp in
                                OnboardingOptionButton(label: exp.rawValue, icon: exp.icon, isSelected: appState.userProfile.tanningExperience == exp) {
                                    appState.userProfile.tanningExperience = exp
                                }
                            }
                        }
                    }

                    // Beauty concerns
                    profileSection(title: "Beauty Concerns", icon: "heart.fill") {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(BeautyConcern.allCases, id: \.self) { concern in
                                MultiSelectOptionButton(
                                    label: concern.rawValue,
                                    icon: concern.icon,
                                    isSelected: appState.userProfile.concerns.contains(concern)
                                ) {
                                    if appState.userProfile.concerns.contains(concern) {
                                        appState.userProfile.concerns.removeAll { $0 == concern }
                                    } else {
                                        appState.userProfile.concerns.append(concern)
                                    }
                                }
                            }
                        }
                    }

                    // Location
                    profileSection(title: "Default City", icon: "location.fill") {
                        VStack(spacing: 10) {
                            if !appState.userProfile.defaultCity.isEmpty {
                                HStack {
                                    Image(systemName: "location.fill")
                                        .foregroundStyle(RaydiantColors.pink)
                                    Text(appState.userProfile.defaultCity)
                                        .font(RaydiantFonts.rounded(15, weight: .semibold))
                                        .foregroundStyle(.white)
                                    Spacer()
                                }
                            }

                            Button { showCitySearch.toggle() } label: {
                                Label("Change city", systemImage: "magnifyingglass")
                                    .font(RaydiantFonts.rounded(14, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.white.opacity(0.15))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }

                            if showCitySearch {
                                citySearchView
                            }
                        }
                    }

                    // App settings
                    profileSection(title: "App Settings", icon: "gearshape.fill") {
                        VStack(spacing: 0) {
                            settingToggle(title: "Notifications", icon: "bell.fill", binding: $appState.userProfile.notificationsEnabled)
                            Divider().background(Color.white.opacity(0.1))
                            settingToggle(title: "Haptic feedback", icon: "hand.tap.fill", binding: $appState.userProfile.hapticsEnabled)
                            Divider().background(Color.white.opacity(0.1))
                            settingToggle(title: "Sound effects", icon: "speaker.wave.2.fill", binding: $appState.userProfile.soundEnabled)
                        }
                    }

                    // Save button
                    Button {
                        appState.saveProfile()
                        isSaved = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { isSaved = false }
                    } label: {
                        HStack {
                            Image(systemName: isSaved ? "checkmark.circle.fill" : "square.and.arrow.down.fill")
                            Text(isSaved ? "Saved!" : "Save Profile")
                        }
                        .font(RaydiantFonts.rounded(17, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(isSaved ?
                                    LinearGradient(colors: [.green, .green.opacity(0.7)], startPoint: .leading, endPoint: .trailing) :
                                    LinearGradient(colors: [RaydiantColors.pink, RaydiantColors.orange], startPoint: .leading, endPoint: .trailing)
                                )
                        )
                        .animation(.spring(duration: 0.3), value: isSaved)
                    }
                    .padding(.horizontal, 24)

                    // Reset onboarding
                    Button { showResetAlert = true } label: {
                        Text("Reset onboarding")
                            .font(RaydiantFonts.rounded(14))
                            .foregroundStyle(.white.opacity(0.5))
                            .underline()
                    }

                    Text("Raydiant gives estimates, not medical advice. Always seek shade and apply SPF.")
                        .font(RaydiantFonts.rounded(11))
                        .foregroundStyle(.white.opacity(0.35))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 40)
                }
                .padding(.bottom, 100)
            }
        }
        .alert("Reset Onboarding?", isPresented: $showResetAlert) {
            Button("Reset", role: .destructive) { appState.resetOnboarding() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will clear your preferences and take you back to the welcome screen.")
        }
    }

    func profileSection<Content: View>(title: String, icon: String, @ViewBuilder content: @escaping () -> Content) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                Label(title, systemImage: icon)
                    .font(RaydiantFonts.rounded(15, weight: .semibold))
                    .foregroundStyle(.white)
                content()
            }
        }
        .padding(.horizontal, 20)
    }

    func settingToggle(title: String, icon: String, binding: Binding<Bool>) -> some View {
        HStack {
            Label(title, systemImage: icon)
                .font(RaydiantFonts.rounded(14, weight: .medium))
                .foregroundStyle(.white)
            Spacer()
            Toggle("", isOn: binding)
                .tint(RaydiantColors.pink)
                .labelsHidden()
        }
        .padding(.vertical, 12)
    }

    var citySearchView: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.white.opacity(0.6))
                TextField("Search city...", text: $searchText)
                    .font(RaydiantFonts.rounded(15))
                    .foregroundStyle(.white)
                    .tint(.white)
                    .onSubmit { searchCity() }
                    .onChange(of: searchText) {
                        if searchText.count > 2 { searchCity() }
                    }
            }
            .padding(12)
            .background(Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.white.opacity(0.25), lineWidth: 1))

            if !cityResults.isEmpty {
                VStack(spacing: 0) {
                    ForEach(cityResults) { city in
                        Button {
                            Task { await appState.fetchWeatherForCity(city) }
                            showCitySearch = false
                            searchText = ""
                            cityResults = []
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(city.name)
                                        .font(RaydiantFonts.rounded(14, weight: .semibold))
                                        .foregroundStyle(.white)
                                    Text(city.displayName)
                                        .font(RaydiantFonts.rounded(11))
                                        .foregroundStyle(.white.opacity(0.55))
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                        }
                        Divider().background(Color.white.opacity(0.1))
                    }
                }
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private func searchCity() {
        Task {
            do {
                cityResults = try await weatherService.searchCity(searchText)
            } catch {
                cityResults = []
            }
        }
    }
}
