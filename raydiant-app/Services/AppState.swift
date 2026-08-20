import SwiftUI
import Foundation

@MainActor
class AppState: ObservableObject {
    @Published var hasCompletedOnboarding: Bool
    @Published var userProfile: UserProfile
    @Published var todayData: TodayGlowData?
    @Published var forecastData: [DayForecast] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var cityName: String = ""
    @Published var lastUpdated: Date?

    private let weatherService = WeatherService()
    let locationService = LocationService()

    init() {
        let defaults = UserDefaults.standard
        self.hasCompletedOnboarding = defaults.bool(forKey: "hasCompletedOnboarding")

        if let data = defaults.data(forKey: "userProfile"),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.userProfile = profile
        } else {
            self.userProfile = UserProfile()
        }
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        saveProfile()
    }

    func saveProfile() {
        if let data = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(data, forKey: "userProfile")
        }
        if userProfile.hapticsEnabled { HapticService.medium() }
    }

    func resetOnboarding() {
        hasCompletedOnboarding = false
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
    }

    func refresh() {
        Task { await fetchWeatherForCurrentLocation() }
    }

    func fetchWeatherForCurrentLocation() async {
        isLoading = true
        errorMessage = nil

        let location = await locationService.requestLocation()

        if let loc = location {
            await fetchWeather(lat: loc.latitude, lon: loc.longitude)
        } else if let lat = userProfile.defaultLatitude, let lon = userProfile.defaultLongitude {
            cityName = userProfile.defaultCity.isEmpty ? "Your City" : userProfile.defaultCity
            await fetchWeather(lat: lat, lon: lon)
        } else {
            cityName = AppConstants.defaultCity
            await fetchWeather(lat: AppConstants.defaultLatitude, lon: AppConstants.defaultLongitude)
        }

        isLoading = false
    }

    func fetchWeather(lat: Double, lon: Double) async {
        do {
            async let weatherFetch = weatherService.fetchWeather(latitude: lat, longitude: lon)
            async let cityFetch = weatherService.reverseGeocode(latitude: lat, longitude: lon)

            let (response, city) = try await (weatherFetch, cityFetch)
            if let city { cityName = city }
            processWeatherData(response)
            lastUpdated = Date()
        } catch {
            errorMessage = "Couldn't load weather data. Showing estimated conditions."
            loadMockData()
        }
    }

    func fetchWeatherForCity(_ city: GeocodingResult) async {
        isLoading = true
        cityName = city.name
        userProfile.defaultLatitude = city.latitude
        userProfile.defaultLongitude = city.longitude
        userProfile.defaultCity = city.name
        saveProfile()
        await fetchWeather(lat: city.latitude, lon: city.longitude)
        isLoading = false
    }

    private func processWeatherData(_ response: OpenMeteoResponse) {
        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)

        let dayFmt = DateFormatter()
        dayFmt.dateFormat = "yyyy-MM-dd"
        let todayStr = dayFmt.string(from: now)

        let hourFmt = DateFormatter()
        hourFmt.dateFormat = "yyyy-MM-dd'T'HH:mm"

        // Extract today's hourly data
        var hourlyUV: [(hour: Int, uv: Double)] = []
        var currentHumidity = 65
        var currentTemp = 28.0
        var currentCloud = 20

        for (i, timeStr) in response.hourly.time.enumerated() {
            guard timeStr.hasPrefix(todayStr) else { continue }
            let hourPart = String(timeStr.dropFirst(11).prefix(2))
            guard let hour = Int(hourPart) else { continue }
            let uv = response.hourly.uvIndex[i] ?? 0.0
            hourlyUV.append((hour: hour, uv: uv))
            if hour == currentHour {
                currentHumidity = response.hourly.relativeHumidity2m[i] ?? 65
                currentTemp = response.hourly.temperature2m[i] ?? 28.0
                currentCloud = response.hourly.cloudCover[i] ?? 20
            }
        }

        let currentUV = hourlyUV.first(where: { $0.hour == currentHour })?.uv
            ?? hourlyUV.last(where: { $0.hour < currentHour })?.uv ?? 0.0

        // Parse today's sunrise/sunset
        var sunrise: Date? = nil
        var sunset: Date? = nil
        if let idx = response.daily.time.firstIndex(of: todayStr) {
            sunrise = hourFmt.date(from: response.daily.sunrise[idx])
            sunset = hourFmt.date(from: response.daily.sunset[idx])
        }

        let glowScore = GlowScoreCalculator.calculate(
            uvIndex: currentUV, cloudCover: Double(currentCloud),
            humidity: Double(currentHumidity), temperature: currentTemp,
            currentTime: now, sunrise: sunrise, sunset: sunset
        )
        let glowLabel = GlowScoreCalculator.label(for: glowScore, uvIndex: currentUV)
        let glowAdvice = GlowScoreCalculator.advice(for: glowScore, uvIndex: currentUV)
        let uvRiskLabel = GlowScoreCalculator.uvRiskLabel(for: currentUV)

        let tanWindows = TanWindowCalculator.calculate(
            hourlyUV: hourlyUV, sunrise: sunrise, sunset: sunset, profile: userProfile
        )
        let burnRisk = BurnRiskCalculator.calculate(uvIndex: currentUV, profile: userProfile)
        let hyperpigRisk = BeautyIndexCalculator.hyperpigmentationRisk(uvIndex: currentUV, profile: userProfile)
        let makeupSurvival = BeautyIndexCalculator.makeupSurvival(humidity: Double(currentHumidity), temperature: currentTemp)
        let hairFrizz = BeautyIndexCalculator.hairFrizz(humidity: Double(currentHumidity))
        let sweatiness = BeautyIndexCalculator.sweatiness(temperature: currentTemp, humidity: Double(currentHumidity))
        let beachScore = BeautyIndexCalculator.beachDayScore(
            uvIndex: currentUV, cloudCover: Double(currentCloud),
            temperature: currentTemp, humidity: Double(currentHumidity)
        )
        let photoWindow = TanWindowCalculator.photoWindow(sunrise: sunrise, sunset: sunset)

        todayData = TodayGlowData(
            glowScore: glowScore, glowLabel: glowLabel, glowAdvice: glowAdvice,
            currentUV: currentUV, uvRiskLabel: uvRiskLabel, hourlyUV: hourlyUV,
            bestTanWindow: tanWindows.best, lowerRiskWindow: tanWindows.lowerRisk,
            avoidWindow: tanWindows.avoid, burnRisk: burnRisk,
            hyperpigmentationRisk: hyperpigRisk,
            hyperpigmentationAdvice: BeautyIndexCalculator.hyperpigmentationAdvice(risk: hyperpigRisk),
            makeupSurvival: makeupSurvival,
            makeupAdvice: BeautyIndexCalculator.makeupAdvice(survival: makeupSurvival),
            hairFrizzRisk: hairFrizz,
            hairFrizzAdvice: BeautyIndexCalculator.hairFrizzAdvice(risk: hairFrizz),
            sweatinessLevel: sweatiness,
            sweatinessAdvice: BeautyIndexCalculator.sweatinessAdvice(level: sweatiness),
            beachDayScore: beachScore,
            beachDayAdvice: BeautyIndexCalculator.beachAdvice(score: beachScore, uvIndex: currentUV),
            photoWindow: photoWindow, cityName: cityName, lastUpdated: now,
            currentTemp: currentTemp, currentHumidity: currentHumidity, currentCloud: currentCloud
        )

        processForecastData(response, hourFmt: hourFmt, dayFmt: dayFmt)
    }

    private func processForecastData(_ response: OpenMeteoResponse, hourFmt: DateFormatter, dayFmt: DateFormatter) {
        var forecasts: [DayForecast] = []

        for (idx, dateStr) in response.daily.time.enumerated() {
            guard let date = dayFmt.date(from: dateStr) else { continue }
            let maxUV = response.daily.uvIndexMax[idx] ?? 0.0

            var dayHourlyUV: [(hour: Int, uv: Double)] = []
            for (hi, timeStr) in response.hourly.time.enumerated() {
                guard timeStr.hasPrefix(dateStr) else { continue }
                let hourPart = String(timeStr.dropFirst(11).prefix(2))
                if let h = Int(hourPart) {
                    dayHourlyUV.append((hour: h, uv: response.hourly.uvIndex[hi] ?? 0.0))
                }
            }

            let sunrise = hourFmt.date(from: response.daily.sunrise[idx])
            let sunset = hourFmt.date(from: response.daily.sunset[idx])

            let score = GlowScoreCalculator.calculateDaily(maxUV: maxUV)
            let label = GlowScoreCalculator.label(for: score, uvIndex: maxUV)
            let windows = TanWindowCalculator.calculate(
                hourlyUV: dayHourlyUV, sunrise: sunrise, sunset: sunset, profile: userProfile
            )

            forecasts.append(DayForecast(
                date: date, maxUV: maxUV, glowScore: score, glowLabel: label,
                bestTanWindow: windows.best,
                riskLabel: GlowScoreCalculator.uvRiskLabel(for: maxUV),
                advice: GlowScoreCalculator.shortAdvice(for: maxUV),
                sunrise: sunrise, sunset: sunset
            ))
        }

        forecastData = forecasts
    }

    private func loadMockData() {
        todayData = MockData.todayGlowData
        forecastData = MockData.forecastData
        if cityName.isEmpty { cityName = AppConstants.defaultCity }
    }
}

enum HapticService {
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    static func heavy() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
