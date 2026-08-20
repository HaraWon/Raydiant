import SwiftUI

enum RaydiantColors {
    static let pink = Color(red: 1.0, green: 0.23, blue: 0.5)
    static let orange = Color(red: 1.0, green: 0.48, blue: 0.18)
    static let yellow = Color(red: 1.0, green: 0.82, blue: 0.2)
    static let softPink = Color(red: 1.0, green: 0.6, blue: 0.75)
    static let deepPurple = Color(red: 0.5, green: 0.1, blue: 0.8)

    static let gradientDefault = [pink, orange, yellow]
    static let gradientMorning = [Color(red: 1.0, green: 0.7, blue: 0.3), Color(red: 1.0, green: 0.4, blue: 0.2), Color(red: 0.8, green: 0.2, blue: 0.5)]
    static let gradientMidday = [Color(red: 1.0, green: 0.82, blue: 0.2), Color(red: 1.0, green: 0.5, blue: 0.1), Color(red: 1.0, green: 0.2, blue: 0.4)]
    static let gradientEvening = [Color(red: 0.9, green: 0.3, blue: 0.6), Color(red: 0.6, green: 0.1, blue: 0.5), Color(red: 0.3, green: 0.05, blue: 0.4)]
    static let gradientNight = [Color(red: 0.1, green: 0.05, blue: 0.3), Color(red: 0.2, green: 0.1, blue: 0.5), Color(red: 0.15, green: 0.05, blue: 0.35)]

    static func gradient(for hour: Int, uvIndex: Double) -> [Color] {
        switch hour {
        case 5..<9: return gradientMorning
        case 9..<17:
            if uvIndex >= 8 { return gradientMidday }
            return gradientDefault
        case 17..<21: return gradientEvening
        default: return gradientNight
        }
    }
}

enum RaydiantFonts {
    static func rounded(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

enum AppConstants {
    static let defaultLatitude = 1.3521
    static let defaultLongitude = 103.8198
    static let defaultCity = "Singapore"
    static let openMeteoBase = "https://api.open-meteo.com/v1/forecast"
    static let geocodingBase = "https://geocoding-api.open-meteo.com/v1/search"
    static let sunscreenReapplyMinutes = 120
}
